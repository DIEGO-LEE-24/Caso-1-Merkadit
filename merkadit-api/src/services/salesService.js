// ===== src/services/salesService.js =====
const salesRepository = require('../repositories/salesRepository');

class SalesService {
    async registerSale(saleData) {
        try {
            // Business logic validation
            this.validateSaleData(saleData);
            
            // Process the sale
            const result = await salesRepository.registerSale(saleData);
            
            if (!result.success) {
                throw new Error(result.message);
            }
            
            return result;
        } catch (error) {
            console.error('Error in sales service:', error);
            throw error;
        }
    }

    validateSaleData(saleData) {
        const { commerceID, productID1, quantity1, unitPrice1 } = saleData;
        
        if (!commerceID) {
            throw new Error('Commerce ID is required');
        }
        
        if (!productID1 || !quantity1 || !unitPrice1) {
            throw new Error('At least one product with quantity and price is required');
        }
        
        if (quantity1 <= 0 || unitPrice1 <= 0) {
            throw new Error('Quantity and price must be positive numbers');
        }
        
        // Additional validations can be added here
    }

    async getSaleDetails(saleID) {
        try {
            const sale = await salesRepository.getSaleById(saleID);
            if (!sale) {
                throw new Error('Sale not found');
            }
            return sale;
        } catch (error) {
            console.error('Error getting sale details:', error);
            throw error;
        }
    }
}

module.exports = new SalesService();