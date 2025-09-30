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
        const { commerceID, products} = saleData;
        
        if (!commerceID) {
            throw new Error('Commerce ID is required');
        }
        
        if (!products || !Array.isArray(products) || products.length === 0) {
            throw new Error('At least one product is required');
        }

        let hasValidProduct = false;
        for (const item of products) {
            
            const product = item.product || item;
            
            if (product.productID && product.quantity && product.unitPrice) {
                if (product.quantity <= 0) {
                    throw new Error('Quantity must be a positive number');
                }
                if (product.unitPrice <= 0) {
                    throw new Error('Unit price must be a positive number');
                }
                hasValidProduct = true;
            }
        }

        if (!hasValidProduct) {
            throw new Error('At least one product with productID, quantity and unitPrice is required');
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
