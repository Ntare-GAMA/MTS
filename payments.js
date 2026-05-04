const express = require('express');
const router = express.Router();
const db = require('../config/database');
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

// MTN MoMo API Configuration
const MOMO_BASE_URL = process.env.MTN_MOMO_BASE_URL || 'https://sandbox.momodeveloper.mtn.com';
const SUBSCRIPTION_KEY = process.env.MTN_MOMO_SUBSCRIPTION_KEY;
const API_USER = process.env.MTN_MOMO_API_USER;
const API_KEY = process.env.MTN_MOMO_API_KEY;
const ENVIRONMENT = process.env.MTN_MOMO_ENVIRONMENT || 'sandbox';
const CALLBACK_URL = process.env.MTN_MOMO_CALLBACK_URL;

// Get MTN MoMo Access Token
async function getAccessToken() {
  try {
    const auth = Buffer.from(`${API_USER}:${API_KEY}`).toString('base64');
    
    const response = await axios.post(
      `${MOMO_BASE_URL}/collection/token/`,
      {},
      {
        headers: {
          'Authorization': `Basic ${auth}`,
          'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY
        }
      }
    );
    
    return response.data.access_token;
  } catch (error) {
    console.error('Error getting access token:', error.response?.data || error.message);
    throw new Error('Failed to get MTN MoMo access token');
  }
}

// Request to Pay - MTN MoMo Collection API
router.post('/request-payment', async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    const { orderId, amount, phoneNumber, paymentMethod } = req.body;
    
    // Validate input
    if (!orderId || !amount || !phoneNumber) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required fields: orderId, amount, phoneNumber' 
      });
    }
    
    // Generate unique transaction ID
    const transactionId = uuidv4();
    
    // Create payment transaction record
    await connection.query(
      `INSERT INTO payment_transactions 
       (order_id, transaction_id, amount, currency, payment_method, phone_number, status)
       VALUES (?, ?, ?, 'RWF', ?, ?, 'pending')`,
      [orderId, transactionId, amount, paymentMethod, phoneNumber]
    );
    
    // Get access token
    const accessToken = await getAccessToken();
    
    // Format phone number for MTN (must be without country code for Rwanda)
    // Expected format: 25078XXXXXXX or 078XXXXXXX -> 78XXXXXXX
    let formattedPhone = phoneNumber.replace(/\s+/g, '');
    if (formattedPhone.startsWith('250')) {
      formattedPhone = formattedPhone.substring(3);
    }
    if (formattedPhone.startsWith('0')) {
      formattedPhone = formattedPhone.substring(1);
    }
    
    // Request to Pay
    const requestPayload = {
      amount: amount.toString(),
      currency: 'RWF',
      externalId: orderId.toString(),
      payer: {
        partyIdType: 'MSISDN',
        partyId: formattedPhone
      },
      payerMessage: 'Payment for MTS Bakery Order',
      payeeNote: `Order #${orderId}`
    };
    
    console.log('Requesting payment:', requestPayload);
    
    const paymentResponse = await axios.post(
      `${MOMO_BASE_URL}/collection/v1_0/requesttopay`,
      requestPayload,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'X-Reference-Id': transactionId,
          'X-Target-Environment': ENVIRONMENT,
          'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY,
          'Content-Type': 'application/json',
          'X-Callback-Url': CALLBACK_URL
        }
      }
    );
    
    // Update transaction status
    await connection.query(
      'UPDATE payment_transactions SET status = ? WHERE transaction_id = ?',
      ['processing', transactionId]
    );
    
    // Update order payment status
    await connection.query(
      'UPDATE orders SET payment_status = ?, transaction_id = ? WHERE id = ?',
      ['processing', transactionId, orderId]
    );
    
    res.json({
      success: true,
      transactionId,
      message: 'Payment request sent. Please check your phone to approve the transaction.',
      status: 'processing'
    });
    
  } catch (error) {
    console.error('Error requesting payment:', error.response?.data || error.message);
    
    // Update transaction status to failed
    if (error.config?.headers?.['X-Reference-Id']) {
      await connection.query(
        'UPDATE payment_transactions SET status = ?, error_message = ? WHERE transaction_id = ?',
        ['failed', error.message, error.config.headers['X-Reference-Id']]
      );
    }
    
    res.status(500).json({ 
      success: false, 
      error: 'Payment request failed',
      message: error.response?.data?.message || error.message
    });
  } finally {
    connection.release();
  }
});

// Check Payment Status
router.get('/status/:transactionId', async (req, res) => {
  try {
    const { transactionId } = req.params;
    
    // Check local database first
    const [transactions] = await db.query(
      'SELECT * FROM payment_transactions WHERE transaction_id = ?',
      [transactionId]
    );
    
    if (transactions.length === 0) {
      return res.status(404).json({ success: false, error: 'Transaction not found' });
    }
    
    const transaction = transactions[0];
    
    // If already successful or failed, return cached status
    if (transaction.status === 'successful' || transaction.status === 'failed') {
      return res.json({
        success: true,
        status: transaction.status,
        transaction
      });
    }
    
    // Get access token
    const accessToken = await getAccessToken();
    
    // Check payment status from MTN MoMo
    const statusResponse = await axios.get(
      `${MOMO_BASE_URL}/collection/v1_0/requesttopay/${transactionId}`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'X-Target-Environment': ENVIRONMENT,
          'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY
        }
      }
    );
    
    const momoStatus = statusResponse.data.status;
    let dbStatus = 'pending';
    
    if (momoStatus === 'SUCCESSFUL') {
      dbStatus = 'successful';
    } else if (momoStatus === 'FAILED') {
      dbStatus = 'failed';
    }
    
    // Update transaction in database
    await db.query(
      `UPDATE payment_transactions 
       SET status = ?, momo_transaction_id = ?, momo_financial_transaction_id = ?
       WHERE transaction_id = ?`,
      [dbStatus, statusResponse.data.externalId, statusResponse.data.financialTransactionId, transactionId]
    );
    
    // Update order payment status
    await db.query(
      'UPDATE orders SET payment_status = ? WHERE transaction_id = ?',
      [dbStatus, transactionId]
    );
    
    res.json({
      success: true,
      status: dbStatus,
      momoResponse: statusResponse.data
    });
    
  } catch (error) {
    console.error('Error checking payment status:', error.response?.data || error.message);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to check payment status',
      message: error.message
    });
  }
});

// Payment Callback (webhook)
router.post('/callback', async (req, res) => {
  try {
    console.log('Payment callback received:', req.body);
    
    const { status, financialTransactionId, externalId } = req.body;
    
    // Update transaction based on callback
    if (status === 'SUCCESSFUL') {
      await db.query(
        `UPDATE payment_transactions 
         SET status = 'successful', momo_financial_transaction_id = ?, callback_data = ?
         WHERE order_id = ?`,
        [financialTransactionId, JSON.stringify(req.body), externalId]
      );
      
      await db.query(
        'UPDATE orders SET payment_status = ? WHERE id = ?',
        ['successful', externalId]
      );
    }
    
    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Error processing callback:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
