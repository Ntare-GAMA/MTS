const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { v4: uuidv4 } = require('uuid');

// Create new order
router.post('/', async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();
    
    const { customer, items, paymentMethod, paymentPhone } = req.body;
    
    // Validate input
    if (!customer || !items || items.length === 0 || !paymentMethod || !paymentPhone) {
      throw new Error('Missing required fields');
    }
    
    // Check if customer exists, if not create
    let customerId;
    const [existingCustomers] = await connection.query(
      'SELECT id FROM customers WHERE phone = ?',
      [customer.phone]
    );
    
    if (existingCustomers.length > 0) {
      customerId = existingCustomers[0].id;
      // Update customer info
      await connection.query(
        'UPDATE customers SET name = ?, address = ? WHERE id = ?',
        [customer.name, customer.address, customerId]
      );
    } else {
      // Create new customer
      const [customerResult] = await connection.query(
        'INSERT INTO customers (name, phone, address) VALUES (?, ?, ?)',
        [customer.name, customer.phone, customer.address]
      );
      customerId = customerResult.insertId;
    }
    
    // Calculate total amount
    const totalAmount = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    
    // Generate order number
    const orderNumber = `ORD-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
    
    // Create order
    const [orderResult] = await connection.query(
      `INSERT INTO orders (order_number, customer_id, total_amount, payment_method, 
       payment_phone, delivery_address, payment_status, order_status) 
       VALUES (?, ?, ?, ?, ?, ?, 'pending', 'pending')`,
      [orderNumber, customerId, totalAmount, paymentMethod, paymentPhone, customer.address]
    );
    
    const orderId = orderResult.insertId;
    
    // Create order items
    for (const item of items) {
      const subtotal = item.price * item.quantity;
      await connection.query(
        `INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, subtotal)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [orderId, item.id, item.name, item.quantity, item.price, subtotal]
      );
    }
    
    await connection.commit();
    
    res.json({
      success: true,
      order: {
        orderId,
        orderNumber,
        totalAmount,
        customerId
      }
    });
    
  } catch (error) {
    await connection.rollback();
    console.error('Error creating order:', error);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    connection.release();
  }
});

// Get order by ID
router.get('/:id', async (req, res) => {
  try {
    const [orders] = await db.query(
      `SELECT o.*, c.name as customer_name, c.phone as customer_phone 
       FROM orders o 
       JOIN customers c ON o.customer_id = c.id 
       WHERE o.id = ?`,
      [req.params.id]
    );
    
    if (orders.length === 0) {
      return res.status(404).json({ success: false, error: 'Order not found' });
    }
    
    const [items] = await db.query(
      'SELECT * FROM order_items WHERE order_id = ?',
      [req.params.id]
    );
    
    res.json({
      success: true,
      order: {
        ...orders[0],
        items
      }
    });
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update order status
router.patch('/:id/status', async (req, res) => {
  try {
    const { orderStatus } = req.body;
    
    await db.query(
      'UPDATE orders SET order_status = ? WHERE id = ?',
      [orderStatus, req.params.id]
    );
    
    res.json({ success: true, message: 'Order status updated' });
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
