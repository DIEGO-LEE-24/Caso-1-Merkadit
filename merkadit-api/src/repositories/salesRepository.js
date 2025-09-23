// ===== src/repositories/salesRepository.js =====
const database = require('../config/database');

class SalesRepository {
    async registerSale(saleData) {
        try {
            console.log('Received saleData:', JSON.stringify(saleData, null, 2));
            
            let products = [];
            
            // Check if data comes as products array (expected format)
            if (saleData.products && Array.isArray(saleData.products)) {
                products = saleData.products;
            } 
            // Check if data comes as individual fields (current issue)
            else if (saleData.productID1) {
                products = [];
                if (saleData.productID1) {
                    products.push({
                        productID: saleData.productID1,
                        quantity: saleData.quantity1,
                        unitPrice: saleData.unitPrice1
                    });
                }
                if (saleData.productID2) {
                    products.push({
                        productID: saleData.productID2,
                        quantity: saleData.quantity2,
                        unitPrice: saleData.unitPrice2
                    });
                }
                if (saleData.productID3) {
                    products.push({
                        productID: saleData.productID3,
                        quantity: saleData.quantity3,
                        unitPrice: saleData.unitPrice3
                    });
                }
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
            const product1 = products[0] || {};
            const product2 = products[1] || {};
            const product3 = products[2] || {};

            console.log('Product1:', product1);
            console.log('Product2:', product2);
            console.log('Product3:', product3);

            // Llamar al stored procedure con parámetros separados
            const connection = await database.pool.getConnection();
            
            const [results] = await connection.execute(
                'CALL SP_registerSale(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @saleID, @totalAmount, @result)',
                [
                    commerceID,
                    customerID || null,
                    paymentMethodID,
                    paymentReference || null,
                    discountAmount || 0,
                    product1.productID || null,
                    product1.quantity || null,
                    product1.unitPrice || null,
                    product2.productID || null,
                    product2.quantity || null,
                    product2.unitPrice || null,
                    product3.productID || null,
                    product3.quantity || null,
                    product3.unitPrice || null,
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