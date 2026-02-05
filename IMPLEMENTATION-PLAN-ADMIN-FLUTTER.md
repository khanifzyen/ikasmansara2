# Implementation Plan: Admin Features in Flutter App

Dokumen ini menjelaskan rencana integrasi fitur admin dari `lofi-admin` ke dalam aplikasi Flutter `ika_smansara`, dengan semua menu admin diakses melalui **hamburger menu (drawer)** di AppBar.

---

## Overview

### Tujuan
Menggabungkan seluruh fitur admin panel ke dalam satu aplikasi Flutter yang sudah ada, sehingga admin dapat mengelola:
- Users (verifikasi alumni)
- Events & Event Dashboard
- Donations & Transactions
- News (Berita)
- Forum Posts
- Loker (Lowongan Kerja)
- Market (Iklan Jual-Beli)
- Memory (Galeri Kenangan)

### Pendekatan UI
- **Hamburger menu (Drawer)** di AppBar untuk akses menu admin
- Menu admin hanya tampil untuk user dengan `role: admin`
- Menggunakan pattern Clean Architecture yang sudah ada

---

## Fitur Admin dari lofi-admin

| No | Modul | File HTML | Deskripsi |
|----|-------|-----------|-----------|
| 1 | Dashboard | `index.html` | Overview stats, recent activity |
| 2 | Users | `users.html`, `user-detail.html`, `user-form.html` | Kelola & verifikasi user |
| 3 | Events | `events.html`, `event-form.html`, `event-wizard.html` | CRUD events |
| 4 | Event Dashboard | `event-dashboard.html` | Peserta, Keuangan, Sub-events, Sponsor, Donasi |
| 5 | Donations | `donations.html`, `donations-detail.html`, `donation-form.html` | Campaign donasi |
| 6 | Transactions | `donation-transactions.html` | Transaksi donasi |
| 7 | News | `news.html`, `news-form.html` | CRUD berita |
| 8 | Forum | `forum.html`, `forum-detail.html` | Moderasi forum |
| 9 | Loker | `loker.html`, `loker-detail.html` | Approval lowongan |
| 10 | Market | `market.html`, `market-detail.html` | Approval iklan |
| 11 | Memory | `memory.html` | Approval galeri |

---

## Proposed Changes

### Phase 1: Core Infrastructure

#### [NEW] `lib/features/admin/` - Admin Feature Module dengan Submodules

Setiap submodule mengikuti pola Clean Architecture lengkap (data, domain, presentation):

