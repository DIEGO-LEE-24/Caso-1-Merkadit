// ===== src/app.js =====
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const database = require('./config/database');
const salesHandler = require('./handlers/salesHandler');
const settlementsHandler = require('./handlers/settlementsHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Routes
app.use('/api/sales', salesHandler);
app.use('/api/settlements', settlementsHandler);

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        service: 'Merkadit API',
        version: '1.0.0'
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: 'Endpoint not found',
        path: req.originalUrl
    });
});

// Error handler
app.use((error, req, res, next) => {
    console.error('Unhandled error:', error);
    res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
});

// Initialize database and start server
async function startServer() {
    try {
        await database.initialize();
        
        app.listen(PORT, () => {
            console.log(`🚀 Merkadit API running on port ${PORT}`);
            console.log(`📊 Health check: http://localhost:${PORT}/health`);
            console.log(`📖 API Endpoints:`);
            console.log(`   POST http://localhost:${PORT}/api/sales/register`);
            console.log(`   GET  http://localhost:${PORT}/api/sales/:saleID`);
            console.log(`   POST http://localhost:${PORT}/api/settlements/process`);
            console.log(`   GET  http://localhost:${PORT}/api/settlements/commerce/:commerceID`);
        });
    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
}

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT received, shutting down gracefully');
    process.exit(0);
});

startServer();

module.exports = app;