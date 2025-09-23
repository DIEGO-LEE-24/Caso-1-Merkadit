// ===== src/handlers/settlementsHandler.js =====
const express = require('express');
const router = express.Router();
const settlementsController = require('../controllers/settlementsController');

// POST /api/settlements/process - Process monthly settlement
router.post('/process', settlementsController.processSettlement.bind(settlementsController));

// GET /api/settlements/commerce/:commerceID - Get settlements for a commerce
router.get('/commerce/:commerceID', settlementsController.getCommerceSettlements.bind(settlementsController));

module.exports = router;