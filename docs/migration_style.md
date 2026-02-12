# PocketBase Migration Style Guide

Project ini menggunakan mekanisme migrasi skema database **custom berbasis Node.js** (`migration/`), bukan menggunakan fitur migrasi bawaan PocketBase (Go) atau tools eksternal lainnya. Pendekatan ini dipilih untuk fleksibilitas dan kemudahan integrasi dengan workflow JavaScript/TypeScript.

## Arsitektur Migrasi

Arsitektur migrasi terdiri dari tiga komponen utama:

1.  **Runner (`migration/index.js`)**: Script utama yang mengeksekusi file-file migrasi secara berurutan.
2.  **Client Helper (`migration/pb-client.js`)**: Wrapper di atas SDK PocketBase yang menyediakan fungsi utilitas seperti otentikasi admin dan logika `upsertCollection`.
3.  **Collection Migrations (`migration/collections/*.js`)**: File definisi skema untuk setiap collection (atau grup collection terkait).

### Struktur Direktori

```
migration/
├── .env                # Environment variables (URL, Admin Credentials)
├── index.js            # Entry point (Runner)
├── pb-client.js        # PocketBase SDK Wrapper & Helpers
└── collections/        # File definisi migrasi
    ├── 01_users.js
    ├── 02_events.js
    ├── 03_donations.js
    └── ...
```

## Cara Kerja (`upsertCollection`)

Inti dari sistem ini adalah fungsi `upsertCollection` di `pb-client.js`. Fungsi ini bersifat **idempotent**, artinya aman dijalankan berkali-kali.

Logika `upsertCollection`:
1.  Cek apakah collection sudah ada (`getCollection`).
2.  **Jika Belum Ada:** Create collection baru dengan skema lengkap (fields, indexes, rules).
3.  **Jika Sudah Ada:**
    *   Bandingkan fields yang didefinisikan di kode dengan yang ada di database using loop.
    *   Jika ada field baru, tambahkan.
    *   Jika ada perubahan properti (seperti `required` atau `type`), update field tersebut.
    *   Merge indexes (menambahkan index baru tanpa menghapus yang lama).
    *   Cek dan update API Rules (`listRule`, `viewRule`, dll) jika berbeda.

> **Note:** Script ini **TIDAK MENGHAPUS** field atau collection yang sudah ada di database tapi tidak ada di kode (non-destructive), kecuali untuk properti spesifik yang ditimpa.

## Panduan Membuat Migrasi Baru

### 1. Buat File Baru
Buat file di `migration/collections/` dengan penomoran urut, misal `10_new_feature.js`.

### 2. Import Helper
```javascript
import { authenticateAdmin, upsertCollection, getCollectionId } from '../pb-client.js';
```

### 3. Definisikan Fungsi Migrasi
Buat fungsi `async` yang melakukan migrasi. Gunakan `getCollectionId` jika butuh relasi ke collection lain.

```javascript
async function migrateNewFeature() {
    console.log('Starting Migration...');
    const pb = await authenticateAdmin();

    // Ambil ID collection lain untuk relasi (jika perlu)
    const usersId = await getCollectionId(pb, 'users');

    await upsertCollection(pb, {
        name: 'new_feature',
        type: 'base',
        // API Rules (kosongkan string untuk public, null untuk admin-only)
        listRule: '@request.auth.id != ""', 
        viewRule: '@request.auth.id != ""',
        createRule: '@request.auth.id != ""',
        updateRule: '@request.auth.id = user.id',
        deleteRule: null, 
        fields: [
            { name: 'title', type: 'text', required: true },
            { 
                name: 'user', 
                type: 'relation', 
                collectionId: usersId, 
                maxSelect: 1 
            },
            // ... field lainnya
        ],
        indexes: [
            'CREATE INDEX idx_feature_user ON new_feature (user)'
        ]
    });
}

// Boilerplate agar bisa dijalankan standalone atau via runner
if (import.meta.url === `file://${process.argv[1]}`) {
    migrateNewFeature().catch(console.error);
}

export { migrateNewFeature };
```

### 4. Daftarkan di Runner
Edit `migration/index.js`, import fungsi baru, dan panggil di dalam `runAllMigrations`.

```javascript
import { migrateNewFeature } from './collections/10_new_feature.js';

// ...
await migrateNewFeature();
// ...
```

## Menjalankan Migrasi

1.  Pastikan file `.env` di folder `migration/` sudah terisi dengan kredensial Admin PocketBase.
2.  Jalankan perintah:

```bash
cd migration
npm run migrate
```
