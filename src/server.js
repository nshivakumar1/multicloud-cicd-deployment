const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const os = require('os');

const app = express();
const port = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        hostname: os.hostname(),
        cloud: process.env.CLOUD_PROVIDER || 'Unknown'
    });
});

app.get('/', (req, res) => {
    const cloud = process.env.CLOUD_PROVIDER || 'Unknown';
    res.json({
        message: `Hello from ${cloud} Multi-Cloud Application!`,
        cloud: cloud,
        timestamp: new Date().toISOString(),
        hostname: os.hostname()
    });
});

app.get('/api/info', (req, res) => {
    res.json({
        application: 'Multi-Cloud CI/CD Demo',
        version: '1.0.0',
        cloud: process.env.CLOUD_PROVIDER || 'Unknown'
    });
});

app.use((req, res) => {
    res.status(404).json({ error: 'Not Found' });
});

const server = app.listen(port, '0.0.0.0', () => {
    console.log(`🚀 App listening at http://0.0.0.0:${port}`);
    console.log(`☁️ Cloud: ${process.env.CLOUD_PROVIDER || 'Unknown'}`);
});

module.exports = app;
