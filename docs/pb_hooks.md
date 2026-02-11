# Dokumentasi PocketBase Hooks (`pb_hooks`)

Dokumen ini berisi analisis detail mengenai *server-side hooks* yang saat ini aktif di direktori `pb_hooks/`. Hooks ini ditulis dalam JavaScript (ES5+) dan dijalankan oleh engine Goya di dalam PocketBase.

## Ringkasan Fungsionalitas

Secara garis besar, hooks yang ada menangani 3 domain utama:
1.  **Event & Payment:** Integrasi dengan Midtrans, pembuatan booking ID, dan generasi tiket.
2.  **User Management:** Penomoran otomatis anggota (nomor urut global & angkatan).
3.  **Utility & Testing:** Endpoint testing dan internal tools.

---

## 1. Event & Payment (`event_midtrans_payment.pb.js`, `midtrans_notification.pb.js`, `ticket_generation.pb.js`)

### A. `event_midtrans_payment.pb.js`
Hook yang berjalan saat **Record Booking Dibuat** (`onRecordCreateRequest` untuk `event_bookings`).

*   **Pemuatan Environment Variable:**
    *   Memuat file `.env` secara manual menggunakan `$os.readFile` untuk mendapatkan `MIDTRANS_SERVER_KEY`.
    *   *Fallback* ke `$os.getenv` jika file tidak ditemukan.
*   **Booking ID Generation:**
    *   Mengambil konfigurasi format dari event terkait (`booking_id_format` atau default `{CODE}-{YEAR}-{SEQ}`).
    *   Increment field `last_booking_seq` pada collection `events`.
    *   Mengisi field `booking_id` pada record baru.
*   **Integrasi Midtrans Snap:**
    *   Jika `payment_status == 'pending'` dan `total_price > 0`, hook akan request ke API Midtrans.
    *   Payload mencakup: `order_id`, `gross_amount`, data customer (nama, email, no.hp), dan `enabled_payments`.
    *   Jika sukses, menyimpan `snap_token` dan `snap_redirect_url` ke record.
    *   Mendukung mode Sandbox (jika key diawali `SB-`) dan Production.

### B. `midtrans_notification.pb.js`
Custom API Endpoint (`POST /api/midtrans/notification`) untuk menerima Webhook dari Midtrans.

*   **Penerimaan Data:** Menerima JSON payload dari Midtrans (`order_id`, `transaction_status`, `fraud_status`, dll).
*   **Audit Trail:** Menyimpan seluruh payload notifikasi ke collection `midtrans_logs` untuk keperluan debugging/audit.
*   **Update Status Booking:**
    *   Mencari record `event_bookings` berdasarkan `booking_id`.
    *   Mengupdate `payment_status` berdasarkan status transaksi:
        *   `capture` (accept) / `settlement` -> **paid**
        *   `cancel` / `deny` / `expire` -> **failed** / **expired**
        *   `pending` -> **pending**
    *   Mengupdate field `payment_method` dan `payment_date`.
*   **Pemicu Lanjutan:** Perubahan status menjadi `paid` akan men-trigger hook `ticket_generation.pb.js`.

### C. `ticket_generation.pb.js`
Hook yang berjalan saat **Record Booking Diupdate** (`onRecordAfterUpdateSuccess` untuk `event_bookings`).

*   **Trigger:** Hanya berjalan jika `payment_status` berubah menjadi `paid`.
*   **Idempotency:** Mengecek apakah tiket untuk booking tersebut sudah ada di `event_booking_tickets`. Jika ada, proses dihentikan (mencegah duplikasi).
*   **Robust Metadata Parsing:**
    *   Mendukung parsing dari format JSON string, byte array (`[]uint8`), maupun object.
    *   **Null-safety:** Memiliki pengecekan khusus untuk nilai `"null"` (string atau byte array) yang sering dikembalikan PocketBase untuk field JSON kosong.
    *   Memastikan `items` selalu berupa array untuk mencegah *runtime crash*.
*   **Logika Pembuatan Tiket (Dua Jalur):**
    1.  **Manual Booking (Fallback):** Jika terdeteksi `manual_ticket_count > 0`, tiket digenerate berdasarkan jumlah dan tipe manual tersebut. Ini tetap diproses meskipun metadata kosong/null.
    2.  **App/Regular Booking:** Loop setiap item di metadata (cart), generate tiket sesuai quantity (`qty`) dan menyertakan `selected_options` (opsi tiket seperti ukuran kaos).
*   **Ticket ID Generation:** Format tiket diambil dari event (`ticket_id_format` atau default `TIX-{CODE}-{SEQ}`).
*   **Update Counter:**
    *   Mengupdate `sold` count di collection `event_tickets`.
    *   Mengupdate `last_ticket_seq` di collection `events`.
*   **Data Tiket:** Setiap tiket disimpan di `event_booking_tickets` dengan status awal `checked_in: false` dan `shirt_picked_up: false`.

---

## 2. User Management (`users.pb.js`)

Hook yang berjalan saat **User Baru Mendaftar** (`onRecordCreate` untuk `users`).

*   **Nomor Urut Global:**
    *   Mengecek collection `registration_sequences` dengan `year = 0`.
    *   Increment `last_number` dan assign ke `no_urut_global` user.
*   **Nomor Urut Angkatan:**
    *   Mengecek collection `registration_sequences` dengan `year = {angkatan_user}`.
    *   Jika sequence tahun tersebut belum ada, otomatis dibuat baru.
    *   Increment `last_number` dan assign ke `no_urut_angkatan` user.
*   **Error Handling:** Jika gagal generate sequence, proses registrasi user akan dibatalkan (throw error).

---

## 3. Utility & Testing

### A. `test_hello.pb.js`
Menyediakan endpoint sederhana untuk tes konektivitas hook.
*   `GET /api/hello`: Return JSON `{ message: "Hello World from GET" }`.
*   `POST /api/hello`: Return JSON `{ message: "Hello World from POST", received_data: ... }`.

### B. `test_internal.pb.js`
Fitur internal untuk testing dari console server.
*   **Console Command:** Menambahkan command `./pocketbase test_post`.
*   **Fungsi:** Mengirim HTTP POST request internal ke `http://127.0.0.1:8090/api/hello` untuk memverifikasi bahwa *internal network calls* (seperti ke Midtrans) berfungsi dengan baik.

---

## Catatan Teknis (Gotchas)

1.  **Manual .env Parsing:** Hook tidak secara otomatis mewarisi environment variables dari shell induk di beberapa environment (terutama Supervisor/Panel), sehingga `event_midtrans_payment.pb.js` memiliki logika khusus untuk membaca file `.env` secara manual dari disk.
2.  **JSVM Compatibility:** Kode ditulis dengan gaya ES5 (var/let, function) dan menggunakan API bawaan PocketBase Goya (`$app`, `$os`, `$http`). Penggunaan `Buffer` di-polyfilled atau didukung oleh environment PocketBase terbaru.
3.  **Concurrency:** Penanganan sequence number (`last_booking_seq`, `last_ticket_seq`, `no_urut_*`) tidak menggunakan database transaction locking yang ketat (seperti `SELECT FOR UPDATE`), namun cukup aman untuk traffic moderat karena sifat single-threaded event loop JSVM di PocketBase (per request).
