/**
 * IKA SMANSARA - Database Seeder (Relations)
 * 
 * This script seeds relational data that depends on the main seeder.
 * Run this AFTER running the main seeder.js
 * 
 * Updated for new schema:
 * - event_bookings (Order/Invoice)
 * - event_booking_tickets (Individual tickets)
 * - event_sub_event_registrations (Sub-event attendance)
 * - donation_transactions
 * - forum_likes
 * 
 * Usage:
 *   npm run seed:relations        - Seed relational data
 *   npm run seed:relations:down   - Remove relational data
 */

import { authenticateAdmin, pb } from './pb-client.js';

// ============================================
// HELPER FUNCTIONS
// ============================================

async function getRecords(pb, collection, filter = '') {
    try {
        const records = await pb.collection(collection).getFullList({ filter });
        return records;
    } catch (error) {
        console.error(`Failed to get ${collection}:`, error.message);
        return [];
    }
}

function generateBookingId(eventCode, year, seq) {
    return `${eventCode}-${year}-${String(seq).padStart(4, '0')}`;
}

function generateTicketId(eventCode, seq) {
    return `TIX-${eventCode}-${String(seq).padStart(3, '0')}`;
}

function generateSubEventTicketId(eventCode, subEventPrefix, seq) {
    return `${eventCode}-${subEventPrefix}-${String(seq).padStart(3, '0')}`;
}

