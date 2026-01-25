/**
 * Migration: Memories (Photo Gallery) Collection
 */

import { authenticateAdmin, createCollection, getCollectionId } from '../pb-client.js';

async function migrateMemory() {
    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    await createCollection(pb, {
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

    console.log('✅ Memories collection created successfully');
}

migrateMemory().catch(console.error);

export { migrateMemory };
