require('dotenv').config();

const express = require('express');
const cors = require('cors');

const db = require('./db');
const authRoutes = require('./routes/auth');
const carsRoutes = require('./routes/cars');
const usersRoutes = require('./routes/users');
const seedRoutes = require('./routes/seed');

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json());

app.get('/health', async (_req, res) => {
  try {
    await db.query('SELECT 1');
    res.json({ status: 'ok', db: 'connected' });
  } catch (e) {
    res.status(500).json({ status: 'error', db: 'disconnected', details: e.message });
  }
});

app.use('/auth', authRoutes);
app.use('/cars', carsRoutes);
app.use('/users', usersRoutes);
app.use('/seed', seedRoutes);

app.use((_req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Backend running on http://localhost:${port}`);
});
