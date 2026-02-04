/**
 * Migration: Add is_deleted to Event Bookings
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function migrateIsDeleted() {
    console.log('\n========================================');
    console.log('🎯 Starting Add is_deleted Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    // Get existing collection to ensure we don't overwrite blindly, 
    // although upsertCollection handles merge, we want to be explicit.

    // We only need to specify the new field. upsertCollection will merge it.
    await upsertCollection(pb, {
        name: 'event_bookings',
        type: 'base',
        // Keep existing rules (or update if needed, but we keep them same)
        // We pass empty strings to avoid overwriting rules if we don't want to change them,
        // BUT upsertCollection logic compares provided rules vs existing. 
        // If we provide undefined/missing in schema object, it might default?
        // upsertCollection:
        // const { name, fields = [], indexes = [], ...rules } = schema;
        // rules.deleteRule !== undefined ? rules.deleteRule : existing.deleteRule

        // So omitting rules is safe, it keeps existing.

        fields: [
            {
                name: 'is_deleted',
                type: 'number',
                required: false,
                min: 0,
                max: 1
            }
        ]
    });

    console.log('\n========================================');
    console.log('✅ is_deleted migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateIsDeleted().catch(console.error);
}

export { migrateIsDeleted };
