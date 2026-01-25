/**
 * IKA SMANSARA - PocketBase Migration Runner
 * 
 * This script runs all collection migrations in order.
 * 
 * Usage:
 *   1. Copy .env.example to .env and fill in your credentials
 *   2. Run: npm install
 *   3. Run: npm run migrate
 */

import { migrateUsers } from './collections/01_users.js';
import { migrateEvents } from './collections/02_events.js';
import { migrateDonations } from './collections/03_donations.js';
import { migrateNews } from './collections/04_news.js';
import { migrateForum } from './collections/05_forum.js';
import { migrateLoker } from './collections/06_loker.js';
import { migrateMarket } from './collections/07_market.js';
import { migrateMemory } from './collections/08_memory.js';

async function runAllMigrations() {
    console.log('🚀 Starting PocketBase migrations...\n');
    console.log('═'.repeat(50));

    try {
        // Run migrations in order (some depend on others)
        console.log('\n📦 [1/8] Migrating Users...');
        await migrateUsers();

        console.log('\n📅 [2/8] Migrating Events...');
        await migrateEvents();

        console.log('\n💰 [3/8] Migrating Donations...');
        await migrateDonations();

        console.log('\n📰 [4/8] Migrating News...');
        await migrateNews();

        console.log('\n💬 [5/8] Migrating Forum...');
        await migrateForum();

        console.log('\n💼 [6/8] Migrating Loker...');
        await migrateLoker();

        console.log('\n🛒 [7/8] Migrating Market...');
        await migrateMarket();

        console.log('\n📷 [8/8] Migrating Memory...');
        await migrateMemory();

        console.log('\n' + '═'.repeat(50));
        console.log('✅ All migrations completed successfully!');
        console.log('═'.repeat(50));

    } catch (error) {
        console.error('\n❌ Migration failed:', error.message);
        process.exit(1);
    }
}

runAllMigrations();
