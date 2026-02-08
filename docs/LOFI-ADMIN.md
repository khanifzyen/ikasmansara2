# Dokumentasi Lo-Fi Prototype: Admin Panel (lofi-admin)

Dokumentasi ini menjelaskan secara detail setiap halaman dalam folder `lofi-admin`, yang merupakan prototype HTML untuk **Admin Panel** aplikasi IKA SMANSARA.

---

## Daftar Isi

1. [Gambaran Umum](#1-gambaran-umum)
2. [Struktur File](#2-struktur-file)
3. [Komponen Umum](#3-komponen-umum)
4. [Halaman Admin](#4-halaman-admin)
   - [Dashboard (index.html)](#41-dashboard-indexhtml)
   - [User Management](#42-user-management)
   - [Event Management](#43-event-management)
   - [Donation Management](#44-donation-management)
   - [News Management](#45-news-management)
   - [Forum Moderation](#46-forum-moderation)
   - [Loker Moderation](#47-loker-moderation)
   - [Market Moderation](#48-market-moderation)
   - [Memory Management](#49-memory-management)
5. [Pola Desain & Keputusan](#5-pola-desain--keputusan)

---

## 1. Gambaran Umum

Admin Panel IKA SMANSARA adalah antarmuka untuk mengelola seluruh aspek aplikasi alumni:

- **User Management**: Kelola data anggota, verifikasi alumni
- **Event Management**: Buat dan kelola event dengan tiket, sub-event, sponsorship, dan donasi terintegrasi
- **Donation Management**: Kelola kampanye donasi dan transaksi
- **Content Moderation**: Moderasi berita, forum, lowongan kerja, dan marketplace
- **Memory/Gallery**: Kelola album foto kenangan

### Karakteristik Utama

| Aspek | Deskripsi |
|-------|-----------|
| **Target User** | Admin/Pengurus IKA |
| **Pendekatan** | Desktop-first dengan responsive mobile |
| **Layout** | Sidebar navigation (desktop) + Bottom nav (mobile) |
| **State Management** | Mock data dengan JavaScript |

---

## 2. Struktur File

```
lofi-admin/
├── index.html              # Dashboard utama
├── style.css               # Stylesheet admin
├── script.js               # Shared JavaScript functions
│
├── users.html              # Daftar user
├── user-detail.html        # Detail & edit user
├── user-form.html          # Form tambah user
│
├── events.html             # Daftar event
├── event-wizard.html       # Wizard pembuatan event (5 step)
├── event-form.html         # Form edit event (tabbed)
├── event-dashboard.html    # Dashboard per-event (peserta, keuangan, dll)
│
├── donations.html          # Daftar kampanye donasi
├── donations-detail.html   # Detail kampanye donasi
├── donation-form.html      # Form buat/edit kampanye
├── donation-transactions.html # Daftar transaksi donasi
│
├── news.html               # Daftar berita
├── news-form.html          # Form tulis/edit berita
│
├── forum.html              # Moderasi forum
├── loker.html              # Moderasi lowongan kerja
├── market.html             # Moderasi marketplace
├── memory.html             # Kelola album foto
```

---

## 3. Komponen Umum

### 3.1 Desktop Sidebar

Navigasi utama untuk tampilan desktop, tersedia di semua halaman:

```
📦 sidebar-menu
├── 🏠 Dashboard
├── 👥 Users
├── 📅 Events
├── 💰 Donasi
├── 📋 Transaksi
├── 📰 Berita
├── 💬 Forum
├── 💼 Loker
├── 🛒 Market
└── 📷 Memory
```

### 3.2 Mobile Bottom Navigation

Navigasi tetap di bawah untuk mobile, berisi 4 menu utama:
- Dashboard
- Users
- Donasi
- Events

### 3.3 Filter Bar

Sistem filter berbasis chip untuk memfilter data:

```html
<div class="filter-bar">
    <button class="filter-chip active">Semua</button>
    <button class="filter-chip">Aktif</button>
    <button class="filter-chip">Draft</button>
</div>
```

### 3.4 Date Filter Section

Filter berdasarkan rentang tanggal:

| Field | Type | Deskripsi |
|-------|------|-----------|
| Tanggal Awal | `date` | Batas awal filter |
| Tanggal Akhir | `date` | Batas akhir filter |

### 3.5 List Card

Komponen kartu untuk menampilkan item dalam daftar:

```
┌─────────────────────────────────────────────┐
│ [Avatar] │ Title                    │ Badge │
│          │ Subtitle                 │ [Aksi]│
└─────────────────────────────────────────────┘
```

### 3.6 Confirm Modal

Modal konfirmasi untuk aksi destruktif (hapus, tutup, dll):

```
┌────────────────────────────┐
│       Konfirmasi           │
├────────────────────────────┤
│ Apakah Anda yakin?         │
│ [Batal]           [Ya]     │
└────────────────────────────┘
```

### 3.7 FAB (Floating Action Button)

Tombol tambah mengambang di kanan bawah untuk menambah item baru.

---

## 4. Halaman Admin

---

### 4.1 Dashboard (`index.html`)

#### Tujuan
Halaman utama admin yang menampilkan ringkasan statistik dan akses cepat ke semua fitur.

#### Fungsionalitas

**Stats Grid** - 4 kartu statistik utama:
| Stat | Icon | Deskripsi |
|------|------|-----------|
| Total Users | 👥 | Jumlah user terdaftar |
| Total Events | 📅 | Jumlah event |
| Total Donasi | 💰 | Total dana terkumpul |
| Total Berita | 📰 | Jumlah artikel berita |

**Admin Menu Grid** - Quick links ke semua modul:
- Users, Events, Donasi, News, Forum, Loker, Market, Memory

#### Data yang Ditampilkan
- Statistik agregat (counter)
- Menu navigasi cepat

---

### 4.2 User Management

#### 4.2.1 Daftar User (`users.html`)

**Tujuan**: Menampilkan dan mengelola daftar anggota.

**Filter Options**:
| Filter | Deskripsi |
|--------|-----------|
| Semua | Tampilkan semua user |
| Alumni | Hanya alumni |
| Umum | Hanya non-alumni (umum/guru/staff) |
| Verified | User terverifikasi |
| Pending | Menunggu verifikasi |

**Tampilan**:
- **Mobile**: List card dengan avatar, nama, email, angkatan, status
- **Desktop**: Tabel dengan kolom lengkap

**Aksi per User**:
| Aksi | Kondisi | Navigasi |
|------|---------|----------|
| Edit | Semua user | → `user-detail.html?id=X` |
| Verify | Status Pending | Tombol langsung |

**FAB**: Tambah user baru → `user-form.html`

---

#### 4.2.2 Detail User (`user-detail.html`)

**Tujuan**: Melihat dan mengedit detail user tertentu.

**Sections**:

1. **Profile Header**
   - Avatar (inisial)
   - Nama lengkap
   - Info angkatan
   - Badge status verifikasi

2. **Form Data** (Editable):

| Field | Type | Deskripsi |
|-------|------|-----------|
| Email | email | Email terdaftar |
| No. HP | text | Nomor telepon |
| Tahun Lulus | select | Angkatan |
| Status Verifikasi | select | Verified/Pending/Rejected |
| Tipe User | select | Alumni/Umum |
| Pekerjaan | text | Status pekerjaan |
| Perusahaan | text | Nama perusahaan |
| Domisili | text | Kota domisili |

3. **User Statistics**
   - Jumlah event diikuti
   - Total donasi
   - Jumlah posting forum

**Aksi**:
| Tombol | Fungsi |
|--------|--------|
| Simpan Perubahan | Update data user |
| Ban User | Blokir akun (destructive) |

---

#### 4.2.3 Form Tambah User (`user-form.html`)

**Tujuan**: Menambahkan user baru secara manual oleh admin.

**Section Form**:

| Section | Fields |
|---------|--------|
| Data Akun | Nama, Email, No. HP, Password Default |
| Data Sekolah | Tahun Lulus (Angkatan) |
| Profil Saat Ini | Status Kerja, Perusahaan, Domisili |
| Status | Status Verifikasi |

**Aksi**: Simpan → alert + redirect ke `users.html`

---

### 4.3 Event Management

#### 4.3.1 Daftar Event (`events.html`)

**Tujuan**: Menampilkan semua event yang pernah dibuat.

**Filter Options**:
| Filter | Deskripsi |
|--------|-----------|
| Semua | Semua event |
| Aktif | Event yang sedang berlangsung |
| Draft | Event belum dipublikasi |
| Selesai | Event yang sudah lewat |

**Data per Event Card**:
- Judul event
- Tanggal & lokasi
- Status badge (Aktif/Draft/Selesai)

**Navigasi**: Klik card → `event-dashboard.html?id=X`

**FAB**: Tambah event baru → `event-wizard.html`

---

#### 4.3.2 Event Wizard (`event-wizard.html`)

**Tujuan**: Wizard 5 langkah untuk membuat event baru dengan pengalaman user yang optimal.

**Progress Steps**:

| Step | Nama | Deskripsi |
|------|------|-----------|
| 1 | Konfigurasi | Setup format ID booking & tiket |
| 2 | Info Dasar | Judul, tanggal, lokasi, deskripsi, banner |
| 3 | Tiket | Jenis tiket, harga, kuota, opsi tambahan |
| 4 | Fitur | Sub-events, Sponsorship, Open Donasi |
| 5 | Review | Preview & konfirmasi sebelum publish |

**Step 1 - Konfigurasi ID**:
| Field | Format Tags | Contoh Output |
|-------|-------------|---------------|
| Kode Event | - | REUNI26 |
| Format Booking ID | {CODE}, {YEAR}, {SEQ} | REUNI26-2026-0001 |
| Format Ticket ID | {CODE}, {SEQ}, {RAND} | TIX-REUNI26-0001 |

**Step 2 - Info Dasar**:
| Field | Type |
|-------|------|
| Judul Event | text |
| Tanggal Mulai | date |
| Waktu | time |
| Lokasi | text |
| Deskripsi Event | textarea |
| Banner Event | file upload |

**Step 3 - Tiket & Peserta**:
- Dynamic ticket types (dapat ditambah/hapus)
- Per tiket: Nama, Harga, Kuota, Deskripsi
- Opsi tambahan (ukuran kaos, dll) dengan format `Label|Harga`

**Step 4 - Fitur Tambahan**:

| Fitur | Toggle | Config Fields |
|-------|--------|---------------|
| Sub-Events | ✓ | Nama, Deskripsi, Kuota, Lokasi |
| Sponsorship | ✓ | Tier Name, Harga, Benefits |
| Open Donasi | ✓ | Deskripsi, Target Donasi |

**Step 5 - Review**:
- Preview event summary
- Contoh format ID
- Pilihan status: Draft / Publikasikan / Jadwalkan

**Navigasi**:
- Tombol "Kembali" & "Lanjut" di footer
- Progress bar & step indicators

---

#### 4.3.3 Event Form (`event-form.html`)

**Tujuan**: Form untuk mengedit event yang sudah ada dengan interface tab.

**Tabs**:

| Tab | Konten |
|-----|--------|
| Info Dasar | Judul, tanggal, waktu, lokasi, deskripsi, banner, status |
| Tiket | Gambar tiket, harga, kuota, includes, opsi ukuran |
| Sub-Events | Dynamic list kegiatan pendukung |
| Sponsor & Donasi | Tier sponsorship + pengaturan donasi |

**Dynamic Items**:
- Setiap item (tiket opsi, sub-event, sponsor tier) bisa ditambah/hapus
- Interface drag-and-drop style untuk reordering

**Aksi**:
| Tombol | Fungsi |
|--------|--------|
| Simpan Pengaturan | Update event |
| Hapus Event | Delete dengan konfirmasi |

---

#### 4.3.4 Event Dashboard (`event-dashboard.html`)

**Tujuan**: Dashboard komprehensif untuk mengelola satu event spesifik.

**Header Stats** (4 kartu):
| Stat | Deskripsi |
|------|-----------|
| Pendaftar | Total peserta terdaftar |
| Pemasukan | Total uang masuk |
| Pengeluaran | Total biaya keluar |
| Saldo | Pemasukan - Pengeluaran |

**Tabs**:

##### Tab Peserta
- Tabel/list peserta dengan:
  - ID Booking
  - Nama, No. HP, Angkatan
  - Jumlah tiket, Total bayar
  - Channel (Aplikasi/Manual Cash/Manual TF)
  - Bukti bayar (view/upload)
  - Catatan (ukuran kaos, dll)
  - Status (Lunas/Pending)
- Aksi: Detail, Validasi
- Modal: Tambah Peserta Manual

##### Tab Keuangan
- Summary: Total Pemasukan, Total Pengeluaran, Saldo Bersih
- **Accordion Pemasukan**:
  - Sumber (Peserta/Sponsor/Donasi)
  - Channel/Keterangan
  - Jumlah (hijau positif)
  - Tanggal
- **Accordion Pengeluaran**:
  - Keperluan, Kategori
  - Jumlah (merah negatif)
  - Bukti, Aksi hapus
  - Tombol "Tambah Pengeluaran"

##### Tab Sub-Events
- List kegiatan pendukung dengan:
  - Nama, kuota, lokasi
  - Count peserta terdaftar
- Link ke edit pengaturan

##### Tab Sponsor
- Total sponsor amount
- List sponsor dengan logo, nama, tier, nominal
- Tombol tambah sponsor
- Link ke edit paket sponsorship

##### Tab Donasi
- Progress card (amount terkumpul, target, persentase)
- Progress bar visual
- List donatur terbaru
- Link ke edit pengaturan donasi

**Fitur Mobile**:
- FAB untuk tambah peserta
- Accordion untuk tabel panjang
- Tombol Scan QR untuk check-in

---

### 4.4 Donation Management

#### 4.4.1 Daftar Kampanye (`donations.html`)

**Tujuan**: Menampilkan semua kampanye donasi.

**Filter Options**:
| Filter | Deskripsi |
|--------|-----------|
| Semua | Semua kampanye |
| Aktif | Yang sedang berjalan |
| Selesai | Yang sudah tutup |

**Data per Card**:
- Judul kampanye
- Target & persentase terkumpul
- Status badge

**Navigasi**: Klik → `donations-detail.html?id=X`

**FAB**: Tambah kampanye → `donation-form.html`

---

#### 4.4.2 Detail Kampanye (`donations-detail.html`)

**Tujuan**: Melihat detail lengkap kampanye donasi.

**Sections**:

1. **Hero Image** dengan badge status
2. **Campaign Info**:
   - Deadline (countdown)
   - Judul kampanye
3. **Progress Section**:
   - Nominal terkumpul vs target
   - Progress bar
   - Persentase & jumlah donatur
4. **Deskripsi lengkap** dengan bullet list penggunaan dana
5. **Riwayat Donasi**:
   - List donatur (avatar, nama, waktu, nominal)
   - Link "Lihat Semua" → transactions

**Admin Actions Bar (fixed bottom)**:
| Tombol | Fungsi |
|--------|--------|
| Edit | → `donation-form.html?id=X` |
| Tutup | Modal konfirmasi tutup kampanye |

---

#### 4.4.3 Form Kampanye (`donation-form.html`)

**Tujuan**: Membuat atau mengedit kampanye donasi.

**Form Fields**:

| Field | Type | Deskripsi |
|-------|------|-----------|
| Judul Campaign | text | Nama kampanye |
| Deskripsi | textarea | Detail kampanye |
| Target Donasi | number | Dalam Rupiah |
| Deadline | date | Batas waktu |
| Banner Image | file | Gambar sampul |
| Penyelenggara | text | Nama panitia |
| Kategori | select | Infrastruktur/Pendidikan/Sosial/Kesehatan/Lainnya |
| Prioritas | select | Normal/Urgent |
| Status | select | Draft/Aktif/Selesai |

**Aksi**:
- Simpan Campaign
- Hapus Campaign (destructive)

---

#### 4.4.4 Transaksi Donasi (`donation-transactions.html`)

**Tujuan**: Melihat dan mengelola transaksi donasi.

**Filter Options**:
| Filter | Deskripsi |
|--------|-----------|
| Semua | Semua transaksi |
| Lunas | Pembayaran selesai |
| Pending | Menunggu konfirmasi |
| Gagal | Pembayaran gagal/expired |

**Data per Transaksi**:
- Nominal donasi
- Nama donatur
- Kampanye tujuan
- ID Transaksi & waktu
- Status badge

**Aksi**:
- Konfirmasi (untuk status Pending)

---

### 4.5 News Management

#### 4.5.1 Daftar Berita (`news.html`)

**Tujuan**: Mengelola artikel berita.

**Filter Options**:
| Filter | Deskripsi |
|--------|-----------|
| Semua | Semua berita |
| Published | Yang sudah dipublikasi |
| Draft | Masih draft |

**Data per Card**:
- Judul berita
- Tanggal & view count
- Status badge

**Aksi**: Edit → `news-form.html?id=X`

**FAB**: Tulis berita → `news-form.html`

---

#### 4.5.2 Form Berita (`news-form.html`)

**Tujuan**: Menulis atau mengedit artikel berita.

**Form Fields**:

| Field | Type | Deskripsi |
|-------|------|-----------|
| Judul Berita | text | Headline artikel |
| Kategori | select | Prestasi/Kegiatan/Pengumuman/Alumni Sukses/Lainnya |
| Thumbnail | file | Gambar thumbnail |
| Ringkasan | textarea | Preview singkat |
| Konten Berita | textarea | Isi lengkap artikel |
| Penulis | select | Pilih user sebagai author |
| Tanggal Publish | date | Jadwal publikasi |
| Status | select | Draft/Published |

**Aksi**:
- Simpan Berita
- Hapus Berita

---

### 4.6 Forum Moderation (`forum.html`)

**Tujuan**: Moderasi konten forum diskusi.

**Filter Options**:
| Filter | Deskripsi |
|--------|-----------|
| Semua | Semua postingan |
| Reported | Dilaporkan user lain |
| Pinned | Postingan yang di-pin |

**Data per Card**:
- Judul postingan
- Author & jumlah replies
- Status badge (Pinned/Reported/Active)

**Navigasi**: Klik → `forum-detail.html?id=X` (detail view)

**Actions available**:
- Pin/Unpin postingan
- Hide/Remove reported content
- Ban author

---

### 4.7 Loker Moderation (`loker.html`)

**Tujuan**: Moderasi lowongan kerja yang diposting user.

**Filter Options**:
| Filter | Deskripsi |
|--------|-----------|
| Semua | Semua lowongan |
| Pending | Menunggu approval |
| Approved | Sudah disetujui |
| Rejected | Ditolak |

**Data per Card**:
- Nama posisi
- Perusahaan & tipe kerja
- Posted by (nama user)
- Status badge

**Aksi Inline**:
| Tombol | Fungsi |
|--------|--------|
| ✓ (Approve) | Setujui lowongan |
| ✗ (Reject) | Tolak lowongan |

**Navigasi**: Klik card → `loker-detail.html?id=X`

---

### 4.8 Market Moderation (`market.html`)

**Tujuan**: Moderasi produk di marketplace alumni.

**Filter Options**:
| Filter | Deskripsi |
|--------|-----------|
| Semua | Semua produk |
| Pending | Menunggu review |
| Approved | Sudah disetujui |
| Rejected | Ditolak |

**Data per Card**:
- Nama produk
- Harga & nama penjual
- Status badge

**Aksi Inline**:
| Tombol | Fungsi |
|--------|--------|
| ✓ (Approve) | Setujui produk |
| ✗ (Reject) | Tolak produk |

---

### 4.9 Memory Management (`memory.html`)

**Tujuan**: Mengelola album foto kenangan.

**Filter Options** (berdasarkan dekade):
- Semua, 2020an, 2010an, 2000an, 1990an

**Data per Album Card**:
- Nama album
- Jumlah foto & tahun
- Aksi: Edit / Delete

**Upload Section**:
- Drag & drop zone
- Multi-file input
- Button "Pilih File"

**Form Album Baru**:
| Field | Type |
|-------|------|
| Nama Album | text |
| Tahun | number |
| Deskripsi | textarea |

**FAB**: Quick upload file

---

## 5. Pola Desain & Keputusan

### 5.1 Responsive Strategy

| Device | Layout | Navigation |
|--------|--------|------------|
| Desktop (≥1024px) | Sidebar + Content area | Sidebar menu |
| Mobile (<1024px) | Full-width content | Bottom nav + Hamburger |

### 5.2 Konsistensi UI

- **Color Coding** untuk status badges:
  - 🟢 Success/Approved/Verified/Published/Lunas
  - 🟡 Warning/Pending/Draft
  - 🔴 Danger/Rejected/Expired/Reported
  - 🔵 Info/Active/Pinned

- **Card-based design** untuk list items
- **Accordion** untuk data panjang di mobile
- **Modal** untuk konfirmasi dan form singkat
- **Fixed footer** untuk action buttons

### 5.3 Form Patterns

- Input groups dengan label
- Inline row untuk field terkait (tanggal + waktu)
- Dynamic items untuk list yang bisa ditambah/hapus
- File upload dengan drag-drop zone
- Select dropdown untuk pilihan terbatas

### 5.4 Navigation Patterns

- **Breadcrumb visual** di header (path indicator)
- **Back button** di setiap halaman detail
- **Tab navigation** untuk konten multi-section
- **Step wizard** untuk proses multi-step
- **Filter chips** untuk filtering cepat

### 5.5 Action Patterns

- **Primary action**: Prominent button (green/primary)
- **Secondary action**: Outline button
- **Destructive action**: Red outline/text
- **Quick actions**: Inline buttons di list cards
- **Batch actions**: Di header section

---

## 6. Hubungan dengan Frontend (lofi)

Admin panel mengelola data yang kemudian ditampilkan di frontend user:

| Admin Page | Frontend Page | Relasi |
|------------|---------------|--------|
| users.html | directory.html, profile.html | CRUD user |
| events.html | event-detail.html, home.html | Event listing |
| donations.html | donation.html, donasiku.html | Campaign & transactions |
| news.html | home.html (berita section) | News articles |
| forum.html | forum.html | Post moderation |
| loker.html | loker.html | Job listings |
| market.html | market.html | Product listings |
| memory.html | (future gallery) | Photo albums |

---

## 7. Catatan Implementasi

### Mock Functions (di script.js)

```javascript
// Filter handling
setFilter(button)      // Toggle filter chip active state

// CRUD operations
submitForm(type)       // Submit form dengan alert + redirect
deleteItem(type, id)   // Delete dengan konfirmasi modal
approveItem(type, id)  // Approve pending item
rejectItem(type, id)   // Reject pending item

// Modal handling
openModal(id)          // Show modal
closeModal(id)         // Hide modal
showConfirm(title, msg)// Show confirmation
executeConfirm()       // Execute confirmed action

// Navigation
goBack()               // window.history.back()
```

### CSS Classes Utama

| Class | Fungsi |
|-------|--------|
| `.admin-sidebar` | Sidebar desktop |
| `.admin-bottom-nav` | Bottom nav mobile |
| `.stats-grid` | Grid untuk stat cards |
| `.filter-bar` | Container filter chips |
| `.list-card` | Card item dalam list |
| `.data-table` | Tabel data desktop |
| `.mobile-list` | List untuk mobile |
| `.form-section` | Container form |
| `.input-group` | Label + input wrapper |
| `.confirm-modal` | Modal overlay |
| `.fab-add` | Floating action button |

---

*Dokumentasi ini dibuat untuk membantu developer memahami flow dan struktur admin panel sebelum implementasi backend.*
