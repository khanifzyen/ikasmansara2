/**
 * Migration: Forum Collections
 * Based on SKEMA.md
 * - forum_posts
 * - forum_comments
 * - forum_likes
 */

import { authenticateAdmin, upsertCollection, getCollectionId, getCollection } from '../pb-client.js';

async function migrateForum() {
    console.log('\n========================================');
    console.log('🎯 Starting Forum Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    if (!usersId) {
        console.error('❌ Users collection not found. Run 01_users.js first.');
        process.exit(1);
    }

    // 1. Forum Posts Collection
    await upsertCollection(pb, {
        name: 'forum_posts',
        type: 'base',
        listRule: 'status = "active" && (visibility = "public" || @request.auth.role = "alumni")',
        viewRule: 'status = "active" && (visibility = "public" || @request.auth.role = "alumni")',
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
            { name: 'content', type: 'text', required: true },
            { name: 'image', type: 'file', maxSelect: 1, maxSize: 5242880 },
            {
                name: 'category',
                type: 'select',
                required: true,
                values: ['karir_loker', 'nostalgia', 'bisnis', 'umum']
            },
            {
                name: 'visibility',
                type: 'select',
                required: true,
                values: ['public', 'alumni_only']
            },
            { name: 'like_count', type: 'number', required: false, min: 0 },
            { name: 'comment_count', type: 'number', required: false, min: 0 },
            { name: 'is_pinned', type: 'bool', required: false },
            {
                name: 'status',
                type: 'select',
                required: true,
                values: ['active', 'hidden', 'deleted']
            }
        ],
        indexes: [
            'CREATE INDEX idx_forum_category ON forum_posts (category)',
            'CREATE INDEX idx_forum_user ON forum_posts (user)',
            'CREATE INDEX idx_forum_status ON forum_posts (status)'
        ]
    });

    const postsId = await getCollectionId(pb, 'forum_posts');

    // 2. Forum Comments Collection
    await upsertCollection(pb, {
        name: 'forum_comments',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.id != ""',
        updateRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        deleteRule: '@request.auth.id = user.id || @request.auth.role = "admin"',
        fields: [
            {
                name: 'post',
                type: 'relation',
                required: true,
                collectionId: postsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            {
                name: 'user',
                type: 'relation',
                required: true,
                collectionId: usersId,
                maxSelect: 1
            },
            { name: 'content', type: 'text', required: true }
        ]
    });

    // Add self-reference for parent comment (for replies)
    const commentsId = await getCollectionId(pb, 'forum_comments');
    if (commentsId) {
        const commentsCollection = await getCollection(pb, 'forum_comments');
        const hasParent = commentsCollection.fields?.some(f => f.name === 'parent');

        if (!hasParent) {
            console.log(`   ➕ Adding parent self-reference to forum_comments...`);
            try {
                await pb.collections.update('forum_comments', {
                    fields: [
                        ...commentsCollection.fields,
                        {
                            name: 'parent',
                            type: 'relation',
                            required: false,
                            collectionId: commentsId,
                            maxSelect: 1
                        }
                    ]
                });
                console.log(`   ✅ Added parent field to forum_comments`);
            } catch (error) {
                console.log(`   ⚠️  Could not add parent field: ${error.message}`);
            }
        }
    }

    // 3. Forum Likes Collection
    await upsertCollection(pb, {
        name: 'forum_likes',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.id != ""',
        updateRule: null,
        deleteRule: '@request.auth.id = user.id',
        fields: [
            {
                name: 'post',
                type: 'relation',
                required: true,
                collectionId: postsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            {
                name: 'user',
                type: 'relation',
                required: true,
                collectionId: usersId,
                maxSelect: 1
            }
        ],
        indexes: [
            'CREATE UNIQUE INDEX idx_like_unique ON forum_likes (post, user)'
        ]
    });

    console.log('\n========================================');
    console.log('✅ Forum migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateForum().catch(console.error);
}

export { migrateForum };
