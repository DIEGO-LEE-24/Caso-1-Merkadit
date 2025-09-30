// ===== src/controllers/salesController.js =====
const salesService = require('../services/salesService');

class SalesController {
    async registerSale(req, res) {
        try {
            const saleData = {
                commerceID: req.body.commerceID,
                customerID: req.body.customerID,
                paymentMethodID: req.body.paymentMethodID,
                paymentReference: req.body.paymentReference,
                discountAmount: req.body.discountAmount,
 		        products: req.body.products,
                computer: req.body.computer || req.ip,
                username: req.body.username || 'API_User'
            };

            const result = await salesService.registerSale(saleData);
            
            res.status(201).json({
                success: true,
                data: result.data,
                message: result.message
            });
        } catch (error) {
            console.error('Error in sales controller:', error);
            res.status(400).json({
                success: false,
                error: error.message,
                message: 'Failed to register sale'
            });
        }
    }

    async getSale(req, res) {
        try {
            const { saleID } = req.params;
            const sale = await salesService.getSaleDetails(saleID);
            
            res.json({
                success: true,
                data: sale
            });
        } catch (error) {
            console.error('Error getting sale:', error);
            res.status(404).json({
                success: false,
                error: error.message
            });
        }
    }
}

module.exports = new SalesController();
