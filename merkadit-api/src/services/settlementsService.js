// ===== src/services/settlementsService.js =====
const settlementsRepository = require('../repositories/settlementsRepository');

class SettlementsService {
    async processSettlement(settlementData) {
        try {
            // Business logic validation
            this.validateSettlementData(settlementData);
            
            // Process the settlement
            const result = await settlementsRepository.settleCommerce(settlementData);
            
            if (!result.success) {
                throw new Error(result.message);
            }
            
            return result;
        } catch (error) {
            console.error('Error in settlements service:', error);
            throw error;
        }
    }

    validateSettlementData(settlementData) {
        console.log('=== SETTLEMENTS DEBUG ===');
        console.log('Raw settlementData:', JSON.stringify(settlementData, null, 2));
        console.log('month value:', settlementData.month);
        console.log('month type:', typeof settlementData.month);
        console.log('Number(month):', Number(settlementData.month));
        console.log('========================');
        
        const { commerceID, month, year } = settlementData;
        
        if (!commerceID) {
            throw new Error('Commerce ID is required');
        }
        
        if (!month || Number(month) < 1 || Number(month) > 12) {
            throw new Error('Valid settlement month (1-12) is required');
        }
        
        if (!year || Number(year) < 2020) {
            throw new Error('Valid settlement year is required');
        }
    }

    async getCommerceSettlements(commerceID, year = null, month = null) {
        try {
            return await settlementsRepository.getSettlementsByCommerce(commerceID, year, month);
        } catch (error) {
            console.error('Error getting commerce settlements:', error);
            throw error;
        }
    }
}

module.exports = new SettlementsService();