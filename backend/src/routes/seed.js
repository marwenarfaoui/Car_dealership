const express = require('express');
const bcrypt = require('bcrypt');
const db = require('../db');

const router = express.Router();

function isSeedAuthorized(req) {
  const providedKey = req.headers['x-seed-key'] || req.body?.seedKey;
  const expectedKey = process.env.SEED_API_KEY;
  if (!expectedKey) return { ok: false, reason: 'SEED_API_KEY is not configured', code: 500 };
  if (providedKey !== expectedKey) return { ok: false, reason: 'Unauthorized seed request', code: 401 };
  return { ok: true };
}

router.post('/', async (req, res) => {
  try {
    const auth = isSeedAuthorized(req);
    if (!auth.ok) return res.status(auth.code).json({ error: auth.reason });

    const adminPasswordHash = await bcrypt.hash('admin123', 10);
    const dealerPasswordHash = await bcrypt.hash('dealer123', 10);
    const clientPasswordHash = await bcrypt.hash('client123', 10);

    const adminResult = await db.query(
      `INSERT INTO users (name, email, password_hash, phone, role, is_verified)
       VALUES ($1,$2,$3,$4,$5,$6)
       ON CONFLICT (email)
       DO UPDATE SET name = EXCLUDED.name, phone = EXCLUDED.phone, role = EXCLUDED.role
       RETURNING id`,
      ['Admin User', 'admin@cardealer.com', adminPasswordHash, '11111111', 'admin', true]
    );

    const dealerResult = await db.query(
      `INSERT INTO users (name, email, password_hash, phone, role, is_verified)
       VALUES ($1,$2,$3,$4,$5,$6)
       ON CONFLICT (email)
       DO UPDATE SET name = EXCLUDED.name, phone = EXCLUDED.phone, role = EXCLUDED.role
       RETURNING id`,
      ['Dealer User', 'dealer@cardealer.com', dealerPasswordHash, '22222222', 'dealer', true]
    );

    await db.query(
      `INSERT INTO users (name, email, password_hash, phone, role, is_verified)
       VALUES ($1,$2,$3,$4,$5,$6)
       ON CONFLICT (email)
       DO UPDATE SET name = EXCLUDED.name, phone = EXCLUDED.phone, role = EXCLUDED.role`,
      ['Client User', 'client@cardealer.com', clientPasswordHash, '33333333', 'client', true]
    );

    const adminId = adminResult.rows[0]?.id;
    const dealerId = dealerResult.rows[0]?.id;

    const dealershipResult = await db.query(
      `INSERT INTO dealerships (name, description, address, city, owner_id)
       VALUES ($1,$2,$3,$4,$5)
       ON CONFLICT DO NOTHING
       RETURNING id`,
      [
        'Prime Auto Center',
        'Premium cars and professional support',
        'Main Street 1',
        'Tunis',
        dealerId || adminId || null,
      ]
    );

    let dealershipId = dealershipResult.rows[0]?.id;

    if (!dealershipId) {
      const existing = await db.query('SELECT id FROM dealerships ORDER BY created_at ASC LIMIT 1');
      dealershipId = existing.rows[0]?.id;
    }

    if (dealershipId) {
      await db.query(
        `INSERT INTO cars (dealership_id, brand, model, year, price, mileage, fuel_type, transmission, description, status, is_featured)
         VALUES
         ($1,'Tesla','Model S Plaid',2023,129990,15000,'Electric','Automatic','High performance electric sedan','available',true),
         ($1,'BMW','M8 Competition',2022,136500,22000,'Gasoline','Automatic','Luxury sports coupe','available',true),
         ($1,'Porsche','911 Turbo',2021,184300,18000,'Gasoline','Automatic','Iconic sports performance','available',false)
         ON CONFLICT DO NOTHING`,
        [dealershipId]
      );
    }

    return res.json({
      success: true,
      message: 'Seed completed',
      credentials: {
        admin: { email: 'admin@cardealer.com', password: 'admin123' },
        dealer: { email: 'dealer@cardealer.com', password: 'dealer123' },
        client: { email: 'client@cardealer.com', password: 'client123' },
      },
    });
  } catch (e) {
    return res.status(500).json({ error: 'seed failed', details: e.message });
  }
});

router.post('/reset', async (req, res) => {
  try {
    const auth = isSeedAuthorized(req);
    if (!auth.ok) return res.status(auth.code).json({ error: auth.reason });

    await db.query('BEGIN');

    await db.query('DELETE FROM messages');
    await db.query('DELETE FROM conversations');
    await db.query('DELETE FROM test_drives');
    await db.query('DELETE FROM notifications');
    await db.query('DELETE FROM reviews');
    await db.query('DELETE FROM payments');
    await db.query('DELETE FROM order_items');
    await db.query('DELETE FROM orders');
    await db.query('DELETE FROM favorites');
    await db.query('DELETE FROM car_images');
    await db.query('DELETE FROM cars');
    await db.query('DELETE FROM dealerships');
    await db.query('DELETE FROM users');

    await db.query('COMMIT');

    return res.json({
      success: true,
      message: 'Database content reset. Call POST /seed to reseed data.',
    });
  } catch (e) {
    try {
      await db.query('ROLLBACK');
    } catch (_) {
      // ignore rollback failure
    }
    return res.status(500).json({ error: 'reset failed', details: e.message });
  }
});

module.exports = router;
