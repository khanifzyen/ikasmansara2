/**
 * IKA SMANSARA - Database Seeder
 * 
 * This script seeds the database with dummy data extracted from lofi prototypes.
 * 
 * Usage:
 *   npm run seed        - Seed the database
 *   npm run seed:down   - Remove all seeded data
 */

import { authenticateAdmin, pb, getCollectionId } from './pb-client.js';

// ============================================
// DUMMY DATA (from lofi prototypes)
// ============================================

// Users Data
const usersData = [
    {
        email: 'budi.santoso@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Budi Santoso',
        phone: '081234567890',
        angkatan: 2010,
        role: 'alumni',
        job_status: 'swasta',
        company: 'PT. Telkom Indonesia',
        domisili: 'Jakarta',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'dimas.setiawan@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Dimas Setiawan',
        phone: '081234567891',
        angkatan: 2012,
        role: 'alumni',
        job_status: 'swasta',
        company: 'Gojek Indonesia',
        domisili: 'Jakarta',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'rina.mulyani@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Rina Mulyani',
        phone: '081234567892',
        angkatan: 1998,
        role: 'alumni',
        job_status: 'wirausaha',
        company: 'CV. Rina Collection',
        domisili: 'Jepara',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'sri.wahyuni@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Sri Wahyuni',
        phone: '081234567893',
        angkatan: 1998,
        role: 'alumni',
        job_status: 'wirausaha',
        company: 'Katering Bu Sri',
        domisili: 'Jepara',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'rian.ardi@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Rian Ardi',
        phone: '081234567894',
        angkatan: 2012,
        role: 'alumni',
        job_status: 'swasta',
        company: 'Studio Arsitek',
        domisili: 'Jakarta',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'dina.cake@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Dina Susanti',
        phone: '081234567895',
        angkatan: 2005,
        role: 'alumni',
        job_status: 'wirausaha',
        company: 'Dina Cake',
        domisili: 'Kudus',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'john.english@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'John Prasetyo',
        phone: '081234567896',
        angkatan: 2015,
        role: 'alumni',
        job_status: 'swasta',
        company: 'English First',
        domisili: 'Jepara',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'sarah.mahasiswi@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Sarah Putri',
        phone: '081234567897',
        angkatan: 2015,
        role: 'alumni',
        job_status: 'mahasiswa',
        domisili: 'Semarang',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'doni.kontraktor@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Doni Firmansyah',
        phone: '081234567898',
        angkatan: 2005,
        role: 'alumni',
        job_status: 'wirausaha',
        company: 'Citra Land Property',
        domisili: 'Jepara',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    },
    {
        email: 'admin@ikasmansara.id',
        password: 'admin123',
        passwordConfirm: 'admin123',
        name: 'Admin IKA SMANSARA',
        phone: '081234567899',
        angkatan: 2000,
        role: 'admin',
        job_status: 'pns_bumn',
        domisili: 'Jepara',
        is_verified: true,
        verified_at: '2024-01-01 00:00:00.000Z'
    }
];

// Events Data
const eventsData = [
    {
        title: 'Jalan Sehat & Reuni Akbar 2026',
        description: 'Acara tahunan jalan sehat dan reuni akbar alumni SMAN 1 Jepara dengan berbagai doorprize menarik.',
        date: '2026-08-20 08:00:00.000Z',
        time: '08:00 WIB',
        location: 'SMAN 1 Jepara',
        status: 'active',
        enable_sponsorship: true,
        enable_donation: true,
        donation_target: 50000000,
        donation_description: 'Donasi untuk kegiatan reuni akbar'
    }
];

