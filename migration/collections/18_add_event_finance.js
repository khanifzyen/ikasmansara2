/**
 * Migration: Create Event Finance Collections (Accounts & Transactions)
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateEventFinance() {
    console.log('\n========================================');
    console.log('🎯 Starting Event Finance Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    const eventsId = await getCollectionId(pb, 'events');
    if (!eventsId) {
        throw new Error('❌ Collection "events" not found! Cannot create relation.');
    }

    // 1. Create Event Accounts Collection
    await upsertCollection(pb, {
        name: 'event_accounts',
        type: 'base',
        fields: [
            {
                name: 'event',
                type: 'relation',
                required: true,
                collectionId: eventsId,
                cascadeDelete: true,
                maxSelect: 1,
                displayFields: null
            },
            {
                name: 'name',
                type: 'text',
                required: true,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'type',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['cash', 'bank', 'gateway']
            },
            {
                name: 'balance',
                type: 'number',
                required: false,
                min: null,
                max: null,
                noDecimal: false
            },
            {
                name: 'account_number',
                type: 'text',
                required: false,
                min: null,
                max: null,
                pattern: ""
            }
        ],
        indexes: [
            'CREATE INDEX idx_ev_acc_event ON event_accounts(event)'
        ],
        listRule: null, // Admin only
        viewRule: null, // Admin only
        createRule: null, // Admin only
        updateRule: null, // Admin only
        deleteRule: null  // Admin only
    });

    const eventAccountsId = await getCollectionId(pb, 'event_accounts');

    // 2. Create Event Financial Transactions Collection
    await upsertCollection(pb, {
        name: 'event_financial_transactions',
        type: 'base',
        fields: [
            {
                name: 'event',
                type: 'relation',
                required: true,
                collectionId: eventsId,
                cascadeDelete: true,
                maxSelect: 1,
                displayFields: null
            },
            {
                name: 'type',
                type: 'select',
                required: true,
                maxSelect: 1,
                values: ['income', 'expense', 'transfer']
            },
            {
                name: 'title',
                type: 'text',
                required: true,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'amount',
                type: 'number',
                required: true,
                min: null,
                max: null,
                noDecimal: false
            },
            {
                name: 'date',
                type: 'date',
                required: true,
                min: "",
                max: ""
            },
            {
                name: 'category',
                type: 'text',
                required: false,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'from_account',
                type: 'relation',
                required: false,
                collectionId: eventAccountsId,
                cascadeDelete: false,
                maxSelect: 1,
                displayFields: null
            },
            {
                name: 'to_account',
                type: 'relation',
                required: false,
                collectionId: eventAccountsId,
                cascadeDelete: false,
                maxSelect: 1,
                displayFields: null
            },
            {
                name: 'proof',
                type: 'file',
                required: false,
                maxSelect: 1,
                maxSize: 5242880,
                mimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'],
                thumbs: [],
                protected: false
            },
            {
                name: 'description',
                type: 'text',
                required: false,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'related_ref',
                type: 'text',
                required: false,
                min: null,
                max: null,
                pattern: ""
            }
        ],
        indexes: [
            'CREATE INDEX idx_ev_trx_event ON event_financial_transactions(event)',
            'CREATE INDEX idx_ev_trx_date ON event_financial_transactions(date)'
        ],
        listRule: null, // Admin only
        viewRule: null, // Admin only
        createRule: null, // Admin only
        updateRule: null, // Admin only
        deleteRule: null  // Admin only
    });

    console.log('\n========================================');
    console.log('✅ Event Finance migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateEventFinance().catch(console.error);
}

export { migrateEventFinance };
