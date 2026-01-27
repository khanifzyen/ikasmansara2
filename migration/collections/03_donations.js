/**
 * Migration: Donations & Donation Transactions
 * Based on SKEMA.md
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateDonations() {
    console.log('\n========================================');
    console.log('🎯 Starting Donations Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');
    const eventsId = await getCollectionId(pb, 'events');

    if (!usersId) {
        console.error('❌ Users collection not found. Run 01_users.js first.');
        process.exit(1);
    }

    // 1. Donations (Campaigns) Collection
    await upsertCollection(pb, {
        name: 'donations',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            { name: 'title', type: 'text', required: true },
            { name: 'description', type: 'editor', required: true },
            { name: 'target_amount', type: 'number', required: true, min: 0 },
            { name: 'collected_amount', type: 'number', required: false, min: 0 },
            { name: 'deadline', type: 'date', required: true },
            { name: 'banner', type: 'file', maxSelect: 1, maxSize: 5242880 },
            { name: 'organizer', type: 'text', required: true },
            {
                name: 'category',
                type: 'select',
                required: true,
                values: ['infrastruktur', 'pendidikan', 'sosial', 'kesehatan', 'lainnya']
            },
            {
                name: 'priority',
                type: 'select',
                required: true,
                values: ['normal', 'urgent']
            },
            {
                name: 'status',
                type: 'select',
                required: true,
                values: ['draft', 'active', 'completed', 'closed']
            },
            { name: 'donor_count', type: 'number', required: false, min: 0 },
            {
                name: 'created_by',
                type: 'relation',
                required: true,
                collectionId: usersId,
                maxSelect: 1
            }
        ],
        indexes: [
            'CREATE INDEX idx_donations_status ON donations (status)',
            'CREATE INDEX idx_donations_category ON donations (category)'
        ]
    });

    const donationsId = await getCollectionId(pb, 'donations');

    // 2. Donation Transactions Collection
    const transactionFields = [
        { name: 'donor_name', type: 'text', required: true },
        { name: 'amount', type: 'number', required: true, min: 1000 },
        { name: 'message', type: 'text', required: false },
        { name: 'is_anonymous', type: 'bool', required: false },
        {
            name: 'payment_status',
            type: 'select',
            required: true,
            values: ['pending', 'success', 'failed']
        },
        { name: 'payment_method', type: 'text', required: false },
        { name: 'transaction_id', type: 'text', required: true }
    ];

    // Add relation fields if collections exist
    if (donationsId) {
        transactionFields.unshift({
            name: 'donation',
            type: 'relation',
            required: false,
            collectionId: donationsId,
            maxSelect: 1
        });
    }

    if (eventsId) {
        transactionFields.splice(1, 0, {
            name: 'event',
            type: 'relation',
            required: false,
            collectionId: eventsId,
            maxSelect: 1
        });
    }

    if (usersId) {
        transactionFields.splice(2, 0, {
            name: 'user',
            type: 'relation',
            required: false,
            collectionId: usersId,
            maxSelect: 1
        });
    }

    await upsertCollection(pb, {
        name: 'donation_transactions',
        type: 'base',
        listRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        viewRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        createRule: '',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: transactionFields,
        indexes: [
            'CREATE UNIQUE INDEX idx_trx_id ON donation_transactions (transaction_id)',
            'CREATE INDEX idx_donation_trx ON donation_transactions (donation)',
            'CREATE INDEX idx_event_trx ON donation_transactions (event)',
            'CREATE INDEX idx_donation_status ON donation_transactions (payment_status)'
        ]
    });

    console.log('\n========================================');
    console.log('✅ Donations migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateDonations().catch(console.error);
}

export { migrateDonations };
