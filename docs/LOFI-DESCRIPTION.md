# Lofi Prototype Documentation

Dokumentasi lengkap halaman-halaman HTML dalam folder `lofi/` yang merupakan prototype user-facing dari aplikasi IKA SMANSARA.

---

## Daftar Isi

1. [Authentication & Onboarding Flow](#1-authentication--onboarding-flow)
2. [Dashboard](#2-dashboard)
3. [E-KTA (Kartu Tanda Anggota Digital)](#3-e-kta-kartu-tanda-anggota-digital)
4. [Event & Ticketing](#4-event--ticketing)
5. [Donation](#5-donation)
6. [Career & Job Vacancy (Loker)](#6-career--job-vacancy-loker)
7. [Marketplace](#7-marketplace)
8. [Forum](#8-forum)
9. [Profile](#9-profile)
10. [Directory](#10-directory)
11. [Navigation Structure](#11-navigation-structure)

---

## 1. Authentication & Onboarding Flow

### `index.html` — Splash Screen

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Layar pembuka aplikasi dengan logo dan animasi loading |
| **Fungsi** | Auto-redirect ke `onboarding.html` setelah 3 detik |
| **Data** | Tidak ada |

### `onboarding.html` — Pengenalan Fitur

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Memperkenalkan manfaat utama aplikasi kepada user baru |
| **Fungsi** | Carousel 3 slide: (1) Koneksi Alumni, (2) Karir & Bisnis, (3) Kontribusi. Tombol "Skip" dan "Lanjut" mengarah ke `role-selection.html` |
| **Data** | Tidak ada |

### `role-selection.html` — Pemilihan Peran

| Aspek | Detail |
|-------|--------|
| **Tujuan** | User memilih peran: Alumni atau Umum/Staff |
| **Fungsi** | Kartu "Saya Alumni" → `register-alumni.html`; Kartu "Umum / Staff" → `register-public.html`. Link ke halaman login untuk user yang sudah terdaftar |
| **Data** | Tidak ada |

### `register-alumni.html` — Registrasi Alumni

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Formulir pendaftaran khusus alumni |
| **Fungsi** | Mengumpulkan data akun, data sekolah, dan profil terkini. Submit menampilkan alert sukses dan redirect ke `login.html` |
| **Data Dikumpulkan** | Nama, Email, No. WhatsApp, Password, Angkatan, Status Pekerjaan, Nama Instansi, Domisili |

### `register-public.html` — Registrasi Umum

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Formulir pendaftaran untuk non-alumni |
| **Fungsi** | Form sederhana dengan kategori user. Submit menampilkan alert sukses |
| **Data Dikumpulkan** | Nama, Kategori (Guru/Staff, Masyarakat Umum, Orang Tua Siswa), Email, Password |

### `login.html` — Halaman Login

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Autentikasi user |
| **Fungsi** | Login via email/password atau Google Sign-In (placeholder). Link "Lupa Password" dan link ke registrasi. Submit redirect ke `home.html` |
| **Data** | Email/No HP, Password |

---

## 2. Dashboard

### `home.html` — Dashboard Alumni

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Halaman utama setelah login untuk alumni terverifikasi |
| **Komponen Utama** | Header dengan greeting personal, notifikasi, foto profil. Preview E-KTA. Quick Menu: Donasi, Berita, Loker, Market. Section event mendatang. Section program donasi. Section berita terbaru |
| **Link Navigasi** | E-KTA → `ekta.html`, Event → `event-detail.html`, Donasi → `donation.html`, Loker → `loker.html`, Market → `market.html`, Berita → `news.html` |
| **Data Ditampilkan** | Nama user, Angkatan, Event (judul, tanggal, lokasi), Donasi (judul, progress), Berita (judul, tag) |

### `home-public.html` — Dashboard Publik/Guest

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Dashboard untuk user non-alumni atau guest |
| **Perbedaan dari Alumni** | Tidak ada E-KTA preview. Banner ajakan registrasi. Quick Menu berbeda: Berita, Donasi, Market, Tentang |
| **Data Ditampilkan** | Event, Donasi, Berita (sama dengan alumni) |

---

## 3. E-KTA (Kartu Tanda Anggota Digital)

### `ekta.html`

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Menampilkan kartu anggota digital alumni |
| **Fungsi** | Kartu dengan nama, angkatan, nomor member unik, dan QR Code. Opsi download dan share (placeholder) |
| **Data Ditampilkan** | Nama Alumni, Angkatan, Nomor Member, QR Code (generated dari member ID) |

---

## 4. Event & Ticketing

### `event-detail.html` — Detail Event

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Menampilkan informasi lengkap event dan fasilitas pembelian tiket |
| **Struktur** | Banner event, informasi dasar (tanggal, lokasi, deskripsi), 4 tab navigasi |

#### Tab 1: Tiket

| Fitur | Detail |
|-------|--------|
| **Pembelian Tiket** | Pilih jumlah tiket, pilih ukuran kaos (S/M/L/XL/XXL), lihat ringkasan harga |
| **Riwayat Tiket** | Daftar tiket yang sudah dibeli dengan status (Lunas, Menunggu, Kadaluarsa) |
| **Modal Detail** | QR Code tiket, detail pembelian, ukuran kaos |

#### Tab 2: Sub-event

| Fitur | Detail |
|-------|--------|
| **Daftar Aktivitas** | Health Check, Eye Check, Blood Donor |
| **Fungsi** | Registrasi/pembatalan aktivitas, QR Code untuk check-in |

#### Tab 3: Sponsorship

| Fitur | Detail |
|-------|--------|
| **Paket Sponsor** | Platinum (Rp 50jt), Gold (Rp 25jt), Silver (Rp 10jt) |
| **Detail** | Keuntungan per tier, tombol "Ajukan Sponsorship" |

#### Tab 4: Donasi

| Fitur | Detail |
|-------|--------|
| **Progress Donasi** | Bar progress dengan target dan terkumpul |
| **Donasi Personal** | Form donasi dengan nominal yang dapat diinput |

### `tiketku.html` — Riwayat Tiket Saya

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Melihat semua tiket yang dimiliki user |
| **Filter** | Status (Semua, Lunas, Menunggu, Kadaluarsa), Rentang tanggal |
| **Aksi per Status** | Lunas → Modal detail + QR; Menunggu → Modal pembayaran; Kadaluarsa → Alert info |
| **Data per Tiket** | Event, Tanggal, Status, ID Transaksi, Jumlah tiket, Ukuran kaos, Total harga |

### `donasiku.html` — Riwayat Donasi Saya

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Melihat semua donasi yang dilakukan user |
| **Filter** | Status (Semua, Berhasil, Menunggu, Gagal), Rentang tanggal |
| **Aksi per Status** | Berhasil → Alert terima kasih; Menunggu → Modal pembayaran; Gagal → Alert info |
| **Data per Donasi** | Judul program, Tanggal, Status, ID Transaksi, Nominal |

---

## 5. Donation

### `donation.html` — Daftar Program Donasi

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Menampilkan semua program donasi yang tersedia |
| **Struktur** | Campaign card dengan judul, deskripsi, progress bar, target, dan terkumpul |
| **Fungsi** | Tombol "Donasi Sekarang" mengarah ke `donation-detail.html` |
| **Data per Campaign** | Judul, Deskripsi, Target Dana, Dana Terkumpul, Persentase Progress |

---

## 6. Career & Job Vacancy (Loker)

### `loker.html` — Lowongan Kerja

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Menampilkan daftar lowongan kerja dari jaringan alumni |
| **Header** | Search box untuk posisi/perusahaan |
| **Filter Chips** | Semua, Fulltime, Internship, Freelance, Remote |
| **FAB** | Tombol "+" untuk posting loker baru → `loker-post.html` |

#### Data per Job Card

| Field | Contoh |
|-------|--------|
| Logo Perusahaan | Avatar berdasarkan inisial |
| Badge Tipe | Fulltime, Internship, Freelance |
| Posisi | Senior Accounting Staff |
| Perusahaan | PT. Telkom Indonesia |
| Lokasi | Jakarta Selatan |
| Gaji | IDR 8jt - 12jt |
| Diposting oleh | Nama alumni + angkatan |

---

## 7. Marketplace

### `market.html` — Marketplace Alumni

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Platform jual-beli produk/jasa antar alumni |
| **Header** | Search box untuk kuliner, jasa, fashion |
| **Filter Chips** | Semua, Kuliner, Jasa Pro, Fashion, Properti |
| **FAB** | Tombol "Jual" → `market-sell.html` |

#### Data per Product Card

| Field | Contoh |
|-------|--------|
| Gambar Produk | Foto produk/jasa |
| Nama | Katering Nasi Box "Bu Sri" |
| Penjual | Sri Wahyuni '98 • Jepara |
| Harga | Rp 25.000 atau "Hubungi Penjual" |

---

## 8. Forum

### `forum.html` — Forum Diskusi

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Ruang diskusi dan berbagi antar alumni |
| **Trigger Post** | Area "Apa yang Anda pikirkan?" untuk membuat post baru |
| **Tab Kategori** | Semua, Karir & Loker, Nostalgia, Bisnis |
| **FAB** | Tombol "+" untuk membuat post baru |

#### Komponen Feed Card

| Elemen | Detail |
|-------|--------|
| Avatar & Nama | Foto profil, nama poster, tag angkatan |
| Waktu | "2 jam yang lalu" |
| Konten | Teks post, opsional gambar |
| Actions | Like (dengan counter), Komentar (dengan counter) |

#### Modal Interaksi

| Modal | Fungsi |
|-------|--------|
| Buat Postingan | Textarea + attachment (foto, lokasi, emoji) |
| Daftar Likes | List user yang menyukai post |
| Komentar | List komentar + input komentar baru |

---

## 9. Profile

### `profile.html` — Profil Saya

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Menampilkan dan mengelola profil user |

#### Section Header

| Data | Contoh |
|-------|--------|
| Avatar | Foto profil dengan badge verified |
| Nama | Budi Santoso |
| Status | Alumni Angkatan 2010 |

#### Statistik User

| Stat | Keterangan |
|------|------------|
| Postingan | Jumlah post di forum |
| Lapak | Jumlah produk di marketplace |
| Donasi | Total nominal donasi |

#### Menu Navigasi

| Menu | Destination |
|------|-------------|
| Edit Biodata | `edit-profile.html` |
| Kartu Anggota (E-KTA) | `ekta.html` |
| Loker Saya | `my-loker.html` |
| Lapak Saya | `my-shop.html` |

#### Privasi & Keamanan

| Setting | Default |
|---------|---------|
| Tampilkan No HP | ON |
| Tampilkan Alamat | OFF |

#### Aksi

- Tombol "Keluar Akun" → `login.html`
- Info versi aplikasi

---

## 10. Directory

### `directory.html` — Direktori Alumni

| Aspek | Detail |
|-------|--------|
| **Tujuan** | Mencari dan terhubung dengan alumni lain |
| **Header** | Search box untuk nama, angkatan, atau instansi |
| **Filter Chips** | Semua, Angkatan, Pekerjaan, Domisili, Terdekat |
| **FAB** | Tombol peta untuk fitur lokasi (placeholder) |

#### Data per Alumni Card

| Field | Contoh |
|-------|--------|
| Avatar | Foto profil atau inisial |
| Nama | Andi Wijaya |
| Angkatan | 2008 |
| Pekerjaan | BUMN - Telkom |
| Aksi | Tombol "Connect" untuk minta kontak |

---

## 11. Navigation Structure

### Bottom Navigation Bar

Navigasi utama yang muncul di semua halaman:

| Icon | Label | Destination |
|------|-------|-------------|
| 🏠 | Home | `home.html` |
| ❤️ | Donasiku | `donasiku.html` |
| 📄 | Tiketku | `tiketku.html` |
| 💼 | Loker | `loker.html` |
| ☰ | Lainnya | Side Drawer |

### Side Drawer Menu

Menu tambahan yang diakses via "Lainnya":

| Icon | Label | Destination |
|------|-------|-------------|
| 👥 | Direktori | `directory.html` |
| 🛍️ | Market | `market.html` |
| 💬 | Forum | `forum.html` |
| 👤 | Profil | `profile.html` |

---

## Shared Components & Patterns

### UI Components

| Component | Usage |
|-----------|-------|
| `.btn-primary` | Tombol aksi utama (hijau) |
| `.btn-secondary` | Tombol aksi sekunder (outline) |
| `.chip` | Filter/kategori pill |
| `.card` | Container konten dengan shadow |
| `.modal-overlay` | Background overlay untuk modal |
| `.modal-content` | Container konten modal (slide-up) |
| `.fab` | Floating Action Button |
| `.bottom-nav` | Fixed bottom navigation |
| `.side-drawer` | Side navigation drawer |

### JavaScript Patterns

| Pattern | Description |
|---------|-------------|
| `navigateTo(page)` | Fungsi navigasi halaman |
| `goBack()` | Kembali ke halaman sebelumnya |
| `openModal() / closeModal()` | Toggle modal visibility |
| `toggleLike(btn)` | Toggle like state dengan counter |
| `filterCards(keyword)` | Filter kartu berdasarkan keyword |

### Data Flow (Mock)

Semua data dalam prototype ini bersifat **mock/static**. Tidak ada koneksi ke backend. Interaksi seperti:
- Login → langsung redirect tanpa validasi
- Pembelian tiket → alert sukses tanpa pemrosesan
- Donasi → alert sukses tanpa payment gateway
- Post forum → alert sukses tanpa penyimpanan

---

## File Structure

```
lofi/
├── index.html          # Splash screen
├── onboarding.html     # Onboarding slides
├── role-selection.html # Role picker
├── login.html          # Login page
├── register-alumni.html    # Alumni registration
├── register-public.html    # Public registration
├── home.html           # Alumni dashboard
├── home-public.html    # Public dashboard
├── ekta.html           # E-KTA digital card
├── event-detail.html   # Event detail + tabs
├── tiketku.html        # My tickets
├── donasiku.html       # My donations
├── donation.html       # Donation campaigns list
├── loker.html          # Job vacancies
├── market.html         # Marketplace
├── forum.html          # Discussion forum
├── profile.html        # User profile
├── directory.html      # Alumni directory
├── style.css           # Shared styles
└── script.js           # Shared scripts
```