// Donations Data
const donationsData = [
    {
        title: 'Renovasi Masjid Sekolah SMAN 1 Jepara',
        description: 'Mari bantu adik-adik kita beribadah dengan nyaman. Program renovasi masjid sekolah yang sudah berusia lebih dari 30 tahun.',
        target_amount: 50000000,
        collected_amount: 35000000,
        deadline: '2026-12-31 23:59:59.000Z',
        organizer: 'Pengurus IKA SMANSARA',
        category: 'infrastruktur',
        priority: 'urgent',
        status: 'active',
        donor_count: 145,
        banner_url: 'https://images.unsplash.com/photo-1541829070764-84a7d30dd3f3?w=800'
    },
    {
        title: 'Beasiswa Anak Alumni Kurang Mampu',
        description: 'Program beasiswa untuk anak-anak alumni yang kurang mampu agar tetap bisa melanjutkan pendidikan.',
        target_amount: 20000000,
        collected_amount: 12500000,
        deadline: '2026-12-31 23:59:59.000Z',
        organizer: 'Pengurus IKA SMANSARA',
        category: 'pendidikan',
        priority: 'normal',
        status: 'active',
        donor_count: 87,
        banner_url: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800'
    },
    {
        title: 'Dana Tali Kasih (Alumni Sakit)',
        description: 'Dana untuk membantu alumni yang sedang sakit dan membutuhkan biaya pengobatan.',
        target_amount: 10000000,
        collected_amount: 2000000,
        deadline: '2027-06-30 23:59:59.000Z',
        organizer: 'Pengurus IKA SMANSARA',
        category: 'kesehatan',
        priority: 'normal',
        status: 'active',
        donor_count: 23,
        banner_url: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800'
    }
];

// News Data
const newsData = [
    {
        title: 'Tim Basket SMAN 1 Jepara Juara DBL Central Java Series 2023',
        slug: 'tim-basket-smansara-juara-dbl-2023',
        summary: 'Tim basket SMAN 1 Jepara berhasil meraih juara dalam kompetisi DBL Central Java Series 2023.',
        content: 'Tim basket SMAN 1 Jepara berhasil meraih juara dalam kompetisi DBL Central Java Series 2023. Prestasi membanggakan ini diraih setelah mengalahkan SMAN 3 Semarang di final dengan skor 78-65.',
        category: 'prestasi',
        status: 'published',
        publish_date: '2024-01-20 10:00:00.000Z',
        view_count: 234
    },
    {
        title: 'Reuni Perak Angkatan 98 Berlangsung Meriah di Aula Sekolah',
        slug: 'reuni-perak-angkatan-98',
        summary: 'Reuni perak angkatan 1998 berlangsung meriah di aula SMAN 1 Jepara.',
        content: 'Reuni perak angkatan 1998 berlangsung meriah di aula SMAN 1 Jepara. Acara yang dihadiri lebih dari 150 alumni ini dimeriahkan dengan berbagai pertunjukan nostalgia.',
        category: 'kegiatan',
        status: 'published',
        publish_date: '2024-01-18 14:00:00.000Z',
        view_count: 189
    },
    {
        title: 'Jalan Sehat HUT SMANSARA ke-60 Siap Digelar Minggu Depan',
        slug: 'jalan-sehat-hut-smansara-60',
        summary: 'Panitia akan menggelar acara jalan sehat yang terbuka untuk umum.',
        content: 'Dalam rangka memperingati HUT ke-60 SMAN 1 Jepara, panitia akan menggelar acara jalan sehat yang terbuka untuk umum. Peserta akan mendapat doorprize menarik.',
        category: 'pengumuman',
        status: 'published',
        publish_date: '2024-01-15 09:00:00.000Z',
        view_count: 456
    },
    {
        title: 'Seminar Karir untuk Siswa Kelas XII bersama Alumni Sukses',
        slug: 'seminar-karir-siswa-kelas-xii',
        summary: 'IKA SMANSARA mengadakan seminar karir untuk siswa kelas XII.',
        content: 'IKA SMANSARA mengadakan seminar karir untuk siswa kelas XII dengan menghadirkan alumni-alumni sukses dari berbagai bidang profesi.',
        category: 'kegiatan',
        status: 'published',
        publish_date: '2024-01-10 08:00:00.000Z',
        view_count: 123
    }
];

// Forum Posts Data
const forumPostsData = [
    {
        content: 'Halo teman-teman, ada yang punya info kontraktor di daerah Jepara untuk renovasi rumah? Mohon infonya ya terima kasih.',
        category: 'bisnis',
        visibility: 'public',
        like_count: 12,
        comment_count: 5,
        is_pinned: false,
        status: 'active'
    },
    {
        content: 'Ketemu foto lama pas acara Kartinian tahun 97. Ada yang masih ingat momen ini? 😄 #Nostalgia',
        category: 'nostalgia',
        visibility: 'alumni_only',
        like_count: 45,
        comment_count: 12,
        is_pinned: false,
        status: 'active',
        image_url: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=500'
    }
];

