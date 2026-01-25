/**
 * IKA SMANSARA - Database Seeder (Relations)
 * 
 * This script seeds relational data that depends on the main seeder.
 * Run this AFTER running the main seeder.js
 * 
 * Usage:
 *   npm run seed:relations        - Seed relational data
 *   npm run seed:relations:down   - Remove relational data
 */

import { authenticateAdmin, pb } from './pb-client.js';

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Get records from a collection
 */
async function getRecords(pb, collection, filter = '') {
    try {
        const records = await pb.collection(collection).getFullList({
            filter: filter
        });
        return records;
    } catch (error) {
        console.error(`Failed to get ${collection}:`, error.message);
        return [];
    }
}

/**
 * Generate unique ticket code
 */
function generateTicketCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = 'TIX-';
    for (let i = 0; i < 8; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
}

/**
 * Generate unique transaction ID
 */
function generateTransactionId() {
    return `TRX-${Date.now()}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
}

// ============================================
// SEEDER DATA TEMPLATES
// ============================================

// Event Tickets Data Template (will be linked to event)
const eventTicketsData = [
    {
        name: 'Tiket Regular',
        price: 100000,
        quota: 300,
        sold: 45,
        includes: JSON.stringify(['Kaos Event', 'Snack Box', 'Doorprize'])
    },
    {
        name: 'Tiket VIP',
        price: 250000,
        quota: 50,
        sold: 12,
        includes: JSON.stringify(['Kaos Event Premium', 'Lunch Box', 'Doorprize', 'Sertifikat', 'Goodie Bag'])
    }
];

// Ticket Options (sizes)
const ticketOptionsData = [
    {
        name: 'Ukuran Kaos',
        choices: JSON.stringify(['S', 'M', 'L', 'XL', 'XXL'])
    }
];

// Sub Events Data
const subEventsData = [
    {
        name: 'Cek Kesehatan Gratis',
        description: 'Pemeriksaan tekanan darah, gula darah, dan kolesterol',
        quota: 100,
        registered: 23,
        location: 'Posko Kesehatan'
    },
    {
        name: 'Senam Pagi Bersama',
        description: 'Senam aerobik bersama instruktur profesional',
        quota: 200,
        registered: 87,
        location: 'Lapangan Utama'
    },
    {
        name: 'Foto Bersama Angkatan',
        description: 'Sesi foto bersama per angkatan',
        quota: null,
        registered: 0,
        location: 'Photo Booth Area'
    }
];

// Sponsor Tiers Data
const sponsorTiersData = [
    {
        tier_name: 'Platinum',
        price: 25000000,
        benefits: JSON.stringify([
            'Logo di backdrop utama',
            'Logo di semua materi promosi',
            'Booth eksklusif 6x3m',
            '10 tiket VIP gratis',
            'Kesempatan sambutan di acara'
        ]),
        company_name: 'Bank Jateng',
        is_filled: true
    },
    {
        tier_name: 'Gold',
        price: 15000000,
        benefits: JSON.stringify([
            'Logo di backdrop',
            'Logo di brosur',
            'Booth 3x3m',
            '5 tiket VIP gratis'
        ]),
        company_name: 'Telkom Indonesia',
        is_filled: true
    },
    {
        tier_name: 'Silver',
        price: 7500000,
        benefits: JSON.stringify([
            'Logo di brosur',
            'Booth 2x2m',
            '3 tiket regular gratis'
        ]),
        company_name: null,
        is_filled: false
    }
];

// ============================================
// STORE SEEDED IDS
// ============================================
const seededRelationIds = {
    event_tickets: [],
    event_ticket_options: [],
    event_sub_events: [],
    event_sponsors: [],
    event_registrations: [],
    donation_transactions: [],
    forum_likes: []
};

// ============================================
// SEEDER FUNCTIONS
// ============================================

/**
 * Seed Event Tickets
 */
async function seedEventTickets(pb, eventId) {
    console.log('\n🎫 Seeding Event Tickets...');

    for (const ticketData of eventTicketsData) {
        try {
            const record = await pb.collection('event_tickets').create({
                ...ticketData,
                event: eventId
            });
            seededRelationIds.event_tickets.push(record.id);
            console.log(`  ✅ Created ticket: ${ticketData.name}`);
        } catch (error) {
            console.error(`  ❌ Failed to create ticket:`, error.message);
        }
    }

    return seededRelationIds.event_tickets;
}

/**
 * Seed Ticket Options
 */
async function seedTicketOptions(pb, ticketIds) {
    console.log('\n📋 Seeding Ticket Options...');

    for (const ticketId of ticketIds) {
        for (const optionData of ticketOptionsData) {
            try {
                const record = await pb.collection('event_ticket_options').create({
                    ...optionData,
                    ticket: ticketId
                });
                seededRelationIds.event_ticket_options.push(record.id);
                console.log(`  ✅ Created option: ${optionData.name} for ticket ${ticketId}`);
            } catch (error) {
                console.error(`  ❌ Failed to create option:`, error.message);
            }
        }
    }
}

/**
 * Seed Sub Events
 */
async function seedSubEvents(pb, eventId) {
    console.log('\n📌 Seeding Sub Events...');

    for (const subEventData of subEventsData) {
        try {
            const record = await pb.collection('event_sub_events').create({
                ...subEventData,
                event: eventId
            });
            seededRelationIds.event_sub_events.push(record.id);
            console.log(`  ✅ Created sub event: ${subEventData.name}`);
        } catch (error) {
            console.error(`  ❌ Failed to create sub event:`, error.message);
        }
    }

    return seededRelationIds.event_sub_events;
}

/**
 * Seed Event Sponsors
 */
async function seedEventSponsors(pb, eventId) {
    console.log('\n🏢 Seeding Event Sponsors...');

    for (const sponsorData of sponsorTiersData) {
        try {
            const record = await pb.collection('event_sponsors').create({
                ...sponsorData,
                event: eventId
            });
            seededRelationIds.event_sponsors.push(record.id);
            console.log(`  ✅ Created sponsor tier: ${sponsorData.tier_name}`);
        } catch (error) {
            console.error(`  ❌ Failed to create sponsor:`, error.message);
        }
    }
}

/**
 * Seed Event Registrations
 */
async function seedEventRegistrations(pb, eventId, ticketIds, subEventIds, userIds) {
    console.log('\n📝 Seeding Event Registrations...');

    // Create 3 sample registrations
    const registrations = [
        {
            userId: userIds[0], // Budi
            ticketId: ticketIds[1], // VIP
            selectedOptions: { 'Ukuran Kaos': 'L' },
            subEvents: [subEventIds[0], subEventIds[1]], // Cek kesehatan + Senam
            paymentStatus: 'paid',
            paymentMethod: 'Bank Transfer',
            paymentDate: '2026-01-20 10:00:00.000Z'
        },
        {
            userId: userIds[2], // Rina
            ticketId: ticketIds[0], // Regular
            selectedOptions: { 'Ukuran Kaos': 'M' },
            subEvents: [subEventIds[1]], // Senam only
            paymentStatus: 'paid',
            paymentMethod: 'QRIS',
            paymentDate: '2026-01-18 14:30:00.000Z'
        },
        {
            userId: userIds[4], // Rian
            ticketId: ticketIds[0], // Regular
            selectedOptions: { 'Ukuran Kaos': 'XL' },
            subEvents: [],
            paymentStatus: 'pending',
            paymentMethod: null,
            paymentDate: null
        }
    ];

    for (const reg of registrations) {
        try {
            const ticketInfo = await pb.collection('event_tickets').getOne(reg.ticketId);
            const record = await pb.collection('event_registrations').create({
                event: eventId,
                ticket: reg.ticketId,
                user: reg.userId,
                ticket_code: generateTicketCode(),
                selected_options: JSON.stringify(reg.selectedOptions),
                sub_events: reg.subEvents,
                total_price: ticketInfo.price,
                payment_status: reg.paymentStatus,
                payment_method: reg.paymentMethod,
                payment_date: reg.paymentDate,
                shirt_picked_up: false,
                checked_in: false
            });
            seededRelationIds.event_registrations.push(record.id);
            console.log(`  ✅ Created registration: ${record.ticket_code}`);
        } catch (error) {
            console.error(`  ❌ Failed to create registration:`, error.message);
            if (error.data) {
                console.error(`     Details:`, JSON.stringify(error.data, null, 2));
            }
        }
    }
}

/**
 * Seed Donation Transactions (for donations)
 */
async function seedDonationTransactions(pb, donationIds, userIds) {
    console.log('\n💳 Seeding Donation Transactions...');

    const transactions = [
        // For first donation (Renovasi Masjid)
        {
            donationId: donationIds[0],
            userId: userIds[0],
            donorName: 'Budi Santoso',
            amount: 1000000,
            message: 'Semoga bermanfaat untuk adik-adik',
            isAnonymous: false,
            status: 'success'
        },
        {
            donationId: donationIds[0],
            userId: userIds[2],
            donorName: 'Rina Mulyani',
            amount: 500000,
            message: '',
            isAnonymous: false,
            status: 'success'
        },
        {
            donationId: donationIds[0],
            userId: null,
            donorName: 'Hamba Allah',
            amount: 2500000,
            message: 'Semoga menjadi amal jariyah',
            isAnonymous: true,
            status: 'success'
        },
        // For second donation (Beasiswa)
        {
            donationId: donationIds[1],
            userId: userIds[4],
            donorName: 'Rian Ardi',
            amount: 750000,
            message: 'Untuk adik-adik yang membutuhkan',
            isAnonymous: false,
            status: 'success'
        },
        // For third donation (Tali Kasih)
        {
            donationId: donationIds[2],
            userId: userIds[3],
            donorName: 'Sri Wahyuni',
            amount: 300000,
            message: 'Semoga lekas sembuh',
            isAnonymous: false,
            status: 'success'
        }
    ];

    for (const trx of transactions) {
        try {
            const record = await pb.collection('donation_transactions').create({
                donation: trx.donationId,
                event: null,
                user: trx.userId,
                donor_name: trx.donorName,
                amount: trx.amount,
                message: trx.message,
                is_anonymous: trx.isAnonymous,
                payment_status: trx.status,
                payment_method: 'Bank Transfer',
                transaction_id: generateTransactionId()
            });
            seededRelationIds.donation_transactions.push(record.id);
            console.log(`  ✅ Created donation transaction: ${record.transaction_id}`);
        } catch (error) {
            console.error(`  ❌ Failed to create donation transaction:`, error.message);
            if (error.data) {
                console.error(`     Details:`, JSON.stringify(error.data, null, 2));
            }
        }
    }
}

/**
 * Seed Event Donation Transactions
 */
async function seedEventDonationTransactions(pb, eventId, userIds) {
    console.log('\n💰 Seeding Event Donation Transactions...');

    const transactions = [
        {
            userId: userIds[1],
            donorName: 'Dimas Setiawan',
            amount: 200000,
            message: 'Sukses acaranya!',
            isAnonymous: false
        },
        {
            userId: userIds[5],
            donorName: 'Dina Susanti',
            amount: 150000,
            message: '',
            isAnonymous: false
        }
    ];

    for (const trx of transactions) {
        try {
            const record = await pb.collection('donation_transactions').create({
                donation: null,
                event: eventId,
                user: trx.userId,
                donor_name: trx.donorName,
                amount: trx.amount,
                message: trx.message,
                is_anonymous: trx.isAnonymous,
                payment_status: 'success',
                payment_method: 'QRIS',
                transaction_id: generateTransactionId()
            });
            seededRelationIds.donation_transactions.push(record.id);
            console.log(`  ✅ Created event donation: ${record.transaction_id}`);
        } catch (error) {
            console.error(`  ❌ Failed to create event donation:`, error.message);
        }
    }
}

/**
 * Seed Forum Likes
 */
async function seedForumLikes(pb, postIds, userIds) {
    console.log('\n❤️ Seeding Forum Likes...');

    // Create likes for first post from multiple users
    const likesToCreate = [
        { postIndex: 0, userIndices: [1, 2, 3, 4, 5] }, // 5 likes on first post
        { postIndex: 1, userIndices: [0, 2, 4, 6, 8] }  // 5 likes on second post
    ];

    for (const likeGroup of likesToCreate) {
        const postId = postIds[likeGroup.postIndex];
        if (!postId) continue;

        for (const userIndex of likeGroup.userIndices) {
            const userId = userIds[userIndex];
            if (!userId) continue;

            try {
                const record = await pb.collection('forum_likes').create({
                    post: postId,
                    user: userId
                });
                seededRelationIds.forum_likes.push(record.id);
                console.log(`  ✅ Created like on post ${postId} by user ${userId}`);
            } catch (error) {
                // Unique constraint violation is expected if already liked
                if (error.message.includes('UNIQUE')) {
                    console.log(`  ⏭️  Like already exists, skipping...`);
                } else {
                    console.error(`  ❌ Failed to create like:`, error.message);
                }
            }
        }
    }
}

// ============================================
// MAIN SEEDER FUNCTIONS
// ============================================

/**
 * Seed all relational data (UP)
 */
async function seedRelationsUp() {
    console.log('🌱 Starting relations seeding...\n');
    console.log('═'.repeat(50));

    try {
        const pb = await authenticateAdmin();

        // Get existing records from main seeder
        console.log('\n📥 Fetching existing records...');

        const events = await getRecords(pb, 'events');
        const donations = await getRecords(pb, 'donations');
        const users = await getRecords(pb, 'users', 'email ~ "@example.com" || email = "admin@ikasmansara.id"');
        const forumPosts = await getRecords(pb, 'forum_posts');

        if (events.length === 0) {
            throw new Error('No events found. Please run main seeder first.');
        }
        if (users.length === 0) {
            throw new Error('No users found. Please run main seeder first.');
        }

        const eventId = events[0].id;
        const donationIds = donations.map(d => d.id);
        const userIds = users.map(u => u.id);
        const postIds = forumPosts.map(p => p.id);

        console.log(`  Found ${events.length} event(s)`);
        console.log(`  Found ${donations.length} donation(s)`);
        console.log(`  Found ${users.length} user(s)`);
        console.log(`  Found ${forumPosts.length} forum post(s)`);

        // 1. Seed Event Tickets
        const ticketIds = await seedEventTickets(pb, eventId);

        // 2. Seed Ticket Options
        await seedTicketOptions(pb, ticketIds);

        // 3. Seed Sub Events
        const subEventIds = await seedSubEvents(pb, eventId);

        // 4. Seed Sponsors
        await seedEventSponsors(pb, eventId);

        // 5. Seed Event Registrations
        await seedEventRegistrations(pb, eventId, ticketIds, subEventIds, userIds);

        // 6. Seed Donation Transactions (for donations)
        await seedDonationTransactions(pb, donationIds, userIds);

        // 7. Seed Event Donation Transactions
        await seedEventDonationTransactions(pb, eventId, userIds);

        // 8. Seed Forum Likes
        await seedForumLikes(pb, postIds, userIds);

        console.log('\n' + '═'.repeat(50));
        console.log('✅ Relations seeding completed successfully!');
        console.log('═'.repeat(50));

        // Summary
        console.log('\n📊 Seeding Summary:');
        console.log(`   Event Tickets:       ${seededRelationIds.event_tickets.length}`);
        console.log(`   Ticket Options:      ${seededRelationIds.event_ticket_options.length}`);
        console.log(`   Sub Events:          ${seededRelationIds.event_sub_events.length}`);
        console.log(`   Sponsors:            ${seededRelationIds.event_sponsors.length}`);
        console.log(`   Event Registrations: ${seededRelationIds.event_registrations.length}`);
        console.log(`   Donation Trx:        ${seededRelationIds.donation_transactions.length}`);
        console.log(`   Forum Likes:         ${seededRelationIds.forum_likes.length}`);

    } catch (error) {
        console.error('\n❌ Relations seeding failed:', error.message);
        process.exit(1);
    }
}

/**
 * Remove all relational data (DOWN)
 */
async function seedRelationsDown() {
    console.log('🗑️  Removing relational data...\n');
    console.log('═'.repeat(50));

    try {
        const pb = await authenticateAdmin();

        // Delete in correct order (respecting foreign keys)
        const collectionsToClean = [
            'forum_likes',
            'event_registrations',
            'donation_transactions',
            'event_ticket_options',
            'event_sub_events',
            'event_sponsors',
            'event_tickets'
        ];

        for (const collectionName of collectionsToClean) {
            try {
                console.log(`\n🗑️  Cleaning ${collectionName}...`);
                const records = await pb.collection(collectionName).getFullList();

                for (const record of records) {
                    try {
                        await pb.collection(collectionName).delete(record.id);
                        console.log(`  ✅ Deleted: ${record.id}`);
                    } catch (error) {
                        console.error(`  ⚠️  Could not delete ${record.id}:`, error.message);
                    }
                }
                console.log(`  📦 Cleaned ${records.length} records from ${collectionName}`);
            } catch (error) {
                console.log(`  ⏭️  Skipping ${collectionName}: ${error.message}`);
            }
        }

        console.log('\n' + '═'.repeat(50));
        console.log('✅ Relational data removed successfully!');
        console.log('═'.repeat(50));

    } catch (error) {
        console.error('\n❌ Seed down failed:', error.message);
        process.exit(1);
    }
}

// ============================================
// CLI ENTRY POINT
// ============================================

const args = process.argv.slice(2);

if (args.includes('--down') || args.includes('-d')) {
    seedRelationsDown();
} else {
    seedRelationsUp();
}

export { seedRelationsUp, seedRelationsDown };
