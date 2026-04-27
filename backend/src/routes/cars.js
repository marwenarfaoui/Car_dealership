const express = require('express');
const db = require('../db');
const { authRequired, roleRequired } = require('../middleware/auth');

const router = express.Router();

router.get('/', async (_req, res) => {
  try {
    const result = await db.query(
      `SELECT id, dealership_id, brand, model, year, price, mileage, fuel_type,
              transmission, description, status, is_featured, created_at, updated_at
       FROM cars
       ORDER BY created_at DESC`
    );

    return res.json(result.rows);
  } catch (e) {
    return res.status(500).json({ error: 'cars list failed', details: e.message });
  }
});

router.post('/', authRequired, roleRequired('admin', 'dealer'), async (req, res) => {
  try {
    const {
      dealership_id = null,
      brand,
      model,
      year = null,
      price = null,
      mileage = null,
      fuel_type = null,
      transmission = null,
      description = null,
      status = 'available',
      is_featured = false,
    } = req.body;

    if (!brand || !model) {
      return res.status(400).json({ error: 'brand and model are required' });
    }

    const result = await db.query(
      `INSERT INTO cars (
        dealership_id, brand, model, year, price, mileage,
        fuel_type, transmission, description, status, is_featured
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
      RETURNING *`,
      [
        dealership_id,
        brand,
        model,
        year,
        price,
        mileage,
        fuel_type,
        transmission,
        description,
        status,
        is_featured,
      ]
    );

    return res.status(201).json(result.rows[0]);
  } catch (e) {
    return res.status(500).json({ error: 'create car failed', details: e.message });
  }
});

router.patch('/:id', authRequired, roleRequired('admin', 'dealer'), async (req, res) => {
  try {
    const { id } = req.params;
    const payload = req.body || {};

    const fields = [];
    const values = [];
    let i = 1;

    for (const [key, value] of Object.entries(payload)) {
      fields.push(`${key} = $${i++}`);
      values.push(value);
    }

    if (fields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    values.push(id);
    const result = await db.query(
      `UPDATE cars SET ${fields.join(', ')}, updated_at = CURRENT_TIMESTAMP WHERE id = $${i} RETURNING *`,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Car not found' });
    }

    return res.json(result.rows[0]);
  } catch (e) {
    return res.status(500).json({ error: 'update car failed', details: e.message });
  }
});

router.delete('/:id', authRequired, roleRequired('admin', 'dealer'), async (req, res) => {
  try {
    const result = await db.query('DELETE FROM cars WHERE id = $1 RETURNING id', [req.params.id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Car not found' });
    }
    return res.json({ success: true });
  } catch (e) {
    return res.status(500).json({ error: 'delete car failed', details: e.message });
  }
});

module.exports = router;
