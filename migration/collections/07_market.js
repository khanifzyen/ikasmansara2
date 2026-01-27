/**
 * Migration: Market (Marketplace) Collection
 * Based on SKEMA.md
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateMarket() {
    console.log('\n========================================');
    console.log('🎯 Starting Market Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    if (!usersId) {
        console.error('❌ Users collection not found. Run 01_users.js first.');
        process.exit(1);
    }

    await upsertCollection(pb, {
        name: 'market',
        type: 'base',
        listRule: 'status = "approved"',
        viewRule: 'status = "approved" || @request.auth.id = user.id || @request.auth.role = "admin"',
        createRule: '@request.auth.role = "alumni"',
        updateRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        deleteRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        fields: [
            {
                name: 'user',
                type: 'relation',
                required: true,
                collectionId: usersId,
                maxSelect: 1
            },
            { name: 'name', type: 'text', required: true },
            {
                name: 'category',
                type: 'select',
                required: true,
                values: ['kuliner', 'fashion', 'jasa_professional', 'properti', 'lainnya']
            },
            { name: 'price', type: 'number', required: true, min: 0 },
            { name: 'description', type: 'editor', required: false },
            { name: 'images', type: 'file', maxSelect: 5, maxSize: 5242880 },
            { name: 'location', type: 'text', required: true },
            { name: 'contact', type: 'text', required: false },
            {
                name: 'status',
                type: 'select',
                required: true,
                values: ['pending', 'approved', 'rejected', 'sold']
            }
        ],
        indexes: [
            'CREATE INDEX idx_market_status ON market (status)',
            'CREATE INDEX idx_market_user ON market (user)',
            'CREATE INDEX idx_market_category ON market (category)'
        ]
    });

    console.log('\n========================================');
    console.log('✅ Market migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateMarket().catch(console.error);
}

export { migrateMarket };
