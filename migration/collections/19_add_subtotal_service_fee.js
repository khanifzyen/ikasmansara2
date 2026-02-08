/**
 * Migration: Add Subtotal and Service Fee Fields to Event Bookings
 * 
 * Target Collection: event_bookings
 * New Fields:
 * - subtotal (number)
 * - service_fee (number)
 */

import { authenticateAdmin } from '../pb-client.js';

async function migrateBookingFields() {
    console.log('\n========================================');
    console.log('🔄 Starting Event Bookings Schema Update...');
    console.log('========================================');

    const pb = await authenticateAdmin();

    console.log(`\n🔍 Fetching collection: event_bookings...`);
    try {
        const bookingsCollection = await pb.collections.getOne('event_bookings');
        let updatedFields = [...bookingsCollection.fields];
        let modified = false;

        // Check and add subtotal
        if (!updatedFields.some(f => f.name === 'subtotal')) {
            console.log(`   + Adding field: subtotal (number)`);
            updatedFields.push({
                name: 'subtotal',
                type: 'number',
                required: false,
                options: {
                    min: 0,
                    noDecimal: false
                }
            });
            modified = true;
        } else {
            console.log(`   - Field 'subtotal' already exists.`);
        }

        // Check and add service_fee
        if (!updatedFields.some(f => f.name === 'service_fee')) {
            console.log(`   + Adding field: service_fee (number)`);
            updatedFields.push({
                name: 'service_fee',
                type: 'number',
                required: false,
                options: {
                    min: 0,
                    noDecimal: false
                }
            });
            modified = true;
        } else {
            console.log(`   - Field 'service_fee' already exists.`);
        }

        if (modified) {
            await pb.collections.update(bookingsCollection.id, {
                fields: updatedFields
            });
            console.log(`   ✅ Successfully updated event_bookings schema.`);
        } else {
            console.log(`   ℹ️ No changes needed.`);
        }

    } catch (err) {
        console.error(`   ❌ Failed to update event_bookings: ${err.message}`);
        if (err.data) {
            console.error(`      Details:`, JSON.stringify(err.data, null, 2));
        }
    }

    console.log('\n========================================');
    console.log('✅ Migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateBookingFields().catch(console.error);
}

export { migrateBookingFields };