// Forum Comments Data
const forumCommentsData = [
    {
        content: 'Wah seru nih, kabari ya infonya!'
    },
    {
        content: 'Setuju, kangen banget sama kantin bu ijah.'
    }
];

// Loker (Job Listings) Data
const lokerData = [
    {
        position: 'Senior Accounting Staff',
        company: 'PT. Telkom Indonesia (Persero)',
        job_type: 'fulltime',
        location: 'Jakarta Selatan',
        salary_range: 'IDR 8jt - 12jt',
        description: 'Kami mencari Senior Accounting Staff yang berpengalaman untuk bergabung dengan tim finance kami. Requirements: S1 Akuntansi, pengalaman minimal 3 tahun, menguasai SAP.',
        apply_link: 'https://recruitment.telkom.co.id',
        status: 'approved'
    },
    {
        position: 'Graphic Designer Intern',
        company: 'Gojek Indonesia',
        job_type: 'internship',
        location: 'WFH / Remote',
        salary_range: 'Paid Intern',
        description: 'Kesempatan magang untuk mahasiswa desain grafis dengan passion tinggi. Requirements: Mahasiswa semester 5+, menguasai Adobe Creative Suite.',
        apply_link: 'https://career.gojek.com/intern',
        status: 'approved'
    },
    {
        position: 'Arsitek Renovasi Rumah',
        company: 'Citra Land Property',
        job_type: 'freelance',
        location: 'Jepara Kota',
        salary_range: 'Per Proyek',
        description: 'Mencari arsitek untuk proyek renovasi rumah di area Jepara. Requirements: S1 Arsitektur, portofolio kuat, bisa AutoCAD & SketchUp.',
        apply_link: 'https://wa.me/6281234567898',
        status: 'approved'
    }
];

// Market Products Data
const marketData = [
    {
        name: 'Katering Nasi Box "Bu Sri"',
        description: 'Nasi box dengan berbagai pilihan lauk pauk homemade. Cocok untuk acara kantor atau keluarga.',
        price: 25000,
        category: 'kuliner',
        location: 'Jepara',
        contact: '081234567893',
        status: 'approved'
    },
    {
        name: 'Jasa Desain Arsitek',
        description: 'Jasa desain arsitektur untuk rumah tinggal, ruko, dan bangunan komersial.',
        price: 1,
        category: 'jasa_professional',
        location: 'Online',
        contact: '081234567894',
        status: 'approved'
    },
    {
        name: 'Kue Kering Lebaran Premium',
        description: 'Aneka kue kering lebaran premium homemade. Nastar, kastengel, putri salju, dll.',
        price: 85000,
        category: 'kuliner',
        location: 'Kudus',
        contact: '081234567895',
        status: 'approved'
    },
    {
        name: 'Kursus Bahasa Inggris Private',
        description: 'Les privat bahasa Inggris untuk semua level. Conversation, TOEFL, IELTS.',
        price: 500000,
        category: 'jasa_professional',
        location: 'Jepara',
        contact: '081234567896',
        status: 'approved'
    }
];

// Memory/Photos Data - Note: Memories require file upload, skipping for now
const memoryData = [
    {
        description: 'Foto bersama saat acara Kartinian tahun 1997',
        year: 1997,
        is_approved: true
    },
    {
        description: 'Momen kebersamaan saat reuni perak angkatan 1998',
        year: 2023,
        is_approved: true
    }
];

// ============================================
// SEEDER FUNCTIONS
// ============================================

/**
 * Store seeded IDs for cleanup
 */
const seededIds = {
    users: [],
    events: [],
    donations: [],
    news: [],
    forum_posts: [],
    forum_comments: [],
    loker: [],
    market_products: [],
    memories: []
};

/**
 * Seed Users
 */
async function seedUsers(pb) {
    console.log('\n📦 Seeding Users...');
    for (const userData of usersData) {
        try {
            // Check if user already exists
            const existing = await pb.collection('users').getList(1, 1, {
                filter: `email = "${userData.email}"`
            });

            if (existing.totalItems > 0) {
                console.log(`  ⏭️  User "${userData.email}" already exists, skipping...`);
                seededIds.users.push(existing.items[0].id);
                continue;
            }

            const record = await pb.collection('users').create(userData);
            seededIds.users.push(record.id);
            console.log(`  ✅ Created user: ${userData.name}`);
        } catch (error) {
            console.error(`  ❌ Failed to create user "${userData.email}":`, error.message);
        }
    }
}

