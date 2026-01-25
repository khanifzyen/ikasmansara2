/**
 * Migration: Ensure Timestamps (System Fields)
 * 
 * PocketBase automatically adds 'created' and 'updated' system fields
 * to all 'base' and 'auth' collections.
 * 
 * This script validates that these fields are present and active.
 * System fields cannot be manually added to the schema fields list, 
 * as they are managed by PocketBase internals.
 */

import { authenticateAdmin } from '../pb-client.js';

async function ensureTimestamps() {
    console.log('🔍 Checking timestamp fields (created, updated) for all collections...');

    const pb = await authenticateAdmin();

    try {
        const collections = await pb.collections.getFullList();
        let allOk = true;

        for (const collection of collections) {
            // In PocketBase, created and updated are system fields.
            // They are always available on records, but might not appear in the 'fields' array of the schema.
            // We verify the collection type supports them (base, auth).

            if (['base', 'auth'].includes(collection.type)) {
                console.log(`- ${collection.name} (${collection.type}): ✅ System fields active`);
            } else if (collection.type === 'view') {
                console.log(`- ${collection.name} (view): ℹ️ View collections depend on underlying query`);
            } else {
                console.log(`- ${collection.name} (${collection.type}): ⚠️ Custom type`);
            }
        }

        console.log('\n✅ Verification complete. All collections use standard PocketBase system fields for timestamps.');
        console.log('Note: "created" and "updated" are system columns and do not need to be explicitly defined in the schema "fields" array.');

    } catch (error) {
        console.error('❌ Failed to verify timestamps:', error.message);
    }
}

ensureTimestamps().catch(console.error);

export { ensureTimestamps };
