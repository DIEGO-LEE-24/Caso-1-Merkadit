// ===== src/handlers/salesHandler.js =====
const express = require('express');
const router = express.Router();
const salesController = require('../controllers/salesController');

// POST /api/sales/register - Register a new sale
router.post('/register', salesController.registerSale.bind(salesController));

// GET /api/sales/:saleID - Get sale details
router.get('/:saleID', salesController.getSale.bind(salesController));

module.exports = router;
// Agregar después de los otros endpoints
router.post('/test', (req, res) => {
    console.log('Test endpoint - Full request body:', JSON.stringify(req.body, null, 2));
    console.log('Products array:', req.body.products);
    console.log('Products is array:', Array.isArray(req.body.products));
    
    res.json({
        success: true,
        receivedData: req.body,
        productsArray: req.body.products,
        message: 'Test successful'
    });
});