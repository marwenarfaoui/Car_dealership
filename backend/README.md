# Backend Setup (Node.js + PostgreSQL)

## 1) Install dependencies
In this folder (`backend`):

npm install

## 2) Configure environment
Copy or edit `.env`:

- `PORT=3000`
- `DATABASE_URL=postgres://postgres:postgres@localhost:5432/car_dealership`
- `JWT_SECRET=change_me_to_a_strong_secret`

## 3) Create database schema
Run SQL file:

- `backend/sql/postgres_schema.sql`

## 4) Start backend

npm run dev

Server base URL:

http://localhost:3000

## 5) Important API routes

- `GET /health`
- `POST /auth/register`
- `POST /auth/login`
- `GET /cars`
- `POST /cars` (admin/dealer token)
- `PATCH /cars/:id` (admin/dealer token)
- `DELETE /cars/:id` (admin/dealer token)
- `GET /users` (admin token)
- `PATCH /users/:id/role` (admin token)
- `DELETE /users/:id` (admin token)

## 7) Seed API (quick bootstrap)

Endpoint:

- `POST /seed`
- `POST /seed/reset`

Auth for seed:

- Header: `x-seed-key: <SEED_API_KEY>`

Example (PowerShell):

`Invoke-WebRequest -Method POST -Uri "http://localhost:3000/seed" -Headers @{"x-seed-key"="seed_my_app_2026"}`

Reset example (PowerShell):

`Invoke-WebRequest -Method POST -Uri "http://localhost:3000/seed/reset" -Headers @{"x-seed-key"="seed_my_app_2026"}`

Seeded users:

- admin: `admin@cardealer.com / admin123`
- dealer: `dealer@cardealer.com / dealer123`
- client: `client@cardealer.com / client123`

## 6) Run Flutter with backend URL
From project root:

flutter run --dart-define=API_BASE_URL=http://localhost:3000
