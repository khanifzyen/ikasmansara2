/**
 * Migration: Events & Related Collections
 * Based on SKEMA.md - Updated structure with bookings/tickets
 * 
 * Collections:
 * - events
 * - event_tickets
 * - event_ticket_options
 * - event_sub_events
 * - event_sponsors
 * - event_bookings (NEW)
 * - event_booking_tickets (NEW)
 * - event_sub_event_registrations (NEW)
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateEvents() {
    console.log('\n========================================');
    console.log('🎯 Starting Events Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    if (!usersId) {
        console.error('❌ Users collection not found. Run 01_users.js first.');
        process.exit(1);
    }

    // 1. Events Collection
    await upsertCollection(pb, {
        name: 'events',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            { name: 'title', type: 'text', required: true },
            { name: 'code', type: 'text', required: true }, // NEW: Event code prefix
            { name: 'date', type: 'date', required: true },
            { name: 'time', type: 'text', required: true },
            { name: 'location', type: 'text', required: true },
            { name: 'description', type: 'editor', required: false },
            { name: 'banner', type: 'file', maxSelect: 1, maxSize: 5242880 },
            {
                name: 'status',
                type: 'select',
                required: true,
                values: ['draft', 'active', 'completed']
            },
            { name: 'enable_sponsorship', type: 'bool', required: false },
            { name: 'enable_donation', type: 'bool', required: false },
            { name: 'donation_target', type: 'number', required: false },
            { name: 'donation_description', type: 'text', required: false },
            {
                name: 'created_by',
                type: 'relation',
                collectionId: usersId,
                maxSelect: 1,
                required: true
            },
            { name: 'booking_id_format', type: 'text', required: true },
            { name: 'ticket_id_format', type: 'text', required: true },
            { name: 'last_booking_seq', type: 'number', required: false, min: 0 },
            { name: 'last_ticket_seq', type: 'number', required: false, min: 0 } // NEW
        ],
        indexes: [
            'CREATE INDEX idx_events_status ON events (status)',
            'CREATE UNIQUE INDEX idx_events_code ON events (code)'
        ]
    });

    const eventsId = await getCollectionId(pb, 'events');

    // 2. Event Tickets Collection (Ticket Types)
    await upsertCollection(pb, {
        name: 'event_tickets',
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
            { name: 'price', type: 'number', required: true, min: 0 },
            { name: 'quota', type: 'number', required: true, min: 0 },
            { name: 'sold', type: 'number', required: false, min: 0 },
            { name: 'includes', type: 'json', required: false },
            { name: 'image', type: 'file', maxSelect: 1, maxSize: 5242880 }
        ],
        indexes: [
            'CREATE INDEX idx_tickets_event ON event_tickets (event)'
        ]
    });

    const ticketsId = await getCollectionId(pb, 'event_tickets');

    // 3. Event Ticket Options Collection
    await upsertCollection(pb, {
        name: 'event_ticket_options',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            {
                name: 'ticket',
                type: 'relation',
                required: true,
                collectionId: ticketsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            { name: 'name', type: 'text', required: true },
            { name: 'choices', type: 'json', required: true }
        ]
    });

    // 4. Event Sub-Events Collection
    await upsertCollection(pb, {
        name: 'event_sub_events',
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
            { name: 'description', type: 'text', required: false },
            { name: 'quota', type: 'number', required: false },
            { name: 'registered', type: 'number', required: false, min: 0 },
            { name: 'location', type: 'text', required: false }
        ],
        indexes: [
            'CREATE INDEX idx_subevents_event ON event_sub_events (event)'
        ]
    });

    const subEventsId = await getCollectionId(pb, 'event_sub_events');

    // 5. Event Sponsors Collection
    await upsertCollection(pb, {
        name: 'event_sponsors',
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
            { name: 'tier_name', type: 'text', required: true },
            { name: 'price', type: 'number', required: true, min: 0 },
            { name: 'benefits', type: 'json', required: true },
            { name: 'logo', type: 'file', maxSelect: 1, maxSize: 5242880 },
            { name: 'company_name', type: 'text', required: false },
            { name: 'is_filled', type: 'bool', required: false }
        ]
    });

    // 6. Event Bookings Collection (NEW - Order/Invoice level)
    await upsertCollection(pb, {
        name: 'event_bookings',
        type: 'base',
        listRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        viewRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        createRule: '@request.auth.id != ""',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            { name: 'booking_id', type: 'text', required: true }, // e.g., REUNI26-2026-0001
            {
                name: 'event',
                type: 'relation',
                required: true,
                collectionId: eventsId,
                maxSelect: 1
            },
            {
                name: 'user',
                type: 'relation',
                required: true,
                collectionId: usersId,
                maxSelect: 1
            },
            {
                name: 'ticket_type',
                type: 'relation',
                required: true,
                collectionId: ticketsId,
                maxSelect: 1
            },
            { name: 'quantity', type: 'number', required: true, min: 1 },
            { name: 'total_price', type: 'number', required: true, min: 0 },
            {
                name: 'payment_status',
                type: 'select',
                required: true,
                values: ['pending', 'paid', 'expired', 'refunded']
            },
            { name: 'payment_method', type: 'text', required: false },
            { name: 'payment_date', type: 'date', required: false }
        ],
        indexes: [
            'CREATE UNIQUE INDEX idx_booking_id ON event_bookings (booking_id)',
            'CREATE INDEX idx_booking_user ON event_bookings (user)',
            'CREATE INDEX idx_booking_event ON event_bookings (event)',
            'CREATE INDEX idx_booking_status ON event_bookings (payment_status)'
        ]
    });

    const bookingsId = await getCollectionId(pb, 'event_bookings');

    // 7. Event Booking Tickets Collection (NEW - Individual tickets)
    await upsertCollection(pb, {
        name: 'event_booking_tickets',
        type: 'base',
        listRule: '@request.auth.id = booking.user.id || @request.auth.role = "admin"',
        viewRule: '@request.auth.id = booking.user.id || @request.auth.role = "admin"',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            { name: 'ticket_id', type: 'text', required: true }, // e.g., TIX-REUNI26-001
            {
                name: 'booking',
                type: 'relation',
                required: true,
                collectionId: bookingsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            { name: 'selected_options', type: 'json', required: false },
            { name: 'shirt_picked_up', type: 'bool', required: false },
            { name: 'shirt_pickup_time', type: 'date', required: false },
            { name: 'checked_in', type: 'bool', required: false },
            { name: 'checkin_time', type: 'date', required: false }
        ],
        indexes: [
            'CREATE UNIQUE INDEX idx_ticket_id ON event_booking_tickets (ticket_id)',
            'CREATE INDEX idx_ticket_booking ON event_booking_tickets (booking)'
        ]
    });

    const bookingTicketsId = await getCollectionId(pb, 'event_booking_tickets');

    // 8. Event Sub-Event Registrations Collection (NEW)
    await upsertCollection(pb, {
        name: 'event_sub_event_registrations',
        type: 'base',
        listRule: '@request.auth.id = booking_ticket.booking.user.id || @request.auth.role = "admin"',
        viewRule: '@request.auth.id = booking_ticket.booking.user.id || @request.auth.role = "admin"',
        createRule: '@request.auth.id != ""',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            { name: 'sub_event_ticket_id', type: 'text', required: true }, // e.g., REUNI26-CEK-001
            {
                name: 'booking_ticket',
                type: 'relation',
                required: true,
                collectionId: bookingTicketsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            {
                name: 'sub_event',
                type: 'relation',
                required: true,
                collectionId: subEventsId,
                maxSelect: 1
            },
            { name: 'checked_in', type: 'bool', required: false },
            { name: 'checkin_time', type: 'date', required: false }
        ],
        indexes: [
            'CREATE UNIQUE INDEX idx_subevent_ticket_id ON event_sub_event_registrations (sub_event_ticket_id)',
            'CREATE INDEX idx_subevent_reg_ticket ON event_sub_event_registrations (booking_ticket)',
            'CREATE INDEX idx_subevent_reg_subevent ON event_sub_event_registrations (sub_event)'
        ]
    });

    console.log('\n========================================');
    console.log('✅ Events migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateEvents().catch(console.error);
}

export { migrateEvents };
