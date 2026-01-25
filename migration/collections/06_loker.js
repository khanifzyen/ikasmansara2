/**
 * Migration: Loker (Job Listings) Collection
 */

import { authenticateAdmin, createCollection, getCollectionId } from '../pb-client.js';

async function migrateLoker() {
    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    await createCollection(pb, {
        name: 'loker',
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
            { name: 'position', type: 'text', required: true },
            { name: 'company', type: 'text', required: true },
            {
                name: 'job_type',
                type: 'select',
                required: true,
                values: ['fulltime', 'parttime', 'internship', 'freelance', 'remote']
            },
            { name: 'location', type: 'text', required: true },
            { name: 'salary_range', type: 'text', required: false },
            { name: 'description', type: 'editor', required: true },
            { name: 'apply_link', type: 'text', required: true },
            {
                name: 'status',
                type: 'select',
                required: true,
                values: ['pending', 'approved', 'rejected', 'closed']
            },
            { name: 'expires_at', type: 'date', required: false }
        ],
        indexes: [
            'CREATE INDEX idx_loker_status ON loker (status)',
            'CREATE INDEX idx_loker_user ON loker (user)',
            'CREATE INDEX idx_loker_job_type ON loker (job_type)'
        ]
    });

    console.log('✅ Loker collection created successfully');
}

migrateLoker().catch(console.error);

export { migrateLoker };