```
lib/features/admin/
├── core/                              # Shared admin components
│   ├── presentation/
│   │   ├── widgets/
│   │   │   ├── admin_drawer.dart      # Hamburger menu drawer
│   │   │   ├── admin_stat_card.dart   # Reusable stat card
│   │   │   └── admin_list_card.dart   # Reusable list card
│   │   └── pages/
│   │       └── admin_dashboard_page.dart
│   └── bloc/
│       └── admin_stats_bloc.dart      # Dashboard stats
│
├── users/                             # User Management Submodule
│   ├── data/
│   │   ├── datasources/
│   │   │   └── admin_users_remote_data_source.dart
│   │   └── repositories/
│   │       └── admin_users_repository_impl.dart
│   ├── domain/
│   │   ├── repositories/
│   │   │   └── admin_users_repository.dart
│   │   └── usecases/
│   │       ├── get_all_users.dart
│   │       ├── get_pending_users.dart
│   │       └── verify_user.dart
│   └── presentation/
│       ├── bloc/
│       │   └── admin_users_bloc.dart
│       ├── pages/
│       │   ├── admin_users_page.dart
│       │   └── admin_user_detail_page.dart
│       └── widgets/
│           └── user_list_tile.dart
│
├── events/                            # Event Management Submodule
│   ├── data/
│   │   ├── datasources/
│   │   │   └── admin_events_remote_data_source.dart
│   │   └── repositories/
│   │       └── admin_events_repository_impl.dart
│   ├── domain/
│   │   ├── repositories/
│   │   │   └── admin_events_repository.dart
│   │   └── usecases/
│   │       ├── get_all_events.dart
│   │       ├── get_event_stats.dart
│   │       ├── get_event_bookings.dart
│   │       ├── create_manual_booking.dart
│   │       └── update_booking_status.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── admin_events_bloc.dart
│       │   └── event_dashboard_bloc.dart
│       ├── pages/
│       │   ├── admin_events_page.dart
│       │   ├── admin_event_dashboard_page.dart
│       │   └── admin_event_form_page.dart
│       └── widgets/
│           ├── event_stats_header.dart
│           ├── participant_table.dart
│           └── finance_accordion.dart
│
├── donations/                         # Donations Submodule
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── bloc/
│       │   └── admin_donations_bloc.dart
│       └── pages/
│           ├── admin_donations_page.dart
│           └── admin_donation_detail_page.dart
│
├── news/                              # News Management Submodule
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── bloc/
│       │   └── admin_news_bloc.dart
│       └── pages/
│           ├── admin_news_page.dart
│           └── admin_news_form_page.dart
│
├── forum/                             # Forum Moderation Submodule
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── bloc/
│       └── pages/
│           └── admin_forum_page.dart
│
├── loker/                             # Loker Approval Submodule
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── bloc/
│       └── pages/
│           ├── admin_loker_page.dart
│           └── admin_loker_detail_page.dart
│
├── market/                            # Market Approval Submodule
│   ├── data/
│   ├── domain/
│   └── presentation/
│       ├── bloc/
│       └── pages/
│           ├── admin_market_page.dart
│           └── admin_market_detail_page.dart
│
└── memory/                            # Memory Approval Submodule
    ├── data/
    ├── domain/
    └── presentation/
        ├── bloc/
        └── pages/
            └── admin_memory_page.dart
```

**Keuntungan Struktur Submodule:**
1. **Separation of Concerns** - Setiap submodule independen
2. **Scalability** - Mudah menambah fitur baru per-modul
3. **Maintainability** - File terlokalisir per-fitur
4. **Reusability** - Model bisa di-share via `core/`
5. **Team Collaboration** - Developer bisa fokus per-submodule

---

#### [MODIFY] `lib/core/router/app_router.dart`

Tambahkan routes untuk semua halaman admin:

```dart
// Admin Routes
GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardPage()),
GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersPage()),
GoRoute(path: '/admin/events', builder: (_, __) => const AdminEventsPage()),
GoRoute(path: '/admin/events/:id', builder: (_, state) => AdminEventDashboardPage(eventId: state.pathParameters['id']!)),
GoRoute(path: '/admin/donations', builder: (_, __) => const AdminDonationsPage()),
GoRoute(path: '/admin/news', builder: (_, __) => const AdminNewsPage()),
GoRoute(path: '/admin/forum', builder: (_, __) => const AdminForumPage()),
GoRoute(path: '/admin/loker', builder: (_, __) => const AdminLokerPage()),
GoRoute(path: '/admin/market', builder: (_, __) => const AdminMarketPage()),
GoRoute(path: '/admin/memory', builder: (_, __) => const AdminMemoryPage()),
```

---

#### [NEW] `lib/features/admin/presentation/widgets/admin_drawer.dart`

Drawer widget berisi menu admin:

```dart
class AdminDrawer extends StatelessWidget {
  // Menu items:
  // - Dashboard
  // - Users (Kelola User)
  // - Events (Kelola Event)
  // - Donations (Kelola Donasi)
  // - News (Kelola Berita)
  // - Forum (Moderasi Forum)
  // - Loker (Approval Loker)
  // - Market (Approval Market)
  // - Memory (Approval Memory)
}
```

---

#### [MODIFY] `lib/features/home/presentation/pages/home_page.dart`

Tambahkan drawer ke AppBar untuk admin:

```dart
Scaffold(
  appBar: AppBar(
    // Tambahkan leading drawer button jika admin
    leading: isAdmin ? Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ) : null,
  ),
  drawer: isAdmin ? const AdminDrawer() : null,
  // ... rest of home page
)
```

---

### Phase 2: Admin Dashboard

