/**
 * Migration: Event Prizes and Winners
 * 
 * Collections:
 * - event_prizes (NEW)
 * - event_winners (NEW)
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateEventDoorprizes() {
    console.log('\n========================================');
    console.log('🎁 Starting Event Doorprizes Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();
    const eventsId = await getCollectionId(pb, 'events');
    const bookingTicketsId = await getCollectionId(pb, 'event_booking_tickets');

    if (!eventsId || !bookingTicketsId) {
        console.error('❌ Required collections (events, event_booking_tickets) not found. Run previous migrations first.');
        process.exit(1);
    }

    // 1. Event Prizes Collection
    await upsertCollection(pb, {
        name: 'event_prizes',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            {
                name: 'event',
                type: 'relation',
                required: true,
                collectionId: eventsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            { name: 'name', type: 'text', required: true },
            { name: 'quantity', type: 'number', required: true, min: 1 },
            { name: 'image', type: 'file', required: false, maxSelect: 1, maxSize: 5242880 }
        ],
        indexes: [
            'CREATE INDEX idx_prizes_event ON event_prizes (event)'
        ]
    });

    const prizesId = await getCollectionId(pb, 'event_prizes');

    // 2. Event Winners Collection
    await upsertCollection(pb, {
        name: 'event_winners',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            {
                name: 'event',
                type: 'relation',
                required: true,
                collectionId: eventsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            {
                name: 'prize',
                type: 'relation',
                required: true,
                collectionId: prizesId,
                maxSelect: 1,
                cascadeDelete: true
            },
            {
                name: 'booking_ticket',
                type: 'relation',
                required: true,
                collectionId: bookingTicketsId,
                maxSelect: 1,
                cascadeDelete: true
            }
        ],
        indexes: [
            'CREATE INDEX idx_winners_event ON event_winners (event)',
            'CREATE UNIQUE INDEX idx_winners_ticket ON event_winners (booking_ticket)' // Ensure 1 ticket wins only once
        ]
    });

    console.log('\n========================================');
    console.log('✅ Event Doorprizes migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateEventDoorprizes().catch(console.error);
}

export { migrateEventDoorprizes };