/**
 * Seed Events
 */
async function seedEvents(pb, adminUserId) {
    console.log('\n📅 Seeding Events...');
    for (const eventData of eventsData) {
        try {
            const record = await pb.collection('events').create({
                ...eventData,
                created_by: adminUserId
            });
            seededIds.events.push(record.id);
            console.log(`  ✅ Created event: ${eventData.title}`);
        } catch (error) {
            console.error(`  ❌ Failed to create event:`, error.message);
        }
    }
}

/**
 * Seed Donations
 */
async function seedDonations(pb, adminUserId) {
    console.log('\n💰 Seeding Donations...');
    for (const donationData of donationsData) {
        try {
            const record = await pb.collection('donations').create({
                ...donationData,
                created_by: adminUserId
            });
            seededIds.donations.push(record.id);
            console.log(`  ✅ Created donation: ${donationData.title}`);
        } catch (error) {
            console.error(`  ❌ Failed to create donation:`, error.message);
        }
    }
}

/**
 * Seed News
 */
async function seedNews(pb, adminUserId) {
    console.log('\n📰 Seeding News...');
    for (const newsItem of newsData) {
        try {
            const record = await pb.collection('news').create({
                ...newsItem,
                author: adminUserId
            });
            seededIds.news.push(record.id);
            console.log(`  ✅ Created news: ${newsItem.title}`);
        } catch (error) {
            console.error(`  ❌ Failed to create news:`, error.message);
        }
    }
}

/**
 * Seed Forum Posts and Comments
 */
async function seedForum(pb, userIds) {
    console.log('\n💬 Seeding Forum Posts...');
    for (let i = 0; i < forumPostsData.length; i++) {
        try {
            const postData = forumPostsData[i];
            const userId = userIds[i] || userIds[0]; // Assign different users

            const record = await pb.collection('forum_posts').create({
                ...postData,
                user: userId
            });
            seededIds.forum_posts.push(record.id);
            console.log(`  ✅ Created forum post by user ${userId}`);

            // Add comments to first post
            if (i === 0 && seededIds.forum_posts.length > 0) {
                for (let j = 0; j < forumCommentsData.length; j++) {
                    try {
                        const commentRecord = await pb.collection('forum_comments').create({
                            post: record.id,
                            user: userIds[j + 2] || userIds[0],
                            content: forumCommentsData[j].content
                        });
                        seededIds.forum_comments.push(commentRecord.id);
                        console.log(`    ✅ Created comment`);
                    } catch (error) {
                        console.error(`    ❌ Failed to create comment:`, error.message);
                    }
                }
            }
        } catch (error) {
            console.error(`  ❌ Failed to create forum post:`, error.message);
        }
    }
}

/**
 * Seed Loker (Job Listings)
 */
async function seedLoker(pb, userIds) {
    console.log('\n💼 Seeding Loker...');
    const postedByUsers = [userIds[0], userIds[7], userIds[8]]; // Budi, Sarah, Doni

    for (let i = 0; i < lokerData.length; i++) {
        try {
            const record = await pb.collection('loker').create({
                ...lokerData[i],
                user: postedByUsers[i] || userIds[0]
            });
            seededIds.loker.push(record.id);
            console.log(`  ✅ Created loker: ${lokerData[i].position}`);
        } catch (error) {
            console.error(`  ❌ Failed to create loker:`, error.message);
        }
    }
}

/**
 * Seed Market Products
 */
async function seedMarket(pb, userIds) {
    console.log('\n🛒 Seeding Market Products...');
    const sellerUsers = [userIds[3], userIds[4], userIds[5], userIds[6]]; // Sri, Rian, Dina, John

    for (let i = 0; i < marketData.length; i++) {
        try {
            const userId = sellerUsers[i] || userIds[0];
            console.log(`  📝 Creating product: ${marketData[i].name} with user: ${userId}`);
            const record = await pb.collection('market').create({
                ...marketData[i],
                user: userId
            });
            seededIds.market_products.push(record.id);
            console.log(`  ✅ Created product: ${marketData[i].name}`);
        } catch (error) {
            console.error(`  ❌ Failed to create product "${marketData[i].name}":`, error.message);
            if (error.data) {
                console.error(`     Details:`, JSON.stringify(error.data, null, 2));
            }
        }
    }
}

