const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../db');

const router = express.Router();

router.post('/register', async (req, res) => {
  try {
    const { name, email, password, phone, role = 'client' } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }

    const exists = await db.query('SELECT id FROM users WHERE LOWER(email)=LOWER($1) LIMIT 1', [email]);
    if (exists.rowCount > 0) {
      return res.status(409).json({ error: 'Email already exists' });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const result = await db.query(
      `INSERT INTO users (name, email, password_hash, phone, role)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, name, email, phone, role, created_at`,
      [name || null, email, passwordHash, phone || null, role]
    );

    return res.status(201).json(result.rows[0]);
  } catch (e) {
    return res.status(500).json({ error: 'register failed', details: e.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }

    const result = await db.query(
      'SELECT id, name, email, phone, role, password_hash FROM users WHERE LOWER(email)=LOWER($1) LIMIT 1',
      [email]
    );

    if (result.rowCount === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'dev_secret',
      { expiresIn: '7d' }
    );

    delete user.password_hash;
    return res.json({ token, user });
  } catch (e) {
    return res.status(500).json({ error: 'login failed', details: e.message });
  }
});

module.exports = router;
