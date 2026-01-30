/**
 * Migration: Fix Event Bookings API Rules
 * 
 * Update 'event_bookings' rules to allow users to update their own bookings (e.g. for cancellation).
 */

import { authenticateAdmin, upsertCollection } from '../pb-client.js';

async function migrateBookingRules() {
    console.log('\n========================================');
    console.log('🛡️  Fixing Event Bookings API Rules...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    try {
        const collection = await pb.collections.getOne('event_bookings');

        await pb.collections.update(collection.id, {
            // Allow users to update their own records (e.g. to set status to cancelled)
            updateRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
            // Allow users to delete their own records (optional, but good for cleanup of pending/failed)
            deleteRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        });

        console.log(`   ✅ Updated API Rules for event_bookings:`);
        console.log(`      updateRule: @request.auth.id = user.id || @request.auth.role = "admin"`);
        console.log(`      deleteRule: @request.auth.id = user.id || @request.auth.role = "admin"`);

    } catch (err) {
        console.error(`   ❌ Failed to update rules: ${err.message}`);
    }

    console.log('\n========================================');
    console.log('✅ Rule Migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateBookingRules().catch(console.error);
}

export { migrateBookingRules };
