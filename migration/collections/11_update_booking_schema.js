/**
 * Migration: Update Booking Schema for Multi-Ticket Support
 * 
 * Target Collections:
 * - event_bookings: Remove 'ticket_type', 'quantity'; Add 'metadata' (json)
 * - event_booking_tickets: Add 'ticket_type' (relation)
 */

import { authenticateAdmin, getCollectionId, upsertCollection } from '../pb-client.js';

async function migrateBookingSchema() {
    console.log('\n========================================');
    console.log('🔄 Starting Booking Schema Migration (Multi-Ticket)...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    // -------------------------------------------------------------------------
    // 1. Update event_bookings (Remove fields, Add metadata)
    // -------------------------------------------------------------------------
    console.log(`\n🔍 Updating collection: event_bookings...`);
    try {
        const bookingsCollection = await pb.collections.getOne('event_bookings');

        // Filter out fields to remove
        const fieldsToRemove = ['ticket_type', 'quantity'];
        let updatedFields = bookingsCollection.fields.filter(f => !fieldsToRemove.includes(f.name));

        // Check if metadata exists, if not add it
        const metadataExists = updatedFields.some(f => f.name === 'metadata');
        if (!metadataExists) {
            console.log(`   + Adding field: metadata (json)`);
            updatedFields.push({
                name: 'metadata',
                type: 'json',
                required: false // Relax requirement to avoid validation errors on existing records
            });
        }

        // Mark removed fields for logging
        const removedCount = bookingsCollection.fields.length - updatedFields.length + (metadataExists ? 0 : 1);
        if (removedCount > 0) {
            console.log(`   - Removing fields: ${fieldsToRemove.join(', ')}`);
        }

        await pb.collections.update(bookingsCollection.id, {
            fields: updatedFields
        });
        console.log(`   ✅ Updated event_bookings schema.`);

    } catch (err) {
        console.error(`   ❌ Failed to update event_bookings: ${err.message}`);
        if (err.data) {
            console.error(`      Details:`, JSON.stringify(err.data, null, 2));
        }
    }

    // -------------------------------------------------------------------------
    // 2. Update event_booking_tickets (Add ticket_type relation)
    // -------------------------------------------------------------------------
    const ticketsId = await getCollectionId(pb, 'event_tickets');
    if (!ticketsId) {
        console.error('❌ event_tickets collection not found! Cannot create relation.');
        return;
    }

    await upsertCollection(pb, {
        name: 'event_booking_tickets',
        fields: [
            {
                name: 'ticket_type',
                type: 'relation',
                required: true,
                collectionId: ticketsId,
                maxSelect: 1
            }
        ]
    });

    console.log('\n========================================');
    console.log('✅ Booking Schema Migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateBookingSchema().catch(console.error);
}

export { migrateBookingSchema };
