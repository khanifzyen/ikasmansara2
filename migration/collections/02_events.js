/**
 * Migration: Events & Related Collections
 * - events
 * - event_tickets
 * - event_ticket_options
 * - event_sub_events
 * - event_sponsors
 * - event_registrations
 */

import { authenticateAdmin, createCollection, getCollectionId } from '../pb-client.js';

async function migrateEvents() {
    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    // 1. Events Collection
    await createCollection(pb, {
        name: 'events',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            { name: 'title', type: 'text', required: true },
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
                maxSelect: 1
            },
            { name: 'booking_id_format', type: 'text', required: true },
            { name: 'ticket_id_format', type: 'text', required: true },
            { name: 'last_booking_seq', type: 'number', required: false }
        ]
    });

    const eventsId = await getCollectionId(pb, 'events');

    // 2. Event Tickets Collection
    await createCollection(pb, {
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
        ]
    });

    const ticketsId = await getCollectionId(pb, 'event_tickets');

    // 3. Event Ticket Options Collection
    await createCollection(pb, {
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
    await createCollection(pb, {
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
        ]
    });

    const subEventsId = await getCollectionId(pb, 'event_sub_events');

    // 5. Event Sponsors Collection
    await createCollection(pb, {
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

    // 6. Event Registrations Collection
    await createCollection(pb, {
        name: 'event_registrations',
        type: 'base',
        listRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        viewRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        createRule: '@request.auth.id != ""',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            {
                name: 'event',
                type: 'relation',
                required: true,
                collectionId: eventsId,
                maxSelect: 1
            },
            {
                name: 'ticket',
                type: 'relation',
                required: true,
                collectionId: ticketsId,
                maxSelect: 1
            },
            {
                name: 'user',
                type: 'relation',
                required: true,
                collectionId: usersId,
                maxSelect: 1
            },
            { name: 'ticket_code', type: 'text', required: true },
            { name: 'selected_options', type: 'json', required: false },
            {
                name: 'sub_events',
                type: 'relation',
                required: false,
                collectionId: subEventsId,
                maxSelect: 999
            },
            { name: 'total_price', type: 'number', required: true, min: 0 },
            {
                name: 'payment_status',
                type: 'select',
                required: true,
                values: ['pending', 'paid', 'expired', 'refunded']
            },
            { name: 'payment_method', type: 'text', required: false },
            { name: 'payment_date', type: 'date', required: false },
            { name: 'shirt_picked_up', type: 'bool', required: false },
            { name: 'shirt_pickup_time', type: 'date', required: false },
            { name: 'checked_in', type: 'bool', required: false },
            { name: 'checkin_time', type: 'date', required: false }
        ],
        indexes: [
            'CREATE UNIQUE INDEX idx_ticket_code ON event_registrations (ticket_code)',
            'CREATE INDEX idx_reg_user ON event_registrations (user)',
            'CREATE INDEX idx_reg_event ON event_registrations (event)'
        ]
    });

    console.log('✅ All event collections created successfully');
}

migrateEvents().catch(console.error);

export { migrateEvents };
