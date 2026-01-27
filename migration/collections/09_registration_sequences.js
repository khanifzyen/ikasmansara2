/**
 * Registration Sequences Migration
 * 
 * Helper collection untuk menyimpan counter sequence nomor EKTA per angkatan.
 * Format EKTA: {angkatan}.{no_urut_angkatan:04d}.{no_urut_global}
 * Contoh: 2010.0010.121
 */

import { authenticateAdmin, upsertCollection } from '../pb-client.js';

const registrationSequencesSchema = {
    name: 'registration_sequences',
    type: 'base',
    fields: [
        {
            name: 'year',
            type: 'number',
            required: true,
            options: {
                min: 0,
                noDecimal: true
            }
        },
        {
            name: 'last_number',
            type: 'number',
            required: true,
            options: {
                min: 0,
                noDecimal: true
            }
        }
    ],
    indexes: [
        'CREATE UNIQUE INDEX idx_reg_seq_year ON registration_sequences(year)'
    ],
    // Admin only access
    listRule: null,
    viewRule: null,
    createRule: null,
    updateRule: null,
    deleteRule: null
};

export async function migrateRegistrationSequences() {
    console.log('\n========================================');
    console.log('🎯 Starting Registration Sequences Migration...');
    console.log('========================================\n');

    const pb = await authenticateAdmin();

    // Create/update collection
    await upsertCollection(pb, registrationSequencesSchema);

    // Initialize global counter record (year = 0) if not exists
    try {
        const existing = await pb.collection('registration_sequences').getFirstListItem('year = 0');
        console.log('   ✅ Global counter (year=0) already exists, last_number:', existing.last_number);
    } catch (error) {
        if (error.status === 404) {
            // Create initial global counter
            await pb.collection('registration_sequences').create({
                year: 0,
                last_number: 0
            });
            console.log('   ✅ Created global counter (year=0) with last_number=0');
        } else {
            console.log('   ⚠️  Could not check global counter:', error.message);
        }
    }

    console.log('\n========================================');
    console.log('✅ Registration Sequences migration completed!');
    console.log('========================================\n');
}

// Only run if executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateRegistrationSequences().catch(console.error);
}

export { migrateRegistrationSequences as default };
