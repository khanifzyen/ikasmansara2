/**
 * Migration: Add Snap Payment Fields
 * 
 * Target Collections:
 * - event_bookings
 * - donation_transactions
 * 
 * Added Fields:
 * - snap_token (text)
 * - snap_redirect_url (text)
 */

import { authenticateAdmin, upsertCollection } from '../pb-client.js';

async function migrateSnapFields() {
    console.log('\n========================================');
    console.log('⚡ Starting Snap Fields Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    // 1. Update event_bookings
    await upsertCollection(pb, {
        name: 'event_bookings',
        fields: [
            { name: 'snap_token', type: 'text', required: false },
            { name: 'snap_redirect_url', type: 'text', required: false }
        ]
    });

    // 2. Update donation_transactions
    await upsertCollection(pb, {
        name: 'donation_transactions',
        fields: [
            { name: 'snap_token', type: 'text', required: false },
            { name: 'snap_redirect_url', type: 'text', required: false }
        ]
    });

    console.log('\n========================================');
    console.log('✅ Snap Fields Migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateSnapFields().catch(console.error);
}

export { migrateSnapFields };
