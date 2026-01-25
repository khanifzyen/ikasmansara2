# IKA SMANSARA - Mobile App Prototype

Prototype aplikasi mobile untuk Ikatan Alumni SMAN 1 Jepara (IKA SMANSARA). Project ini berisi mockup High-Fidelity (Hi-Fi) menggunakan HTML, CSS, dan JavaScript Native.

## 📂 Struktur Project

Prototype utama terletak di dalam folder `lofi/`.
Semua file HTML dijalankan secara lokal dan menggunakan data mock (dummy) untuk simulasi fitur.

## 👥 Jenis User & Hak Akses

Aplikasi ini memiliki 2 peran utama (User Roles) dengan hak akses yang berbeda:

### 1. Alumni (`home.html`)
User yang terverifikasi sebagai lulusan SMAN 1 Jepara.
*   **Hak Akses Utama:**
    *   ✅ **E-KTA (Kartu Tanda Anggota):** Kartu digital eksklusif dengan Nomor Anggota & Angkatan.
    *   ✅ **Direktori Alumni:** Akses penuh mencari dan melihat daftar alumni lain.
    *   ✅ **Loker:** Akses penuh ke info lowongan kerja & posting loker.
    *   ✅ **Market:** Jual beli produk dalam komunitas.
    *   ✅ **Forum:** Diskusi penuh.
*   **Fitur Personal:**
    *   **Tiketku:** Riwayat pembelian tiket event dengan QR Code.
    *   **Donasiku:** Riwayat donasi pribadi dengan status pembayaran.

### 2. Umum / Staff (`home-public.html`)
User tamu, guru, staff sekolah, atau masyarakat umum yang belum/tidak terverifikasi sebagai alumni.
*   **Hak Akses Terbatas:**
    *   ❌ **Tidak ada E-KTA:** Banner digantikan dengan ajakan registrasi.
    *   ⚠️ **Loker (Terbatas):** Tidak muncul di Quick Menu utama (akses terbatas/read-only).
    *   ✅ **Berita:** Akses baca berita sekolah/alumni.
    *   ✅ **Donasi:** Bisa berpartisipasi dalam program donasi.
    *   ✅ **Market:** Bisa melihat produk (View Only/Contact Seller).
*   **Batasan:**
    *   Beberapa fitur akan memunculkan *alert* login/registrasi jika diakses.

## 🚀 Fitur Utama

Berikut adalah breakdown fitur yang tersedia dalam prototype:

### 🔐 Autentikasi
*   **Login**: Halaman masuk akun.
*   **Register Alumni**: Form pendaftaran khusus alumni dengan verifikasi tahun angkatan.
*   **Register Umum**: Form pendaftaran untuk masyarakat umum/staff.
*   **Role Selection**: Halaman awal memilih peran ("Saya Alumni" atau "Umum/Staff").

### 🏠 Dashboard & Navigasi
*   **Bottom Navigation**:
    1.  **Home**: Dashboard utama (beda tampilan untuk Alumni vs Umum).
    2.  **Donasiku**: Riwayat donasi user (Filter: Lunas, Pending, Gagal).
    3.  **Tiketku**: Riwayat tiket event user (Filter & QR Code).
    4.  **Loker**: Info lowongan kerja.
    5.  **Lainnya**: Drawer menu tambahan.
*   **Side Drawer (Lainnya)**:
    *   Akses ke Direktori, Market, Forum, dan Profil.

### 💳 Transaksi & Riwayat (History)
*   **Metode Pembayaran (Mock)**: Simulasi pembayaran via Virtual Account BCA (Midtrans Mockup).
*   **Donasiku**:
    *   Tracking status donasi.
    *   Validasi filter tanggal (Maksimal range 1 tahun).
    *   Menampilkan ID Transaksi (`TRX-...`).
*   **Tiketku**:
    *   Manajemen tiket event.
    *   Status: Pending (Bayar), Success (Lihat Tiket/QR), Expired.
    *   Menampilkan ID Transaksi (`TRX-...`).

### 📱 Fitur Komunitas
*   **E-KTA**: Kartu anggota digital (Hanya Alumni).
*   **Direktori**: Pencarian alumni.
*   **Forum**: Diskusi antar pengguna.
*   **Market**: Marketplace sederhana komunitas.
*   **Berita**: Portal informasi & prestasi sekolah.

## 🛠️ Catatan Teknis
*   **Tech Stack**: HTML5, Vanilla CSS (Variables), Vanilla JS.
*   **Data**: Menggunakan `const` array sebagai Mock Data di dalam setiap file HTML (tidak ada database backend riil).
*   **Responsive**: Desain *Mobile-First* yang responsif.
*   **Icons**: Menggunakan SVG native.

---
*Dibuat oleh Tim Pengembang IKA SMANSARA*
