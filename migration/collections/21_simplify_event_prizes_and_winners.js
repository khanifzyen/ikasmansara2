import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function simplifyEventPrizes() {
    console.log('\n========================================');
    console.log('🔄 Simplifying Event Prizes and Winners...');
    console.log('========================================');

    const adminPb = await authenticateAdmin();
    const eventsId = await getCollectionId(adminPb, 'events');
    const bookingTicketsId = await getCollectionId(adminPb, 'event_booking_tickets');

    if (!eventsId || !bookingTicketsId) {
        console.error('❌ Required collections not found.');
        process.exit(1);
    }

    // 1. Update/Create event_winners
    await upsertCollection(adminPb, {
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
                name: 'prize_name',
                type: 'text',
                required: true
            },
            {
                name: 'booking_ticket',
                type: 'relation',
                required: true,
                collectionId: bookingTicketsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            {
                name: 'status',
                type: 'select',
                required: true,
                values: ['won', 'disqualified'],
                maxSelect: 1
            }
        ],
        indexes: [
            'CREATE INDEX idx_winners_event ON event_winners (event)',
            'CREATE UNIQUE INDEX idx_winners_ticket ON event_winners (booking_ticket)'
        ]
    });

    console.log('\n========================================');
    console.log('✅ Event Prizes and Winners simplified!');
    console.log('Note: To fully clean up, you may manually delete the `event_prizes` collection if it exists.');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    simplifyEventPrizes().catch(console.error);
}

export { simplifyEventPrizes };
