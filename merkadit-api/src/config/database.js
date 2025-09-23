// ===== src/config/database.js =====
const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'merkadit',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    multipleStatements: true
};

class Database {
    constructor() {
        this.pool = null;
    }

    async initialize() {
        try {
            this.pool = mysql.createPool(dbConfig);
            console.log('Database connection pool created successfully');
            
            // Test connection
            const connection = await this.pool.getConnection();
            await connection.ping();
            connection.release();
            console.log('Database connection tested successfully');
        } catch (error) {
            console.error('Database connection failed - Full error:', error);
            process.exit(1);
        }
    }

    getPool() {
        if (!this.pool) {
            throw new Error('Database not initialized. Call initialize() first.');
        }
        return this.pool;
    }

    async executeStoredProcedure(procedureName, parameters = []) {
        const connection = await this.pool.getConnection();
        try {
            const placeholders = parameters.map(() => '?').join(',');
            const query = `CALL ${procedureName}(${placeholders})`;
            
            const [results] = await connection.execute(query, parameters);
            return results;
        } catch (error) {
            console.error(`Error executing stored procedure ${procedureName}:`, error);
            throw error;
        } finally {
            connection.release();
        }
    }

    async query(sql, parameters = []) {
        const connection = await this.pool.getConnection();
        try {
            const [results] = await connection.execute(sql, parameters);
            return results;
        } catch (error) {
            console.error('Database query error:', error);
            throw error;
        } finally {
            connection.release();
        }
    }
}

module.exports = new Database();