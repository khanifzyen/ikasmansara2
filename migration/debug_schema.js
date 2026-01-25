import { authenticateAdmin } from './pb-client.js';

async function debugSchema() {
    const pb = await authenticateAdmin();

    console.log('--- Inspecting "donations" Collection ---');
    try {
        const collection = await pb.collections.getOne('donations');
        console.log('Collection Type:', collection.type);
        console.log('System Fields (schema keys):', Object.keys(collection));
        // console.log('Full Schema:', JSON.stringify(collection, null, 2));
    } catch (e) {
        console.error('Error fetching collection:', e.message);
    }

    console.log('\n--- Fetching One Record (No Sort) ---');
    try {
        const records = await pb.collection('donations').getList(1, 1, {
            // No sort
        });

        if (records.items.length > 0) {
            const item = records.items[0];
            console.log('Record Keys:', Object.keys(item));
            console.log('Created field value:', item.created);
            console.log('Updated field value:', item.updated);
        } else {
            console.log('No records found in "donations".');
        }
    } catch (e) {
        console.error('Error fetching record:', e.message);
    }
}

debugSchema();
