/**
 * Migration: Create Notifications Collection
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateNotifications() {
    console.log('\n========================================');
    console.log('🎯 Starting Notifications Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    const usersId = await getCollectionId(pb, 'users');
    if (!usersId) {
        throw new Error('❌ Collection "users" not found! Cannot create relation.');
    }

    await upsertCollection(pb, {
        name: 'notifications',
        type: 'base',
        fields: [
            {
                name: 'user',
                type: 'relation',
                required: true,
                collectionId: usersId,
                cascadeDelete: true,
                maxSelect: 1,
                displayFields: null
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
                name: 'message',
                type: 'text',
                required: true,
                min: null,
                max: null,
                pattern: ""
            },
            {
                name: 'type',
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
                name: 'is_read',
                type: 'bool',
                required: false
            },
            {
                name: 'action_url',
                type: 'text',
                required: false,
                min: null,
                max: null,
                pattern: ""
            }
        ],
        indexes: [
            'CREATE INDEX idx_notif_user ON notifications(user)',
            'CREATE INDEX idx_notif_read ON notifications(is_read)'
        ],
        listRule: 'user = @request.auth.id',
        viewRule: 'user = @request.auth.id',
        createRule: null, // Disabled (System only)
        updateRule: 'user = @request.auth.id', // Only update (mark as read) allowed
        deleteRule: null  // Disabled (System only)
    });

    console.log('\n========================================');
    console.log('✅ Notifications migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateNotifications().catch(console.error);
}

export { migrateNotifications };
