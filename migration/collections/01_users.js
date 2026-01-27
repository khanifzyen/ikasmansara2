/**
 * Migration: Users Collection (extends PocketBase Auth)
 * Based on SKEMA.md
 * 
 * Note: PocketBase already has a built-in 'users' auth collection.
 * This script updates it with additional custom fields using upsert logic.
 */

import { authenticateAdmin, getCollection } from '../pb-client.js';

async function migrateUsers() {
    console.log('\n========================================');
    console.log('🎯 Starting Users Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    // Get existing users collection
    const existing = await getCollection(pb, 'users');

    if (!existing) {
        console.error('❌ Users collection not found. PocketBase should have this by default.');
        process.exit(1);
    }

    console.log(`\n🔍 Checking collection: users...`);
    console.log(`   📦 Collection "users" exists. Checking fields...`);

    // Define required custom fields
    const customFields = [
        { name: 'name', type: 'text', required: true },
        { name: 'phone', type: 'text', required: false },
        { name: 'avatar', type: 'file', maxSelect: 1, maxSize: 5242880 },
        { name: 'angkatan', type: 'number', required: false, min: 1900, max: 2100 },
        { name: 'no_urut_angkatan', type: 'number', required: false },
        { name: 'no_urut_global', type: 'number', required: false },
        {
            name: 'role',
            type: 'select',
            required: true,
            values: ['alumni', 'public', 'admin']
        },
        {
            name: 'job_status',
            type: 'select',
            required: false,
            values: ['swasta', 'pns_bumn', 'wirausaha', 'mahasiswa', 'lainnya']
        },
        { name: 'company', type: 'text', required: false },
        { name: 'domisili', type: 'text', required: false },
        { name: 'is_verified', type: 'bool', required: false },
        { name: 'verified_at', type: 'date', required: false }
    ];

    // Check which fields are missing
    const existingFieldNames = existing.fields?.map(f => f.name) || [];
    const newFields = customFields.filter(f => !existingFieldNames.includes(f.name));

    if (newFields.length === 0) {
        console.log(`   ⏭️  All custom fields already exist.`);
    } else {
        console.log(`   ➕ Adding ${newFields.length} new fields:`);
        newFields.forEach(f => console.log(`      + ${f.name} (${f.type})`));
    }

    // Merge existing fields with new fields
    const mergedFields = [...existing.fields, ...newFields];

    try {
        await pb.collections.update('users', {
            fields: mergedFields,
            // API Rules for users
            listRule: '@request.auth.role = "admin"',
            viewRule: '@request.auth.id = id || @request.auth.role = "admin"',
            updateRule: '@request.auth.id = id || @request.auth.role = "admin"',
            deleteRule: '@request.auth.role = "admin"'
        });
        console.log(`   ✅ Users collection updated successfully!`);
    } catch (error) {
        console.error(`   ❌ Failed to update users:`, error.message);
        if (error.response?.data) {
            console.error(`      Details:`, JSON.stringify(error.response.data, null, 2));
        }
        throw error;
    }

    console.log('\n========================================');
    console.log('✅ Users migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateUsers().catch(console.error);
}

export { migrateUsers };
