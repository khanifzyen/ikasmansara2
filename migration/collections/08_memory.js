/**
 * Migration: Memories (Photo Gallery) Collection
 * Based on SKEMA.md
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateMemory() {
    console.log('\n========================================');
    console.log('🎯 Starting Memories Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    if (!usersId) {
        console.error('❌ Users collection not found. Run 01_users.js first.');
        process.exit(1);
    }

    await upsertCollection(pb, {
        name: 'memories',
        type: 'base',
        listRule: 'is_approved = true',
        viewRule: 'is_approved = true || @request.auth.id = user.id || @request.auth.role = "admin"',
        createRule: '@request.auth.role = "alumni"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        fields: [
            {
                name: 'user',
                type: 'relation',
                required: true,
                collectionId: usersId,
                maxSelect: 1
            },
            { name: 'image', type: 'file', required: true, maxSelect: 1, maxSize: 10485760 },
            { name: 'year', type: 'number', required: true, min: 1900, max: 2100 },
            { name: 'description', type: 'text', required: false },
            { name: 'is_approved', type: 'bool', required: false },
            {
                name: 'approved_by',
                type: 'relation',
                required: false,
                collectionId: usersId,
                maxSelect: 1
            }
        ],
        indexes: [
            'CREATE INDEX idx_memory_year ON memories (year)',
            'CREATE INDEX idx_memory_approved ON memories (is_approved)'
        ]
    });

    console.log('\n========================================');
    console.log('✅ Memories migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateMemory().catch(console.error);
}

export { migrateMemory };
