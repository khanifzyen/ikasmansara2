# IKA SMANSARA - PocketBase Migration

Migration scripts untuk membuat collections di PocketBase.

## Prerequisites

- Node.js 18+
- PocketBase instance yang sudah running
- Admin account di PocketBase

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Copy `.env.example` ke `.env` dan isi credentials:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` dengan kredensial PocketBase Anda:
   ```
   POCKETBASE_URL=http://127.0.0.1:8090
   POCKETBASE_ADMIN_EMAIL=admin@example.com
   POCKETBASE_ADMIN_PASSWORD=your_password
   ```

## Usage

### Run All Migrations
```bash
npm run migrate
```

### Run Individual Migration
```bash
npm run migrate:users
npm run migrate:events
npm run migrate:donations
npm run migrate:news
npm run migrate:forum
npm run migrate:loker
npm run migrate:market
npm run migrate:memory
```

### Seed Database with Dummy Data
```bash
npm run seed
```

### Remove All Seeded Data
```bash
npm run seed:down
```

## Collections Created

| # | Collection | Description |
|---|------------|-------------|
| 1 | users | User accounts (extends PocketBase auth) |
| 2 | events | Event campaigns |
| 3 | event_tickets | Ticket packages per event |
| 4 | event_ticket_options | Ticket options (shirt size, etc) |
| 5 | event_sub_events | Sub-events (health check, etc) |
| 6 | event_sponsors | Sponsor tiers |
| 7 | event_registrations | User registrations |
| 8 | donations | Donation campaigns |
| 9 | donation_transactions | Donation payments |
| 10 | news | News articles |
| 11 | forum_posts | Forum discussions |
| 12 | forum_comments | Post comments |
| 13 | forum_likes | Post likes |
| 14 | loker | Job listings |
| 15 | market | Marketplace products |
| 16 | memories | Photo gallery |

## Troubleshooting

### "Collection already exists"
Migrations akan skip collection yang sudah ada. Jika ingin recreate, hapus dulu via PocketBase Admin UI.

### "Failed to authenticate"
Pastikan:
- PocketBase sudah running
- URL, email, dan password di `.env` sudah benar
- Account adalah superuser/admin
