/**
 * Migration: Add Manual Booking Fields to Event Bookings
 */

import { authenticateAdmin, upsertCollection } from '../pb-client.js';

async function migrateManualBookingFields() {
    console.log('\n========================================');
    console.log('🎯 Starting Add Manual Booking Fields Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

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
                options: {
                    min: null,
                    max: null,
                    pattern: ""
                }
            },
            {
                name: 'coordinator_phone',
                type: 'text',
                required: false,
                presentable: false,
                unique: false,
                options: {
                    min: null,
                    max: null,
                    pattern: ""
                }
            },
            {
                name: 'manual_ticket_count',
                type: 'number',
                required: false,
                presentable: false,
                unique: false,
                options: {
                    min: null,
                    max: null,
                    noDecimal: true
                }
            },
            {
                name: 'manual_ticket_type',
                type: 'relation',
                required: false,
                presentable: false,
                unique: false,
                options: {
                    collectionId: 'event_tickets',
                    cascadeDelete: false,
                    minSelect: null,
                    maxSelect: 1,
                    displayFields: null
                }
            },
            {
                name: 'notes',
                type: 'text',
                required: false,
                presentable: false,
                unique: false,
                options: {
                    min: null,
                    max: null,
                    pattern: ""
                }
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
