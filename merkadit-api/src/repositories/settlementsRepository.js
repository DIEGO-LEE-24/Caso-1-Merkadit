// ===== src/repositories/settlementsRepository.js =====
const database = require('../config/database');

class SettlementsRepository {
    async settleCommerce(settlementData) {
        try {
            console.log('=== REPOSITORY SETTLEMENTS DEBUG ===');
            console.log('settlementData received:', JSON.stringify(settlementData, null, 2));
            
            const {
                commerceID,
                month,
                year,
                processedBy
            } = settlementData;
            
            console.log('Extracted values:');
            console.log('- commerceID:', commerceID);
            console.log('- month:', month); 
            console.log('- year:', year);
            console.log('- processedBy:', processedBy);
            console.log('=====================================');

            const parameters = [commerceID, month, year, processedBy || 'API_User'];
            console.log('Parameters to SP:', parameters);

            // Use pool.getConnection for OUT parameters
            const connection = await database.pool.getConnection();
            
            const [results] = await connection.execute(
                'CALL SP_settleCommerce(?, ?, ?, ?, @settlementID, @totalAmount, @result)',
                parameters
            );

            // Get output parameters
            const [outputs] = await connection.execute('SELECT @settlementID as settlementID, @totalAmount as totalAmount, @result as result');
            
            connection.release();
            
            console.log('SP Output:', outputs[0]);
            
            return {
                success: true,
                data: outputs[0],
                message: outputs[0].result || 'Settlement processed successfully'
            };

        } catch (error) {
            console.error('Error in settleCommerce repository:', error);
            throw {
                success: false,
                error: error.message,
                message: 'Failed to process settlement'
            };
        }
    }

    async getSettlementsByCommerce(commerceID, year = null, month = null) {
        try {
            let query = `
                SELECT s.*, c.name as commerceName
                FROM Settlements s
                JOIN Contracts ct ON s.contractID = ct.contractID
                JOIN Commerces c ON ct.commerceID = c.commerceID
                WHERE ct.commerceID = ?
            `;
            
            const parameters = [commerceID];
            
            if (year) {
                query += ' AND YEAR(s.settlementDate) = ?';
                parameters.push(year);
            }
            
            if (month) {
                query += ' AND MONTH(s.settlementDate) = ?';
                parameters.push(month);
            }
            
            query += ' ORDER BY s.settlementDate DESC';
            
            const results = await database.query(query, parameters);
            return results;
        } catch (error) {
            console.error('Error getting settlements by commerce:', error);
            throw error;
        }
    }
}

module.exports = new SettlementsRepository();