const express = require('express');
const db = require('../db');
const { authRequired, roleRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/', authRequired, roleRequired('admin'), async (_req, res) => {
  try {
    const result = await db.query(
      `SELECT id, name, email, phone, role, is_verified, created_at, updated_at
       FROM users
       ORDER BY created_at DESC`
    );
    return res.json(result.rows);
  } catch (e) {
    return res.status(500).json({ error: 'users list failed', details: e.message });
  }
});

router.patch('/:id/role', authRequired, roleRequired('admin'), async (req, res) => {
  try {
    const { role } = req.body;
    if (!role || !['admin', 'dealer', 'client'].includes(role)) {
      return res.status(400).json({ error: 'invalid role' });
    }

    const result = await db.query(
      'UPDATE users SET role = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING id, name, email, role',
      [role, req.params.id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    return res.json(result.rows[0]);
  } catch (e) {
    return res.status(500).json({ error: 'role update failed', details: e.message });
  }
});

router.delete('/:id', authRequired, roleRequired('admin'), async (req, res) => {
  try {
    const result = await db.query('DELETE FROM users WHERE id = $1 RETURNING id', [req.params.id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    return res.json({ success: true });
  } catch (e) {
    return res.status(500).json({ error: 'delete user failed', details: e.message });
  }
});

module.exports = router;
