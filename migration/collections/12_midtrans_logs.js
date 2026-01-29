/**
 * Migration: Midtrans Logs Collection
 * Based on SKEMA.md
 * 
 * Collection for storing Midtrans notification audit trail.
 */

import { authenticateAdmin, getCollection, upsertCollection } from '../pb-client.js';

async function migrateMidtransLogs() {
    console.log('\n========================================');
    console.log('🎯 Starting Midtrans Logs Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    const collectionName = 'midtrans_logs';

    // Check if collection exists
    const existing = await getCollection(pb, collectionName);
    if (existing) {
        console.log(`\n⏭️  Collection "${collectionName}" already exists. Skipping.`);
        console.log('========================================\n');
        return;
    }

    console.log(`\n🔍 Creating collection: ${collectionName}...`);

    const collectionData = {
        name: collectionName,
        type: 'base',
        fields: [
            { name: 'order_id', type: 'text', required: true },
            { name: 'transaction_id', type: 'text', required: true },
            { name: 'transaction_status', type: 'text', required: true },
            { name: 'payment_type', type: 'text', required: false },
            { name: 'gross_amount', type: 'text', required: false },
            { name: 'fraud_status', type: 'text', required: false },
            { name: 'status_code', type: 'text', required: false },
            { name: 'raw_body', type: 'json', required: true, maxSize: 2000000 }
        ],
        indexes: [
            'CREATE INDEX `idx_order_id` ON `midtrans_logs` (`order_id`)'
        ],
        // API Rules: Admin only for list/view, create/update/delete disabled (system only via hooks)
        listRule: '@request.auth.role = "admin"',
        viewRule: '@request.auth.role = "admin"',
        createRule: null,
        updateRule: null,
        deleteRule: null
    };

    try {
        await upsertCollection(pb, collectionData);
        console.log(`   ✅ Collection "${collectionName}" created successfully!`);
    } catch (error) {
        console.error(`   ❌ Failed to create ${collectionName}:`, error.message);
        if (error.response?.data) {
            console.error(`      Details:`, JSON.stringify(error.response.data, null, 2));
        }
        throw error;
    }

    console.log('\n========================================');
    console.log('✅ Midtrans Logs migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateMidtransLogs().catch(console.error);
}

export { migrateMidtransLogs };
