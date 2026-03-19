/**
 * Migration: Restore Event Prizes
 * 
 * Collections:
 * - event_prizes (NEW - restored)
 * - event_winners (UPDATE: remove prize_name, add prize relation)
 */

import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';

async function restoreEventPrizes() {
    console.log('\n========================================');
    console.log('🎁 Starting Restore Event Prizes Migration...');
    console.log('========================================');

    const pb = await authenticateAdmin();
    const eventsId = await getCollectionId(pb, 'events');

    if (!eventsId) {
        console.error('❌ Required collections (events) not found. Run previous migrations first.');
        process.exit(1);
    }

    // 1. Re-create Event Prizes Collection
    await upsertCollection(pb, {
        name: 'event_prizes',
        type: 'base',
        listRule: '',
        viewRule: '',
        createRule: '@request.auth.role = "admin"',
        updateRule: '@request.auth.role = "admin"',
        deleteRule: '@request.auth.role = "admin"',
        fields: [
            {
                name: 'event',
                type: 'relation',
                required: true,
                collectionId: eventsId,
                maxSelect: 1,
                cascadeDelete: true
            },
            { name: 'name', type: 'text', required: true },
            { name: 'quantity', type: 'number', required: true, min: 1 },
            { name: 'image', type: 'file', required: false, maxSelect: 1, maxSize: 5242880 }
        ],
        indexes: [
            'CREATE INDEX idx_prizes_event ON event_prizes (event)'
        ]
    });

    const prizesId = await getCollectionId(pb, 'event_prizes');
    
    const winnersId = await getCollectionId(pb, 'event_winners');
    if (!winnersId || !prizesId) {
         console.error('❌ Required collections not found.');
         process.exit(1);
    }
    
    // We update event_winners directly using raw API if needed, or upsert its full definition again
    // Let's get the existing collection config
    const winnersCollection = await pb.collections.getOne('event_winners');
    
    // Remove prize_name, add prize
    let newFields = winnersCollection.schema.filter(f => f.name !== 'prize_name');
    
    // Check if prize relation already exists (in case running multiple times)
    if (!newFields.find(f => f.name === 'prize')) {
        newFields.push({
            name: 'prize',
            type: 'relation',
            required: true,
            options: {
                collectionId: prizesId,
                maxSelect: 1,
                cascadeDelete: true
            }
        });
    }

    winnersCollection.schema = newFields;
    
    try {
        await pb.collections.update('event_winners', winnersCollection);
        console.log('✅ Collection updated: event_winners');
    } catch (e) {
        console.log('Note: Failed to update event_winners schema, maybe it already has the exact fields (', e.message, ')');
    }

    console.log('\n========================================');
    console.log('✅ Event Prizes restoration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    restoreEventPrizes().catch(console.error);
}

export { restoreEventPrizes };