/**
 * Seed Memories/Photos
 * Note: Memories require file upload for 'image' field, skipping for now
 */
async function seedMemories(pb, userIds) {
    console.log('\n📷 Seeding Memories...');
    console.log('  ⚠️  Skipping memories - requires file upload for image field');
    // Memories require file upload which cannot be done with URL data
    // for (let i = 0; i < memoryData.length; i++) {
    //     try {
    //         const record = await pb.collection('memories').create({
    //             ...memoryData[i],
    //             user: userIds[i + 2] || userIds[0]
    //         });
    //         seededIds.memories.push(record.id);
    //         console.log(`  ✅ Created memory`);
    //     } catch (error) {
    //         console.error(`  ❌ Failed to create memory:`, error.message);
    //     }
    // }
}

// ============================================
// MAIN SEEDER FUNCTIONS
// ============================================

/**
 * Seed all data (UP)
 */
async function seedUp() {
    console.log('🌱 Starting database seeding...\n');
    console.log('═'.repeat(50));

    try {
        const pb = await authenticateAdmin();

        // 1. Seed Users first
        await seedUsers(pb);

        // Get admin user ID for relations
        const adminUser = await pb.collection('users').getList(1, 1, {
            filter: 'role = "admin"'
        });
        const adminUserId = adminUser.items[0]?.id;

        if (!adminUserId) {
            throw new Error('Admin user not found. Please run seed users first.');
        }

        // 2. Seed Events
        await seedEvents(pb, adminUserId);

        // 3. Seed Donations
        await seedDonations(pb, adminUserId);

        // 4. Seed News
        await seedNews(pb, adminUserId);

        // 5. Seed Forum
        await seedForum(pb, seededIds.users);

        // 6. Seed Loker
        await seedLoker(pb, seededIds.users);

        // 7. Seed Market
        await seedMarket(pb, seededIds.users);

        // 8. Seed Memories
        await seedMemories(pb, seededIds.users);

        console.log('\n' + '═'.repeat(50));
        console.log('✅ Database seeding completed successfully!');
        console.log('═'.repeat(50));

        // Summary
        console.log('\n📊 Seeding Summary:');
        console.log(`   Users:         ${seededIds.users.length}`);
        console.log(`   Events:        ${seededIds.events.length}`);
        console.log(`   Donations:     ${seededIds.donations.length}`);
        console.log(`   News:          ${seededIds.news.length}`);
        console.log(`   Forum Posts:   ${seededIds.forum_posts.length}`);
        console.log(`   Forum Comments:${seededIds.forum_comments.length}`);
        console.log(`   Loker:         ${seededIds.loker.length}`);
        console.log(`   Market:        ${seededIds.market_products.length}`);
        console.log(`   Memories:      ${seededIds.memories.length}`);

    } catch (error) {
        console.error('\n❌ Seeding failed:', error.message);
        process.exit(1);
    }
}

/**
 * Remove all seeded data (DOWN)
 */
async function seedDown() {
    console.log('🗑️  Removing seeded data...\n');
    console.log('═'.repeat(50));

    try {
        const pb = await authenticateAdmin();

        // Delete in reverse order (to respect foreign key constraints)
        const collectionsToClean = [
            'memories',
            'market',
            'loker',
            'forum_likes',
            'forum_comments',
            'forum_posts',
            'donation_transactions',
            'event_tickets',
            'news',
            'donations',
            'events'
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

        // Delete seeded users (except first admin if needed)
        console.log('\n🗑️  Cleaning users...');
        try {
            const users = await pb.collection('users').getFullList({
                filter: 'email ~ "@example.com"'
            });
            for (const user of users) {
                try {
                    await pb.collection('users').delete(user.id);
                    console.log(`  ✅ Deleted user: ${user.email}`);
                } catch (error) {
                    console.error(`  ⚠️  Could not delete user ${user.email}:`, error.message);
                }
            }
            console.log(`  📦 Cleaned ${users.length} seeded users`);
        } catch (error) {
            console.log('  ⏭️  Could not clean users:', error.message);
        }

        console.log('\n' + '═'.repeat(50));
        console.log('✅ Seeded data removed successfully!');
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
    seedDown();
} else {
    seedUp();
}

export { seedUp, seedDown };