function generateTransactionId() {
    return `TRX-${Date.now()}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
}

// ============================================
// STORE SEEDED IDS
// ============================================
const seededRelationIds = {
    event_bookings: [],
    event_booking_tickets: [],
    event_sub_event_registrations: [],
    donation_transactions: [],
    forum_likes: []
};

// ============================================
// SEEDER FUNCTIONS
// ============================================

/**
 * Seed Event Bookings and Tickets
 */
async function seedEventBookings(pb, event, ticketTypes, subEvents, users) {
    console.log('\n📝 Seeding Event Bookings & Tickets...');

    const eventCode = event.code || 'EVT';
    const year = new Date(event.date).getFullYear();
    let bookingSeq = event.last_booking_seq || 0;
    let ticketSeq = event.last_ticket_seq || 0;

    // Sample bookings
    const bookingsData = [
        {
            user: users[0], // Budi
            ticketType: ticketTypes.find(t => t.name.includes('Early Bird')) || ticketTypes[0],
            quantity: 2,
            selectedOptions: [{ size: 'L' }, { size: 'M' }],
            subEventRegistrations: [0, 1], // Indices of subEvents
            paymentStatus: 'paid',
            paymentMethod: 'Bank Transfer',
            paymentDate: '2026-01-20 10:00:00.000Z'
        },
        {
            user: users[2], // Rina
            ticketType: ticketTypes.find(t => t.name.includes('Regular')) || ticketTypes[1],
            quantity: 1,
            selectedOptions: [{ size: 'S' }],
            subEventRegistrations: [1], // Senam only
            paymentStatus: 'paid',
            paymentMethod: 'QRIS',
            paymentDate: '2026-01-18 14:30:00.000Z'
        },
        {
            user: users[4], // Rian
            ticketType: ticketTypes.find(t => t.name.includes('Umum')) || ticketTypes[0],
            quantity: 1,
            selectedOptions: [{}],
            subEventRegistrations: [],
            paymentStatus: 'pending',
            paymentMethod: null,
            paymentDate: null
        }
    ];

    for (const bookingData of bookingsData) {
        try {
            bookingSeq++;
            const bookingId = generateBookingId(eventCode, year, bookingSeq);
            const totalPrice = bookingData.ticketType.price * bookingData.quantity;

            // 1. Create Booking
            const booking = await pb.collection('event_bookings').create({
                booking_id: bookingId,
                event: event.id,
                user: bookingData.user.id,
                ticket_type: bookingData.ticketType.id,
                quantity: bookingData.quantity,
                total_price: totalPrice,
                payment_status: bookingData.paymentStatus,
                payment_method: bookingData.paymentMethod,
                payment_date: bookingData.paymentDate
            });
            seededRelationIds.event_bookings.push(booking.id);
            console.log(`  ✅ Created booking: ${bookingId}`);

            // 2. Create Individual Tickets for this Booking
            for (let i = 0; i < bookingData.quantity; i++) {
                ticketSeq++;
                const ticketId = generateTicketId(eventCode, ticketSeq);
                const selectedOptions = bookingData.selectedOptions[i] || {};

                const ticket = await pb.collection('event_booking_tickets').create({
                    ticket_id: ticketId,
                    booking: booking.id,
                    selected_options: selectedOptions,
                    shirt_picked_up: false,
                    checked_in: false
                });
                seededRelationIds.event_booking_tickets.push(ticket.id);
                console.log(`    ✅ Created ticket: ${ticketId}`);

                // 3. Register Sub-Events for this ticket (only first ticket registers)
                if (i === 0 && bookingData.subEventRegistrations.length > 0) {
                    for (const subEventIndex of bookingData.subEventRegistrations) {
                        const subEvent = subEvents[subEventIndex];
                        if (!subEvent) continue;

                        const subEventPrefix = subEvent.name.substring(0, 3).toUpperCase();
                        const subEventTicketId = generateSubEventTicketId(eventCode, subEventPrefix, ticketSeq);

                        try {
                            const subEventReg = await pb.collection('event_sub_event_registrations').create({
                                sub_event_ticket_id: subEventTicketId,
                                booking_ticket: ticket.id,
                                sub_event: subEvent.id,
                                checked_in: false
                            });
                            seededRelationIds.event_sub_event_registrations.push(subEventReg.id);
                            console.log(`      ✅ Registered sub-event: ${subEvent.name}`);
                        } catch (err) {
                            console.error(`      ❌ Failed sub-event registration:`, err.message);
                        }
                    }
                }
            }

        } catch (error) {
            console.error(`  ❌ Failed to create booking:`, error.message);
            if (error.data) console.error(`     Details:`, JSON.stringify(error.data, null, 2));
        }
    }

    // Update event sequences
    try {
        await pb.collection('events').update(event.id, {
            last_booking_seq: bookingSeq,
            last_ticket_seq: ticketSeq
        });
    } catch (e) {
        console.log('  ⚠️ Could not update event sequences:', e.message);
    }
}

/**
 * Seed Donation Transactions
 */
async function seedDonationTransactions(pb, donations, events, users) {
    console.log('\n💳 Seeding Donation Transactions...');

    const transactions = [
        // Campaign donations
        {
            donation: donations[0]?.id,
            event: null,
            user: users[0]?.id,
            donorName: 'Budi Santoso',
            amount: 1000000,
            message: 'Semoga bermanfaat untuk adik-adik',
            isAnonymous: false,
            status: 'success'
        },
        {
            donation: donations[0]?.id,
            event: null,
            user: users[2]?.id,
            donorName: 'Rina Mulyani',
            amount: 500000,
            message: '',
            isAnonymous: false,
            status: 'success'
        },
        {
            donation: donations[0]?.id,
            event: null,
            user: null,
            donorName: 'Hamba Allah',
            amount: 2500000,
            message: 'Semoga menjadi amal jariyah',
            isAnonymous: true,
            status: 'success'
        },
        {
            donation: donations[1]?.id,
            event: null,
            user: users[4]?.id,
            donorName: 'Rian Ardi',
            amount: 750000,
            message: 'Untuk adik-adik yang membutuhkan',
            isAnonymous: false,
            status: 'success'
        },
        {
            donation: donations[2]?.id,
            event: null,
            user: users[3]?.id,
            donorName: 'Sri Wahyuni',
            amount: 300000,
            message: 'Semoga lekas sembuh',
            isAnonymous: false,
            status: 'success'
        },
        // Event donations
        {
            donation: null,
            event: events[0]?.id,
            user: users[1]?.id,
            donorName: 'Dimas Setiawan',
            amount: 200000,
            message: 'Sukses acaranya!',
            isAnonymous: false,
            status: 'success'
        },
        {
            donation: null,
            event: events[0]?.id,
            user: users[5]?.id,
            donorName: 'Dina Susanti',
            amount: 150000,
            message: '',
            isAnonymous: false,
            status: 'success'
        }
    ];

    for (const trx of transactions) {
        if (!trx.donation && !trx.event) continue; // Skip invalid

        try {
            const record = await pb.collection('donation_transactions').create({
                donation: trx.donation,
                event: trx.event,
                user: trx.user,
                donor_name: trx.donorName,
                amount: trx.amount,
                message: trx.message,
                is_anonymous: trx.isAnonymous,
                payment_status: trx.status,
                payment_method: trx.user ? 'Bank Transfer' : 'QRIS',
                transaction_id: generateTransactionId()
            });
            seededRelationIds.donation_transactions.push(record.id);
            console.log(`  ✅ Created transaction: ${record.transaction_id}`);
        } catch (error) {
            console.error(`  ❌ Failed to create transaction:`, error.message);
            if (error.data) console.error(`     Details:`, JSON.stringify(error.data, null, 2));
        }
    }
}

/**
 * Seed Forum Likes
 */
async function seedForumLikes(pb, posts, users) {
    console.log('\n❤️ Seeding Forum Likes...');

    const likesToCreate = [
        { postIndex: 0, userIndices: [1, 2, 3, 4, 5] },
        { postIndex: 1, userIndices: [0, 2, 4, 6, 8] }
    ];

    for (const likeGroup of likesToCreate) {
        const post = posts[likeGroup.postIndex];
        if (!post) continue;

        for (const userIndex of likeGroup.userIndices) {
            const user = users[userIndex];
            if (!user) continue;

            try {
                const record = await pb.collection('forum_likes').create({
                    post: post.id,
                    user: user.id
                });
                seededRelationIds.forum_likes.push(record.id);
                console.log(`  ✅ Like on post by ${user.name || user.email}`);
            } catch (error) {
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
// MAIN FUNCTIONS
// ============================================

async function seedRelationsUp() {
    console.log('🌱 Starting relations seeding...\n');
    console.log('═'.repeat(50));

    try {
        const pb = await authenticateAdmin();

        console.log('\n📥 Fetching existing records...');
        const events = await getRecords(pb, 'events');
        const ticketTypes = await getRecords(pb, 'event_tickets');
        const subEvents = await getRecords(pb, 'event_sub_events');
        const donations = await getRecords(pb, 'donations');
        const users = await getRecords(pb, 'users', 'email ~ "@example.com" || email = "admin@ikasmansara.id"');
        const forumPosts = await getRecords(pb, 'forum_posts');

        if (events.length === 0 || users.length === 0) {
            throw new Error('Missing events or users. Run main seeder first.');
        }

        console.log(`  Found ${events.length} event(s), ${ticketTypes.length} ticket types`);
        console.log(`  Found ${subEvents.length} sub-events, ${donations.length} donations`);
        console.log(`  Found ${users.length} users, ${forumPosts.length} forum posts`);

        // 1. Seed Bookings, Tickets, and Sub-Event Registrations
        await seedEventBookings(pb, events[0], ticketTypes, subEvents, users);

        // 2. Seed Donation Transactions
        await seedDonationTransactions(pb, donations, events, users);

        // 3. Seed Forum Likes
        await seedForumLikes(pb, forumPosts, users);

        console.log('\n' + '═'.repeat(50));
        console.log('✅ Relations seeding completed!');
        console.log('═'.repeat(50));

        console.log('\n📊 Summary:');
        console.log(`   Event Bookings:      ${seededRelationIds.event_bookings.length}`);
        console.log(`   Booking Tickets:     ${seededRelationIds.event_booking_tickets.length}`);
        console.log(`   Sub-Event Regs:      ${seededRelationIds.event_sub_event_registrations.length}`);
        console.log(`   Donation Trx:        ${seededRelationIds.donation_transactions.length}`);
        console.log(`   Forum Likes:         ${seededRelationIds.forum_likes.length}`);

    } catch (error) {
        console.error('\n❌ Relations seeding failed:', error.message);
        process.exit(1);
    }
}

async function seedRelationsDown() {
    console.log('🗑️  Removing relational data...\n');
    console.log('═'.repeat(50));

    try {
        const pb = await authenticateAdmin();

        const collectionsToClean = [
            'forum_likes',
            'event_sub_event_registrations',
            'event_booking_tickets',
            'event_bookings',
            'donation_transactions'
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
                console.log(`  📦 Cleaned ${records.length} records`);
            } catch (error) {
                console.log(`  ⏭️  Skipping ${collectionName}: ${error.message}`);
            }
        }

        console.log('\n' + '═'.repeat(50));
        console.log('✅ Relational data removed!');
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
