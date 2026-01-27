/**
 * Migration: News Collection
 * Based on SKEMA.md
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateNews() {
    console.log('\n========================================');
    console.log('🎯 Starting News Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    if (!usersId) {
        console.error('❌ Users collection not found. Run 01_users.js first.');
        process.exit(1);
    }

    await upsertCollection(pb, {
        name: 'news',
        type: 'base',
        listRule: 'status = "published"',
        viewRule: 'status = "published" || @request.auth.role = "admin"',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            { name: 'title', type: 'text', required: true },
            { name: 'slug', type: 'text', required: true },
            {
                name: 'category',
                type: 'select',
                required: true,
                values: ['prestasi', 'kegiatan', 'pengumuman', 'alumni_sukses', 'lainnya']
            },
            { name: 'thumbnail', type: 'file', maxSelect: 1, maxSize: 5242880 },
            { name: 'summary', type: 'text', required: true },
            { name: 'content', type: 'editor', required: true },
            {
                name: 'author',
                type: 'relation',
                required: true,
                collectionId: usersId,
                maxSelect: 1
            },
            { name: 'publish_date', type: 'date', required: true },
            {
                name: 'status',
                type: 'select',
                required: true,
                values: ['draft', 'published']
            },
            { name: 'view_count', type: 'number', required: false, min: 0 }
        ],
        indexes: [
            'CREATE UNIQUE INDEX idx_news_slug ON news (slug)',
            'CREATE INDEX idx_news_status ON news (status)',
            'CREATE INDEX idx_news_category ON news (category)'
        ]
    });

    console.log('\n========================================');
    console.log('✅ News migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateNews().catch(console.error);
}

export { migrateNews };
