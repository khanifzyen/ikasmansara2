# Analisis Flow: Tab Peserta (Admin Event Dashboard)

Dokumen ini menjelaskan alur kerja (*flow*) untuk fitur Manajemen Peserta pada dashboard admin, mengacu pada `lofi-admin/event-dashboard.html` dan logika *backend* di `pb_hooks/`.

## 1. Arsitektur Data Terkait

Manajemen peserta melibatkan tiga entitas utama:
1.  **`event_bookings` (Order/Registrasi):** Menyimpan data induk transaksi, status pembayaran, dan informasi koordinator/pendaftar.
2.  **`event_booking_tickets` (Peserta/Tiket Individual):** Representasi setiap orang yang akan hadir. Satu *booking* bisa memiliki banyak tiket.
3.  **`event_tickets` (Master Tiket):** Definisi paket (VIP, Reguler, dll) dan kuota.

## 2. Alur Pembelian & Registrasi

### A. Melalui Aplikasi (User Self-Service)
1.  **Order:** User memilih tiket di aplikasi -> Record `event_bookings` dibuat (Status: `pending`).
2.  **Payment:** User membayar via Midtrans.
3.  **Webhook:** Midtrans mengirim notifikasi ke `midtrans_notification.pb.js` -> Status booking berubah menjadi `paid`.
4.  **Generation:** Hook `ticket_generation.pb.js` mendeteksi status `paid` -> Otomatis membuat record di `event_booking_tickets` berdasarkan jumlah tiket yang dibeli.
5.  **Visibility:** Peserta muncul di daftar admin sebagai status **Lunas**.

### B. Input Manual (Admin/Koordinator Cash)
1.  **Input:** Admin klik "+ Tambah Manual" -> Mengisi data koordinator, jumlah tiket, dan tipe tiket.
2.  **Booking:** Sistem membuat record `event_bookings` dengan `registration_channel` = `manual_cash` atau `manual_transfer` (Status: `pending`).
3.  **Validation:** Admin menerima uang tunai/bukti transfer, lalu mengubah status booking menjadi `paid` di UI.
4.  **Generation:** Hook `ticket_generation.pb.js` terpicu (karena status menjadi `paid`) -> Membuat tiket individual di `event_booking_tickets`.

## 3. Fitur Utama di Tab Peserta (Flutter Implementation)

### A. Daftar Peserta (List View)
*   **Data Source:** Mengambil dari `event_bookings` (untuk daftar transaksi) dan menyertakan relasi ke `event_booking_tickets` (untuk detail orangnya).
*   **Informasi Penting:**
    *   `booking_id`: ID unik untuk pencarian.
    *   `coordinator_name`: Nama pendaftar/koordinator.
    *   `payment_status`: Filter (`pending`, `paid`, `expired`).
    *   `registration_channel`: Mengetahui asal pendaftaran (App vs Manual).

### B. Modal Tambah Manual
Field yang dibutuhkan berdasarkan `SKEMA.md`:
*   `coordinator_name` (Text)
*   `coordinator_phone` (Text)
*   `coordinator_angkatan` (Number)
*   `manual_ticket_count` (Number)
*   `manual_ticket_type` (Relation to `event_tickets`)
*   `notes` (Text - misal: "Sudah bayar di rapat")

### C. Manajemen Status & Kelengkapan
Berdasarkan `lofi`, admin dapat melakukan:
1.  **Update Payment:** Klik pada badge "Pending" untuk ubah ke "Lunas".
2.  **Detail Peserta:** Membuka daftar orang di bawah satu *booking_id*.
3.  **Shirt Pickup:** Centang `shirt_picked_up` pada tiap `event_booking_tickets`.
4.  **Main Check-in:** Centang `checked_in` saat hari-H.

## 4. Referensi PocketBase Hooks (`pb_hooks`)

Sangat penting untuk memahami bahwa **Tiket tidak dibuat saat Booking dibuat**, tapi saat **Booking dibayar**.

*   **`ticket_generation.pb.js` (Baris 126+):** 
    Menangani logika pembuatan tiket manual. Hook ini akan membaca field `manual_ticket_count` dan membuat tiket sejumlah tersebut dengan nama koordinator sebagai nama default peserta. Tiket-tiket ini yang nantinya muncul saat admin melakukan Scan QR (Event Check-in).

*   **Idempotency (Penting):** 
    Hook ini mengecek apakah tiket sudah ada sebelum dibuat (baris 37+). Jika admin mengubah status `paid` -> `pending` -> `paid` lagi, tiket tidak akan digenerate dua kali.

---

## 5. Checklist Implementasi Flutter

- [ ] Integrasi `PocketBase` SDK untuk fetch `event_bookings` dengan filter `event`.
- [ ] UI List dengan Status Badge (Warna: Hijau=Lunas, Kuning=Pending, Merah=Batal).
- [ ] Detail Page/Modal untuk menampilkan list `event_booking_tickets` dari satu `booking_id`.
- [ ] Fitur Scan QR yang memanggil API update `checked_in` pada `event_booking_tickets`.
- [ ] Form Tambah Manual dengan validasi kuota (`event_tickets.sold` vs `quota`).
