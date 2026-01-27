import PocketBase from 'pocketbase';
import dotenv from 'dotenv';

dotenv.config();

const pb = new PocketBase(process.env.POCKETBASE_URL);

// Disable auto-cancellation to prevent concurrent request issues
pb.autoCancellation(false);

/**
 * Authenticate as superuser/admin
 */
export async function authenticateAdmin() {
    try {
        await pb.collection('_superusers').authWithPassword(
            process.env.POCKETBASE_ADMIN_EMAIL,
            process.env.POCKETBASE_ADMIN_PASSWORD
        );
        console.log('✅ Authenticated as admin');
        return pb;
    } catch (error) {
        console.error('❌ Failed to authenticate:', error.message);
        throw error;
    }
}

/**
 * Check if collection exists
 */
export async function collectionExists(pb, name) {
    try {
        await pb.collections.getOne(name);
        return true;
    } catch (error) {
        return false;
    }
}

/**
 * Get collection by name (returns null if not found)
 */
export async function getCollection(pb, name) {
    try {
        return await pb.collections.getOne(name);
    } catch (error) {
        return null;
    }
}

/**
 * Get collection ID by name
 */
export async function getCollectionId(pb, name) {
    const collection = await getCollection(pb, name);
    return collection ? collection.id : null;
}

/**
 * Upsert collection - create if not exists, update fields if exists
 * @param {PocketBase} pb - PocketBase instance
 * @param {Object} schema - Collection schema with name, type, fields, rules, indexes
 */
export async function upsertCollection(pb, schema) {
    const { name, fields = [], indexes = [], ...rules } = schema;

    console.log(`\n🔍 Checking collection: ${name}...`);

    const existing = await getCollection(pb, name);

    if (!existing) {
        // CREATE new collection
        console.log(`   📦 Collection "${name}" not found. Creating...`);

        try {
            const collection = await pb.collections.create({
                name,
                type: schema.type || 'base',
                fields,
                indexes,
                ...rules
            });

            console.log(`   ✅ Created collection "${name}" with ${fields.length} fields`);
            fields.forEach(f => console.log(`      + ${f.name} (${f.type})`));

            if (indexes.length > 0) {
                console.log(`   📑 Created ${indexes.length} indexes`);
            }

            // Verify fields were created
            await verifyFields(pb, name, fields.map(f => f.name));

            return collection;
        } catch (error) {
            console.error(`   ❌ Failed to create "${name}":`, error.message);
            if (error.response?.data) {
                console.error(`      Details:`, JSON.stringify(error.response.data, null, 2));
            }
            throw error;
        }
    } else {
        // UPDATE existing collection - check for missing or changed fields
        console.log(`   📦 Collection "${name}" exists. Checking fields...`);

        const existingFields = existing.fields || [];
        const updatedFields = [...existingFields];
        let hasChanges = false;

        for (const schemaField of fields) {
            const existingFieldIndex = updatedFields.findIndex(f => f.name === schemaField.name);

            if (existingFieldIndex === -1) {
                // New field
                console.log(`      + New field: ${schemaField.name} (${schemaField.type})`);
                updatedFields.push(schemaField);
                hasChanges = true;
            } else {
                // Existing field - check if properties changed
                const existingField = updatedFields[existingFieldIndex];
                let fieldChanged = false;

                // Check key properties
                if (existingField.required !== schemaField.required) {
                    console.log(`      * Update field "${schemaField.name}": required ${existingField.required} -> ${schemaField.required}`);
                    existingField.required = schemaField.required;
                    fieldChanged = true;
                }

                if (schemaField.type && existingField.type !== schemaField.type) {
                    console.log(`      * Update field "${schemaField.name}": type ${existingField.type} -> ${schemaField.type}`);
                    existingField.type = schemaField.type;
                    fieldChanged = true;
                }

                if (fieldChanged) hasChanges = true;
            }
        }

        // Merge indexes (avoid duplicates by name)
        const existingIndexes = existing.indexes || [];
        const newIndexes = indexes.filter(idx => {
            const match = idx.match(/CREATE\s+(?:UNIQUE\s+)?INDEX\s+(\w+)/i);
            if (!match) return true;
            const indexName = match[1];
            return !existingIndexes.some(ei => ei.includes(indexName));
        });

        if (newIndexes.length > 0) hasChanges = true;
        const mergedIndexes = [...existingIndexes, ...newIndexes];

        // Always check rules
        const rulesChanged = JSON.stringify({
            listRule: existing.listRule,
            viewRule: existing.viewRule,
            createRule: existing.createRule,
            updateRule: existing.updateRule,
            deleteRule: existing.deleteRule
        }) !== JSON.stringify({
            listRule: rules.listRule !== undefined ? rules.listRule : existing.listRule,
            viewRule: rules.viewRule !== undefined ? rules.viewRule : existing.viewRule,
            createRule: rules.createRule !== undefined ? rules.createRule : existing.createRule,
            updateRule: rules.updateRule !== undefined ? rules.updateRule : existing.updateRule,
            deleteRule: rules.deleteRule !== undefined ? rules.deleteRule : existing.deleteRule
        });

        if (!hasChanges && !rulesChanged) {
            console.log(`   ⏭️  No changes detected for "${name}".`);
            return existing;
        }

        try {
            const updated = await pb.collections.update(existing.id, {
                fields: updatedFields,
                indexes: mergedIndexes,
                ...rules
            });

            console.log(`   🔄 Updated collection "${name}" successfully!`);
            return updated;
        } catch (error) {
            console.error(`   ❌ Failed to update "${name}":`, error.message);
            if (error.response?.data) {
                console.error(`      Details:`, JSON.stringify(error.response.data, null, 2));
            }
            throw error;
        }
    }
}

/**
 * Verify fields exist in collection after create/update
 */
async function verifyFields(pb, collectionName, fieldNames) {
    console.log(`   🔎 Verifying fields...`);

    try {
        const collection = await pb.collections.getOne(collectionName);
        const actualFieldNames = collection.fields?.map(f => f.name) || [];

        const missing = fieldNames.filter(fn => !actualFieldNames.includes(fn));
        const verified = fieldNames.filter(fn => actualFieldNames.includes(fn));

        if (missing.length > 0) {
            console.log(`   ⚠️  Missing fields (not persisted):`);
            missing.forEach(f => console.log(`      ✗ ${f}`));
        }

        if (verified.length > 0) {
            console.log(`   ✓ Verified ${verified.length}/${fieldNames.length} fields exist`);
        }

        return missing.length === 0;
    } catch (error) {
        console.log(`   ⚠️  Could not verify fields: ${error.message}`);
        return false;
    }
}

/**
 * Create collection if not exists (legacy - use upsertCollection instead)
 */
export async function createCollection(pb, schema) {
    return upsertCollection(pb, schema);
}

/**
 * Update collection
 */
export async function updateCollection(pb, name, schema) {
    try {
        const collection = await pb.collections.update(name, schema);
        console.log(`✅ Updated collection: ${name}`);
        return collection;
    } catch (error) {
        console.error(`❌ Failed to update "${name}":`, error.message);
        throw error;
    }
}

export { pb };
