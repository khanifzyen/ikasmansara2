# IKA SMANSARA

**IKA SMANSARA** adalah platform digital untuk **Ikatan Alumni SMAN 1 Jepara** yang menghubungkan alumni, sekolah, dan masyarakat umum dalam satu ekosistem terintegrasi.

## 🎯 Tujuan Utama

Memfasilitasi komunikasi, kolaborasi, dan aktivitas komunitas alumni SMAN 1 Jepara melalui fitur-fitur digital modern.

---

## 📁 Struktur Project

| Folder | Deskripsi |
|--------|-----------|
| `ika_smansara/` | Aplikasi mobile **Flutter** (Android, iOS, Web) |
| `lofi/` | Hi-Fi prototype web untuk **User** (HTML/CSS/JS) |
| `lofi-admin/` | Hi-Fi prototype web untuk **Admin Panel** |
| `migration/` | Tools migrasi database & seeder untuk PocketBase |
| `pb_hooks/` | Backend hooks PocketBase (payment, ticketing, webhooks) |

---

## 🔧 Tech Stack

- **Mobile App**: Flutter + Dart (Clean Architecture + BLoC)
- **Backend**: PocketBase (Auth, Database, Realtime)
- **Payment**: Midtrans (Snap Token + Webhook)
- **Prototype**: Vanilla HTML, CSS, JavaScript

---

## 👥 Role Pengguna

| Role | Deskripsi | Fitur Utama |
|------|-----------|-------------|
| **Alumni** | Lulusan terverifikasi SMAN 1 Jepara | E-KTA, Direktori, Loker, Market, Forum, Event |
| **Umum/Public** | Staff, guru, atau masyarakat umum | Berita, Donasi, Market (view-only) |
| **Admin** | Pengelola sistem | Manajemen User, Konten, Event, Keuangan |

---

## ✨ Fitur Utama

### 📋 Autentikasi & Profil
- Login & Register (Alumni / Umum)
- Verifikasi status alumni
- E-KTA digital dengan QR Code

### 🎟️ Event & Tiket
- Daftar event (reuni, jalan sehat, dll)
- Pemesanan tiket multi-jenis
- Sub-event registration (donor darah, cek kesehatan)
- QR Code tiket untuk check-in
- Integrasi pembayaran Midtrans

### 💰 Donasi
- Kampanye donasi (infrastruktur, pendidikan, sosial)
- Donasi terkait event
- Tracking riwayat & status donasi
- Pembayaran via Midtrans

### 💼 Loker (Lowongan Kerja)
- Posting lowongan kerja antar-alumni
- Filter berdasarkan tipe pekerjaan & lokasi
- Approval sistem oleh admin

### 🛒 Market
- Marketplace komunitas alumni
- Jual-beli produk/jasa
- Kategori: Kuliner, Fashion, Jasa, Properti

### 💬 Forum
- Diskusi antar-pengguna
- Kategori: Karir, Nostalgia, Bisnis, Umum
- Komentar & Like

### 📰 Berita
- Portal informasi sekolah & alumni
- Kategori: Prestasi, Kegiatan, Pengumuman, Alumni Sukses

### 📸 Kenangan (Memories)
- Galeri foto kenangan sekolah
- Upload & approval sistem

---

## 🗃️ Database Collections (PocketBase)

- `users` - Pengguna dengan role & verifikasi
- `events`, `event_tickets`, `event_bookings` - Sistem event & tiket
- `donations`, `donation_transactions` - Kampanye & transaksi donasi
- `forum_posts`, `forum_comments`, `forum_likes` - Forum diskusi
- `loker` - Lowongan kerja
- `market` - Marketplace produk
- `memories` - Galeri kenangan
- `news` - Berita & artikel
- `midtrans_logs` - Audit trail pembayaran
- `notifications`, `activity_logs` - Notifikasi & logging

---

## 🔗 Integrasi Eksternal

- **Midtrans**: Payment gateway (QRIS, VA, e-Wallet)
- **Bluetooth Printer**: Print tiket event via thermal printer

---

*Dikembangkan untuk komunitas IKA SMANSARA*
