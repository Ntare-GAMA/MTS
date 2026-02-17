const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Get all products
router.get('/', async (req, res) => {
  try {
    const [products] = await db.query(
      'SELECT * FROM products WHERE in_stock = TRUE ORDER BY category, name'
    );
    res.json({ success: true, products });
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get products by category
router.get('/category/:category', async (req, res) => {
  try {
    const [products] = await db.query(
      'SELECT * FROM products WHERE category = ? AND in_stock = TRUE',
      [req.params.category]
    );
    res.json({ success: true, products });
  } catch (error) {
    console.error('Error fetching products by category:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get single product
router.get('/:id', async (req, res) => {
  try {
    const [products] = await db.query(
      'SELECT * FROM products WHERE id = ?',
      [req.params.id]
    );
    
    if (products.length === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }
    
    res.json({ success: true, product: products[0] });
  } catch (error) {
    console.error('Error fetching product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
