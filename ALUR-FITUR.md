# Alur Fitur Aplikasi IKA SMANSARA

Dokumen ini menjelaskan alur (flow) untuk setiap fitur dalam aplikasi berdasarkan skema database.

---

## Daftar Isi

1. [Autentikasi & Registrasi](#1-autentikasi--registrasi)
2. [Event & Tiket](#2-event--tiket)
3. [Donasi](#3-donasi)
4. [Forum](#4-forum)
5. [Lowongan Kerja (Loker)](#5-lowongan-kerja-loker)
6. [Market (Jual-Beli)](#6-market-jual-beli)
7. [Galeri Kenangan](#7-galeri-kenangan)
8. [Direktori Alumni](#8-direktori-alumni)
9. [Berita](#9-berita)

---

## 1. Autentikasi & Registrasi

### 1.1 Registrasi Alumni

```mermaid
sequenceDiagram
    actor User
    participant App
    participant PocketBase
    participant RegSeq as registration_sequences

    User->>App: Isi form registrasi
    Note right of User: name, email, phone, angkatan

    App->>PocketBase: Create user (role: alumni)
    PocketBase-->>App: User created (unverified)

    App->>RegSeq: Get/create record (year = angkatan)
    RegSeq-->>App: last_number++
    App->>RegSeq: Get record (year = 0)
    RegSeq-->>App: last_number++ (global)

    App->>PocketBase: Update user
    Note right of App: no_urut_angkatan, no_urut_global

    App-->>User: Registrasi berhasil
    Note right of User: Menunggu verifikasi admin
```

**Flow:**
1. User mengisi form dengan data lengkap
2. Sistem membuat akun dengan `role = alumni`, `is_verified = false`
3. Sistem generate nomor EKTA:
   - Ambil/buat `registration_sequences` dengan `year = angkatan`
   - Increment `last_number` → dapat `no_urut_angkatan`
   - Increment record `year = 0` → dapat `no_urut_global`
4. Format EKTA: `{angkatan}.{no_urut_angkatan:04d}.{no_urut_global}`
5. Admin memverifikasi akun

### 1.2 Login

```mermaid
flowchart LR
    A[Open App] --> B{Token valid?}
    B -->|Yes| C[Dashboard]
    B -->|No| D[Login Page]
    D --> E[Input Email/Password]
    E --> F{Valid?}
    F -->|Yes| C
    F -->|No| G[Error Message]
```

---

## 2. Event & Tiket

### 2.1 Melihat Event

```mermaid
flowchart TD
    A[Home] --> B[Event List]
    B --> C[Event Detail]
    C --> D{Tab}
    D --> E[Info Tab]
    D --> F[Tiket Tab]
    D --> G[Sub-Event Tab]
    D --> H[Sponsor Tab]
    D --> I[Donasi Tab]
```

### 2.2 Pembelian Tiket

```mermaid
sequenceDiagram
    actor User
    participant App
    participant PB as PocketBase
    participant Event as events
    participant Booking as event_bookings
    participant Ticket as event_booking_tickets

    User->>App: Pilih tipe tiket & jumlah
    User->>App: Pilih opsi (ukuran, dll)
    User->>App: Pilih sub-event (opsional)

    App->>Event: Get last_booking_seq, last_ticket_seq
    Event-->>App: seq numbers

    App->>Booking: Create booking
    Note right of App: booking_id = REUNI26-2026-0001

    loop For each ticket quantity
        App->>Ticket: Create ticket
        Note right of App: ticket_id = TIX-REUNI26-001
        
        opt Sub-event selected
            App->>PB: Create sub_event_registration
        end
    end

    App->>Event: Update seq counters
    App-->>User: Tampilkan Payment Page
```

**Collections Terkait:**
- `events` → informasi event + counter
- `event_tickets` → tipe tiket (VIP, Regular)
- `event_ticket_options` → opsi tambahan (ukuran kaos)
- `event_bookings` → order/invoice
- `event_booking_tickets` → tiket individual
- `event_sub_events` → sub-event (cek kesehatan, dll)
- `event_sub_event_registrations` → pendaftaran sub-event

### 2.3 Check-in Event

```mermaid
sequenceDiagram
    actor Panitia
    participant Scanner
    participant PB as PocketBase
    
    Panitia->>Scanner: Scan QR tiket
    Note right of Scanner: ticket_id = TIX-REUNI26-001
    
    Scanner->>PB: Find ticket by ticket_id
    PB-->>Scanner: Ticket record
    
    alt Already checked in
        Scanner-->>Panitia: ❌ Sudah check-in
    else Not checked in
        Scanner->>PB: Update checked_in = true
        Scanner-->>Panitia: ✅ Check-in berhasil
    end
```

### 2.4 Pengambilan Kaos

```mermaid
flowchart LR
    A[Scan QR Tiket] --> B{Sudah bayar?}
    B -->|No| C[❌ Belum Lunas]
    B -->|Yes| D{Kaos diambil?}
    D -->|Yes| E[❌ Sudah Diambil]
    D -->|No| F[Update shirt_picked_up]
    F --> G[✅ Berikan Kaos]
```

---

## 3. Donasi

### 3.1 Donasi Campaign

```mermaid
sequenceDiagram
    actor User
    participant App
    participant PB as PocketBase
    participant Donation as donations
    participant Trx as donation_transactions

    User->>App: Pilih campaign donasi
    User->>App: Input nominal & pesan
    User->>App: Pilih anonymous atau tidak

    App->>Trx: Create transaction
    Note right of App: payment_status = pending
    
    App-->>User: Redirect ke Payment Gateway
    
    User->>App: Bayar
    
    App->>Trx: Update status = success
    App->>Donation: Increment collected_amount
    App->>Donation: Increment donor_count
    
    App-->>User: ✅ Donasi berhasil
```

### 3.2 Donasi Event

```mermaid
flowchart TD
    A[Event Detail] --> B[Tab Donasi]
    B --> C[Input Nominal]
    C --> D[Bayar]
    D --> E[donation_transactions]
    Note right of E: event = event_id<br/>donation = null
```

**Perbedaan:**
- **Campaign Donasi**: `donation = donation_id`, `event = null`
- **Donasi Event**: `donation = null`, `event = event_id`

---

## 4. Forum

### 4.1 Membuat Post

```mermaid
flowchart TD
    A[Forum] --> B[New Post Button]
    B --> C[Compose Screen]
    C --> D{Input}
    D --> E[content: text]
    D --> F[category: select]
    D --> G[visibility: select]
    D --> H[image: optional]
    D --> I[Submit]
    I --> J[forum_posts]
```

### 4.2 Interaksi Post

```mermaid
flowchart LR
    subgraph Post Actions
        A[Like] --> B[forum_likes]
        C[Comment] --> D[forum_comments]
        E[Reply] --> F["forum_comments (parent)"]
    end
```

**Visibility Rules:**
- `public`: Semua user bisa lihat
- `alumni_only`: Hanya alumni terverifikasi

---

## 5. Lowongan Kerja (Loker)

### 5.1 Posting Loker

```mermaid
stateDiagram-v2
    [*] --> Draft: Create
    Draft --> Pending: Submit
    Pending --> Approved: Admin Approve
    Pending --> Rejected: Admin Reject
    Approved --> Closed: Expired/Manual
    Rejected --> Pending: Resubmit
    Closed --> [*]
```

### 5.2 Melamar Lowongan

```mermaid
flowchart LR
    A[Loker Detail] --> B[Klik Apply]
    B --> C{apply_link type}
    C -->|URL| D[Open Browser]
    C -->|Email| E[Open Email App]
```

---

## 6. Market (Jual-Beli)

### 6.1 Posting Produk

```mermaid
sequenceDiagram
    actor Seller
    participant App
    participant Admin
    participant PB as PocketBase

    Seller->>App: Isi form produk
    Note right of Seller: name, price, category, images

    App->>PB: Create market (status: pending)
    PB-->>App: Product created

    App-->>Seller: Menunggu approval

    Admin->>PB: Review & approve
    PB-->>App: status = approved

    App-->>Seller: Produk live!
```

### 6.2 Kategori Produk

| Kategori | Contoh |
|----------|--------|
| `kuliner` | Katering, kue, makanan |
| `fashion` | Batik, tas, sepatu |
| `jasa_professional` | Konsultan, arsitek |
| `properti` | Rumah, tanah, kost |
| `lainnya` | Lain-lain |

---

## 7. Galeri Kenangan

### 7.1 Upload Foto

```mermaid
flowchart TD
    A[Memories Screen] --> B[Upload Button]
    B --> C[Select Image]
    C --> D[Input Year & Caption]
    D --> E[Submit]
    E --> F["memories (is_approved: false)"]
    F --> G{Admin Review}
    G -->|Approve| H[Tampil di Galeri]
    G -->|Reject| I[Not Shown]
```

### 7.2 Browsing Galeri

```mermaid
flowchart LR
    A[Memories] --> B[Filter by Year]
    B --> C[Photo Grid]
    C --> D[Photo Detail]
```

---

## 8. Direktori Alumni

### 8.1 Pencarian Alumni

```mermaid
flowchart TD
    A[Directory Screen] --> B[Search/Filter]
    B --> C{Filter Options}
    C --> D[By Name]
    C --> E[By Angkatan]
    C --> F[By Domisili]
    C --> G[By Job Status]
    D & E & F & G --> H[Results List]
    H --> I[Profile Detail]
```

**Access Rules:**
- Hanya menampilkan user dengan `is_verified = true`
- List/View: Admin only (API level)
- Client harus memiliki token admin atau custom rule

### 8.2 Profile View

```mermaid
flowchart LR
    A[User Card] --> B[Name & Angkatan]
    B --> C[EKTA Number]
    A --> D[Company & Job]
    A --> E[Domisili]
    A --> F[Contact Button]
    F --> G[Open WhatsApp]
```

---

## 9. Berita

### 9.1 News Flow

```mermaid
flowchart TD
    A[Admin] --> B[Create News]
    B --> C{Status}
    C -->|Draft| D[Not Visible]
    C -->|Published| E[Visible to Users]
    
    F[User] --> G[News List]
    G --> H[News Detail]
    H --> I[Increment view_count]
```

### 9.2 Kategori Berita

- `prestasi` - Prestasi siswa/alumni
- `kegiatan` - Kegiatan sekolah/alumni
- `pengumuman` - Pengumuman resmi
- `alumni_sukses` - Profil alumni sukses
- `lainnya` - Berita lainnya

---

## QR Code Strategy

> **QR codes tidak disimpan di database.** Generate client-side dari ID unik.

| QR Type | Source Field | Example |
|---------|--------------|---------|
| Booking | `booking_id` | `REUNI26-2026-0001` |
| Ticket | `ticket_id` | `TIX-REUNI26-001` |
| Sub-Event | `sub_event_ticket_id` | `REUNI26-CEK-001` |

```javascript
// Client-side generation
import QRCode from 'qrcode';

const ticketId = 'TIX-REUNI26-001';
QRCode.toDataURL(ticketId, (err, url) => {
  // Display as image
});
```

---

## Database Hooks (Auto-Update)

| Trigger | Action |
|---------|--------|
| Donation transaction `success` | Update `donations.collected_amount` & `donor_count` |
| Booking `paid` | Update `event_tickets.sold` |
| Sub-event registration created | Update `event_sub_events.registered` |
