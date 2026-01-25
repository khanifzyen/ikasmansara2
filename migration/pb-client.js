import PocketBase from 'pocketbase';
import dotenv from 'dotenv';

dotenv.config();

const pb = new PocketBase(process.env.POCKETBASE_URL);

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
 * Create collection if not exists
 */
export async function createCollection(pb, schema) {
    const exists = await collectionExists(pb, schema.name);
    if (exists) {
        console.log(`⏭️  Collection "${schema.name}" already exists, skipping...`);
        return null;
    }

    try {
        const collection = await pb.collections.create(schema);
        console.log(`✅ Created collection: ${schema.name}`);
        return collection;
    } catch (error) {
        console.error(`❌ Failed to create "${schema.name}":`, error.message);
        throw error;
    }
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

/**
 * Get collection ID by name
 */
export async function getCollectionId(pb, name) {
    try {
        const collection = await pb.collections.getOne(name);
        return collection.id;
    } catch (error) {
        console.error(`❌ Collection "${name}" not found`);
        return null;
    }
}

export { pb };