#### [NEW] `lib/features/admin/presentation/pages/admin_dashboard_page.dart`

Dashboard dengan:
- Stats Grid (Total Users, Events, Donasi, Berita)
- Menu Grid (link ke setiap modul admin)
- Recent Activity (dari `activity_logs` collection)

---

### Phase 3: User Management

#### [NEW] `lib/features/admin/presentation/pages/admin_users_page.dart`

Fitur:
- List semua users dengan filter (Semua, Alumni, Umum, Verified, Pending)
- Search user
- Tap untuk detail
- Tombol Verify untuk pending users

#### [NEW] `lib/features/admin/presentation/pages/admin_user_detail_page.dart`

Detail user dengan aksi:
- View profile lengkap
- Verify/Unverify user
- Edit role
- Delete user

---

### Phase 4: Event Management

#### [NEW] `lib/features/admin/presentation/pages/admin_events_page.dart`

- List events dengan filter status
- FAB untuk create event baru

#### [NEW] `lib/features/admin/presentation/pages/admin_event_dashboard_page.dart`

Dashboard per-event dengan tabs:
1. **Peserta** - List booking + manual input + QR scan
2. **Keuangan** - Pemasukan/Pengeluaran/Saldo
3. **Sub-Events** - Statistik kegiatan pendukung
4. **Sponsor** - Daftar sponsor
5. **Donasi** - Donasi event

#### [NEW] `lib/features/admin/presentation/pages/admin_event_form_page.dart`

Form create/edit event wizard

---

### Phase 5: Content Moderation

#### [NEW] Halaman untuk moderasi konten:

| Page | Fungsi |
|------|--------|
| `admin_news_page.dart` | CRUD berita |
| `admin_forum_page.dart` | Moderasi post/komentar |
| `admin_loker_page.dart` | Approve/Reject lowongan |
| `admin_market_page.dart` | Approve/Reject iklan |
| `admin_memory_page.dart` | Approve/Reject foto kenangan |

---

## Verification Plan

### Manual Testing

Karena ini adalah fitur admin UI-heavy, verifikasi dilakukan secara manual:

1. **Login sebagai Admin**
   - Login dengan akun yang memiliki `role: admin`
   - Pastikan hamburger menu muncul di AppBar

2. **Cek Admin Drawer**
   - Tap hamburger menu
   - Pastikan semua menu admin tampil
   - Tap setiap menu dan pastikan navigasi berfungsi

3. **Test Dashboard**
   - Verifikasi stats muncul dengan benar
   - Verifikasi recent activity load dari database

4. **Test User Management**
   - List users tampil
   - Filter berfungsi
   - Verify user berfungsi

5. **Test Event Dashboard**
   - Pilih event aktif
   - Test semua tabs (Peserta, Keuangan, Sub-Events, Sponsor, Donasi)
   - Test manual booking input

6. **Test Content Moderation**
   - Approve/Reject loker
   - Approve/Reject market
   - Approve/Reject memory

---

## User Review Required

> [!IMPORTANT]
> **Prioritas Implementasi**: Mengingat kompleksitas fitur admin, saya sarankan implementasi bertahap:
> 
> **Prioritas 1 (Must Have):**
> - Admin Drawer + Dashboard
> - User Management (verifikasi alumni)
> - Event Dashboard (peserta, keuangan)
> 
> **Prioritas 2 (Should Have):**
> - News Management
> - Loker/Market Approval
> 
> **Prioritas 3 (Nice to Have):**
> - Forum Moderation
> - Memory Approval
> - Full Event Wizard

> [!WARNING]
> **Breaking Changes**: Tidak ada breaking changes karena ini adalah fitur tambahan. User non-admin tidak akan terpengaruh.

---

## Questions

1. **Apakah prioritas implementasi di atas sudah sesuai?**

2. **Untuk Event Dashboard, apakah perlu QR Scanner untuk check-in?** (sudah ada di lofi tetapi akan menambah kompleksitas)

3. **Apakah ada fitur admin lain yang belum tercakup di lofi yang perlu ditambahkan?**
