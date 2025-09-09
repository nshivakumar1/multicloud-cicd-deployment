const request = require('supertest');
const app = require('../server');

describe('API Tests', () => {
    test('GET / should return welcome message', async () => {
        const res = await request(app).get('/');
        expect(res.statusCode).toBe(200);
        expect(res.body).toHaveProperty('message');
        expect(res.body).toHaveProperty('cloud');
    });

    test('GET /health should return health status', async () => {
        const res = await request(app).get('/health');
        expect(res.statusCode).toBe(200);
        expect(res.body.status).toBe('healthy');
    });

    test('GET /api/info should return app info', async () => {
        const res = await request(app).get('/api/info');
        expect(res.statusCode).toBe(200);
        expect(res.body).toHaveProperty('application');
    });

    test('GET /nonexistent should return 404', async () => {
        const res = await request(app).get('/nonexistent');
        expect(res.statusCode).toBe(404);
    });
});
