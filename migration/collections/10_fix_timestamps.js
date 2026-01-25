/**
 * Migration: Fix Timestamps
 * 
 * Explicitly adds 'created' and 'updated' fields to collections if missing.
 * This addresses the issue where default system fields are not appearing in records.
 */

import { authenticateAdmin, updateCollection } from '../pb-client.js';

async function fixTimestamps() {
    const pb = await authenticateAdmin();
    const collections = await pb.collections.getFullList();

    for (const collection of collections) {
        if (['base', 'auth'].includes(collection.type)) {
            console.log(`Checking ${collection.name}...`);

            // Check if fields already exist in the defined schema
            const hasCreated = collection.fields.find(f => f.name === 'created');
            const hasUpdated = collection.fields.find(f => f.name === 'updated');

            if (hasCreated && hasUpdated) {
                console.log(`- ${collection.name}: Timestamps already in schema.`);
                continue;
            }

            const newFields = [...collection.fields];

            if (!hasCreated) {
                console.log(`- ${collection.name}: Adding 'created' field`);
                newFields.push({
                    name: 'created',
                    type: 'date',
                    required: false,
                    presentable: false,
                    system: false, // Try as non-system first if system fails
                    options: {}
                });
            }

            if (!hasUpdated) {
                console.log(`- ${collection.name}: Adding 'updated' field`);
                newFields.push({
                    name: 'updated',
                    type: 'date',
                    required: false,
                    presentable: false,
                    system: false,
                    options: {}
                });
            }

            try {
                // We update the collection with the new fields
                // Note: If PocketBase considers them system fields, this might throw or be ignored.
                // But if they are missing from sorting, we must ensure they are in the schema.
                await pb.collections.update(collection.id, {
                    fields: newFields
                });
                console.log(`✅ ${collection.name} updated successfully.`);
            } catch (err) {
                console.error(`❌ Failed to update ${collection.name}: ${err.message}`);
                // If it fails because of "system field", then they should exist. 
                // But the error says "invalid sort field", so they likely don't exist as sortable columns.
            }
        }
    }
}

fixTimestamps().catch(console.error);
