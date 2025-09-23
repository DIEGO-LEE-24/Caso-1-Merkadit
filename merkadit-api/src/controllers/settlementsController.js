// ===== src/controllers/settlementsController.js =====
const settlementsService = require('../services/settlementsService');

class SettlementsController {
    async processSettlement(req, res) {
        try {
            console.log('=== CONTROLLER SETTLEMENTS DEBUG ===');
            console.log('Raw req.body:', JSON.stringify(req.body, null, 2));
            console.log('Content-Type:', req.headers['content-type']);
            console.log('=====================================');
            
            const settlementData = {
                commerceID: req.body.commerceID,
                month: req.body.month,           // Cambiar de settlementMonth
                year: req.body.year,             // Cambiar de settlementYear
                processedBy: req.body.processedBy || 'API_User'  // Cambiar de username
            };

            const result = await settlementsService.processSettlement(settlementData);
            
            res.status(201).json({
                success: true,
                data: result.data,
                message: result.message
            });
        } catch (error) {
            console.error('Error in settlements controller:', error);
            res.status(400).json({
                success: false,
                error: error.message,
                message: 'Failed to process settlement'
            });
        }
    }

    async getCommerceSettlements(req, res) {
        try {
            const { commerceID } = req.params;
            const { year, month } = req.query;
            
            const settlements = await settlementsService.getCommerceSettlements(
                commerceID, 
                year ? parseInt(year) : null, 
                month ? parseInt(month) : null
            );
            
            res.json({
                success: true,
                data: settlements
            });
        } catch (error) {
            console.error('Error getting settlements:', error);
            res.status(400).json({
                success: false,
                error: error.message
            });
        }
    }
}

module.exports = new SettlementsController();