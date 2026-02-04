/**
 * Migration: Add Manual Booking Fields to Event Bookings
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateManualBookingFields() {
    console.log('\n========================================');
    console.log('🎯 Starting Add Manual Booking Fields Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    // Get event_tickets ID for relation
    const eventTicketsId = await getCollectionId(pb, 'event_tickets');
    if (!eventTicketsId) {
        throw new Error('❌ Collection "event_tickets" not found! Cannot create relation.');
    }

    await upsertCollection(pb, {
        name: 'event_bookings',
        type: 'base',
        fields: [
            {
                name: 'coordinator_name',
                type: 'text',
                required: false,
                presentable: false,
                unique: false,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'coordinator_phone',
                type: 'text',
                required: false,
                presentable: false,
                unique: false,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'coordinator_angkatan',
                type: 'number',
                required: false,
                presentable: false,
                unique: false,
                min: null,
                max: null,
                noDecimal: true
            },
            {
                name: 'registration_channel',
                type: 'select',
                required: false,
                presentable: false,
                unique: false,
                maxSelect: 1,
                values: ['app', 'manual_cash', 'manual_transfer']
            },
            {
                name: 'manual_ticket_count',
                type: 'number',
                required: false,
                presentable: false,
                unique: false,
                min: null,
                max: null,
                noDecimal: true
            },
            {
                name: 'manual_ticket_type',
                type: 'relation',
                required: false,
                presentable: false,
                unique: false,
                collectionId: eventTicketsId,
                cascadeDelete: false,
                minSelect: null,
                maxSelect: 1,
                displayFields: null
            },
            {
                name: 'payment_proof',
                type: 'file',
                required: false,
                presentable: false,
                unique: false,
                maxSelect: 1,
                maxSize: 5242880,
                mimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'],
                thumbs: [],
                protected: false
            },
            {
                name: 'notes',
                type: 'text',
                required: false,
                presentable: false,
                unique: false,
                min: null,
                max: null,
                pattern: ""
            }
        ]
    });

    console.log('\n========================================');
    console.log('✅ Manual Booking Fields migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateManualBookingFields().catch(console.error);
}

export { migrateManualBookingFields };
