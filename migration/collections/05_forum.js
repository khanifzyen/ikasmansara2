/**
 * Migration: Forum Collections
 * - forum_posts
 * - forum_comments
 * - forum_likes
 */

import { authenticateAdmin, createCollection, getCollectionId } from '../pb-client.js';

async function migrateForum() {
    const pb = await authenticateAdmin();
    const usersId = await getCollectionId(pb, 'users');

    // 1. Forum Posts Collection
    await createCollection(pb, {
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
    await createCollection(pb, {
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
            { name: 'content', type: 'text', required: true },
            {
                name: 'parent',
                type: 'relation',
                required: false,
                collectionId: '_pbc_forum_comments', // self-reference placeholder
                maxSelect: 1
            }
        ]
    });

    // 3. Forum Likes Collection
    await createCollection(pb, {
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

    console.log('✅ Forum collections created successfully');
}

migrateForum().catch(console.error);

export { migrateForum };
