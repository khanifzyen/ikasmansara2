/**
 * Migration: Users Collection (extends PocketBase Auth)
 * 
 * Note: PocketBase already has a built-in 'users' auth collection.
 * This script updates it with additional custom fields.
 */

import { authenticateAdmin, updateCollection, getCollectionId } from '../pb-client.js';

async function migrateUsers() {
    const pb = await authenticateAdmin();

    // Update existing users collection with additional fields
    const usersSchema = {
        fields: [
            // PocketBase default auth fields are already included
            { name: 'name', type: 'text', required: true },
            { name: 'phone', type: 'text', required: false },
            { name: 'avatar', type: 'file', maxSelect: 1, maxSize: 5242880 },
            { name: 'angkatan', type: 'number', required: false, min: 1900, max: 2100 },
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
        ]
    };

    await updateCollection(pb, 'users', usersSchema);
    console.log('✅ Users collection updated with custom fields');
}

migrateUsers().catch(console.error);

export { migrateUsers };
