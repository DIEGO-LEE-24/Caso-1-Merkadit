// ===== src/repositories/salesRepository.js =====
const database = require('../config/database');

class SalesRepository {
    async registerSale(saleData) {
        try {
            console.log('Received saleData:', JSON.stringify(saleData, null, 2));
            
            let products = [];
            
            // Check if data comes as products array (expected format)
            if (saleData.products && Array.isArray(saleData.products)) {
                products = saleData.products.map(item => {
                    // If the input looks like { "product": { "productID": 1, ... } }
                    if (item.product && typeof item.product === 'object') {
                        return {
                            productID: item.product.productID,
                            quantity: item.product.quantity,
                            unitPrice: item.product.unitPrice
                        };
                    } 
                    // If the input looks like { "productID": 1, ... }
                    else {
                        return {
                            productID: item.productID,
                            quantity: item.quantity,
                            unitPrice: item.unitPrice
                        };
                    }
                });
            }

            console.log('Processed products:', products);
            console.log('Products count:', products.length);

            if (!products || products.length === 0) {
                throw new Error('No products found in request data');
            }

            const {
                commerceID,
                customerID,
                paymentMethodID,
                paymentReference,
                discountAmount,
                cashierName
            } = saleData;

            // Preparar productos individuales (máximo 3)
            const productsJSON = JSON.stringify(products);

            console.log('Products JSON for SP:', productsJSON);

            // Llamar al stored procedure con parámetros separados
            const connection = await database.pool.getConnection();
            
            const [results] = await connection.execute(
                'CALL SP_registerSale(?, ?, ?, ?, ?, ?, ?, ?, @saleID, @totalAmount, @result)',
                [
                    commerceID,
                    customerID || null,
                    paymentMethodID,
                    paymentReference || null,
                    discountAmount || 0,
   		    productsJSON,
                    'POS-001',  // posID fijo
                    cashierName || saleData.username || 'API_User'
                ]
            );

            // Obtener valores de salida
            const [outputs] = await connection.execute('SELECT @saleID as saleID, @totalAmount as totalAmount, @result as result');
            
            connection.release();

            console.log('SP Output:', outputs[0]);

            // Check if the result indicates success
            if (outputs[0].result === 'SUCCESS' || (outputs[0].result && outputs[0].result.includes('Sale registered successfully'))) {
                return {
                    success: true,
                    saleID: outputs[0].saleID,
                    totalAmount: outputs[0].totalAmount,
                    message: outputs[0].result,
                    invoice: outputs[0].result.includes('Invoice:') ? outputs[0].result.split('Invoice: ')[1].split('.')[0] : null
                };
            } else {
                throw new Error(outputs[0].result);
            }

        } catch (error) {
            console.error('Error in registerSale repository:', error);
            throw {
                success: false,
                error: error.message,
                message: 'Failed to register sale'
            };
        }
    }

    async getSaleById(saleID) {
        try {
            const connection = await database.pool.getConnection();
            
            const [results] = await connection.execute(`
                SELECT s.*, c.name as commerceName, cust.name as customerName,
                       pm.name as paymentMethod
                FROM Sales s
                LEFT JOIN Commerces c ON s.commerceID = c.commerceID
                LEFT JOIN Customers cust ON s.customerID = cust.customerID
                LEFT JOIN PaymentMethods pm ON s.paymentMethodID = pm.paymentMethodID
                WHERE s.saleID = ?
            `, [saleID]);

            // Obtener detalles de productos
            const [details] = await connection.execute(`
                SELECT sd.*, p.name as productName, p.sku
                FROM SaleDetails sd
                LEFT JOIN Products p ON sd.productID = p.productID
                WHERE sd.saleID = ?
            `, [saleID]);

            connection.release();

            if (results.length > 0) {
                return {
                    ...results[0],
                    products: details
                };
            }

            return null;
        } catch (error) {
            console.error('Error getting sale by ID:', error);
            throw error;
        }
    }
}

module.exports = new SalesRepository();
