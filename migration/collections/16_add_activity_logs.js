/**
 * Migration: Create Activity Logs Collection
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateActivityLogs() {
    console.log('\n========================================');
    console.log('🎯 Starting Activity Logs Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    const usersId = await getCollectionId(pb, 'users');
    if (!usersId) {
        throw new Error('❌ Collection "users" not found! Cannot create relation.');
    }

    await upsertCollection(pb, {
        name: 'activity_logs',
        type: 'base',
        fields: [
            {
                name: 'type',
                type: 'text',
                required: true,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'module',
                type: 'text',
                required: true,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'message',
                type: 'text',
                required: true,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'related_id',
                type: 'text',
                required: false,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'related_collection',
                type: 'text',
                required: false,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'actor',
                type: 'relation',
                required: true,
                collectionId: usersId,
                cascadeDelete: false,
                maxSelect: 1,
                displayFields: null
            },
            {
                name: 'is_read',
                type: 'bool',
                required: false
            }
        ],
        indexes: [
            'CREATE INDEX idx_activity_created ON activity_logs(created)'
        ],
        listRule: null, // Admin only
        viewRule: null, // Admin only
        createRule: null, // Disabled (System only)
        updateRule: null, // Disabled (System only)
        deleteRule: null  // Disabled (System only)
    });

    console.log('\n========================================');
    console.log('✅ Activity Logs migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateActivityLogs().catch(console.error);
}

export { migrateActivityLogs };
