# Implementation Plan - IKA SMANSARA Mobile App

Dokumen ini berisi rencana implementasi lengkap aplikasi mobile IKA SMANSARA menggunakan **Flutter** dan **PocketBase**.

---

## Tech Stack

| Kategori | Teknologi | Kegunaan |
|----------|-----------|----------|
| Framework | Flutter 3.x | Cross-platform mobile |
| Backend | PocketBase | Auth, Database, Realtime |
| State | BLoC + Cubit | State management |
| DI | GetIt + Injectable | Dependency injection |
| Routing | GoRouter | Deep linking |
| Storage | Drift + Secure Storage | Local cache & tokens |

---

## Arsitektur

```
lib/
├── core/                   # Shared utilities
│   ├── constants/          # App constants, colors, strings
│   ├── errors/             # Failure & Exception classes
│   ├── network/            # PocketBase client wrapper
│   ├── router/             # GoRouter config
│   ├── di/                 # GetIt injection
│   └── widgets/            # Shared UI components
├── features/
│   ├── auth/
│   ├── home/
│   ├── ekta/
│   ├── directory/
│   ├── events/
│   ├── donations/
│   ├── news/
│   ├── forum/
│   ├── loker/
│   ├── market/
│   └── memory/
└── main.dart
```

---

## Phase 1: Foundation (Week 1-2) ✅

### 1.1 Project Setup ✅
- [x] Create Flutter project: `flutter create ika_smansara`
- [x] Setup folder structure (Clean Architecture + Feature-First)
- [x] Install dependencies menggunakan `flutter pub add`:
  ```bash
  # State Management & Architecture
  flutter pub add flutter_bloc bloc
  flutter pub add go_router
  flutter pub add get_it injectable
  flutter pub add freezed_annotation json_annotation
  
  # Network & Backend
  flutter pub add dio pocketbase
  
  # Local Storage
  flutter pub add flutter_secure_storage drift sqlite3_flutter_libs
  flutter pub add shared_preferences flutter_dotenv
  
  # UI Components
  flutter pub add google_fonts flutter_svg
  flutter pub add cached_network_image shimmer
  flutter pub add qr_flutter mobile_scanner
  
  # Utilities
  flutter pub add intl equatable
  
  # Dev Dependencies
  flutter pub add --dev build_runner
  flutter pub add --dev freezed json_serializable
  flutter pub add --dev injectable_generator
  flutter pub add --dev drift_dev
  ```

### 1.2 Core Setup ✅
- [x] Setup GetIt + Injectable
- [x] Create PocketBase client wrapper (`core/network/pb_client.dart`)
- [x] Setup GoRouter dengan route guards
- [x] Create base widgets (Button, Input, Card, etc.)
- [x] Setup app theme (colors, typography dari design system)

### 1.3 PocketBase Backend ⏭️ (Skipped - Sudah setup oleh user)
- [x] Deploy PocketBase (local atau cloud)
- [x] Import schema dari `SKEMA.md`
- [x] Setup API rules dan permissions
- [x] Create admin account

---

## Phase 2: Authentication (Week 2-3)

### 2.1 Data Layer
- [x] `AuthRemoteDataSource` - PocketBase auth API
- [x] `AuthLocalDataSource` - Secure storage untuk token (Managed by `PBClient`)
- [x] `UserModel` - DTO dengan freezed

### 2.2 Domain Layer
- [x] `User` entity
- [x] `AuthRepository` interface
- [x] UseCases: `Login`, `Register`, `Logout`, `GetCurrentUser` (Implemented in Bloc/Repo)

### 2.3 Presentation Layer

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `SplashScreen` | Check auth status, routing | `index.html` |
| `OnboardingScreen` | Intro app (first time) | `onboarding.html` |
| `RoleSelectionScreen` | Pilih Alumni/Umum | `role-selection.html` |
| `LoginScreen` | Email + Password login | `login.html` |
| `RegisterAlumniScreen` | Form pendaftaran alumni | `register-alumni.html` |
| `RegisterPublicScreen` | Form pendaftaran umum | `register-public.html` |

- [x] Implementasi UI Screens di atas
- [x] Branding & Theming (Sesuai Lofi style)

### 2.4 BLoC
- [x] `AuthBloc` - Handle login, register, logout
- [x] `Splash` Logic - Check auth + Onboarding → route

---

## Phase 3: Home & Navigation (Week 3-4)

### 3.1 Screens

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `HomeScreen` | Dashboard utama (role-based) | `home.html`, `home-public.html` |
| `MainShell` | Bottom navigation + drawer | - |
| `ProfileScreen` | Profil user | `profile.html` |
| `EditProfileScreen` | Edit profil | `edit-profile.html` |

- [x] Implementasi UI Screens & Navigation Shell

### 3.2 Features
- [x] Greeting card dengan nama user
- [x] Quick stats (upcoming events, donations)
- [x] News carousel
- [x] Menu shortcuts
- [x] Bottom navigation (Home, Donasiku, Tiketku, Loker, More)
- [x] Side drawer menu

---

## Phase 4: E-KTA & Directory (Week 4-5)

### 4.1 E-KTA (Alumni Only)

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `EKTAScreen` | Kartu alumni digital + QR | `ekta.html` |

- [x] Generate QR code dari user ID (UI Placeholder)
- [x] Card flip animation (Visual Only)
- [x] Share/download kartu (UI Only)

### 4.2 Directory

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `DirectoryScreen` | List alumni dengan filter | `directory.html` |
| `DirectoryDetailScreen` | Detail profil alumni | - |

- [x] Search by nama, angkatan
- [x] Filter by domisili, pekerjaan
- [x] Infinite scroll pagination (UI Implementation)

---

## Phase 5: Events & Tickets (Week 5-7)

### 5.1 Screens

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `EventDetailScreen` | Detail event + booking | `event-detail.html` |
| `TicketListScreen` | List tiket user | `tiketku.html` |
| `TicketDetailScreen` | Detail tiket + QR | - |

- [x] Implementasi UI Screens

### 5.2 Features
- [x] Event detail dengan info lengkap
- [x] Ticket booking flow (qty, size selection mock)
- [x] Payment integration (UI Simulation)
- [x] E-ticket dengan QR code (QrImageView)
- [x] Sub-event registration (Tab Section)
- [x] Shared content for Sponsors & Donations

---

## Phase 6: Donations (Week 7-8)

### 6.1 Screens

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `DonationListScreen` | Daftar kampanye donasi | `donation.html` |
| `DonationDetailScreen` | Detail kampanye + payment | `donation-detail.html` |
| `MyDonationsScreen` | Riwayat donasi user | `donasiku.html` |

- [x] Implementasi UI Screens

### 6.2 Features
- [x] Campaign slider di Home
- [x] Campaign list dengan progress bar
- [x] Donation detail dengan urgent badge
- [x] Payment simulation (VA popup)
- [x] Donatur list (Real-time mock)
- [x] Progress bar dengan animasi
- [x] Donatur list (recent)
- [x] Anonymous donation option
- [x] Payment methods
- [x] Transaction history dengan filter

---

## Phase 7: News & Forum (Week 8-9)

### 7.1 News

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `NewsListScreen` | List berita | `news-list.html` |
| `NewsDetailScreen` | Detail berita | `news-detail.html` |

### 7.2 Forum

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `ForumScreen` | Feed diskusi | `forum.html` |
| `ForumDetailScreen` | Detail post + comments | `forum-detail.html` |
| `CreatePostScreen` | Buat postingan baru | - |

### 7.3 Features
- [ ] Category tabs (Semua, Karir, Nostalgia, Bisnis)
- [ ] Like/unlike posts
- [ ] Comment system
- [ ] Image attachment
- [ ] Post visibility (public/alumni only)

---

## Phase 8: Loker & Market (Week 9-10)

### 8.1 Loker (Lowongan Kerja)

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `LokerListScreen` | List lowongan | `loker.html` |
| `LokerDetailScreen` | Detail lowongan | `loker-detail.html` |
| `LokerPostScreen` | Form posting loker | `loker-post.html` |
| `MyLokerScreen` | Loker yang dipost user | `my-loker.html` |

### 8.2 Market

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `MarketScreen` | List produk | `market.html` |
| `MarketDetailScreen` | Detail produk | `market-detail.html` |
| `MarketSellScreen` | Form jual barang | `market-sell.html` |
| `MyShopScreen` | Produk user | `my-shop.html` |

### 8.3 Features
- [ ] Search dan filter (kategori, lokasi, tipe)
- [ ] Contact seller (WhatsApp link)
- [ ] Image gallery
- [ ] Status moderation (pending, approved)

---

## Phase 9: Memory Gallery (Week 10-11)

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `MemoryScreen` | Galeri foto kenangan | `memory.html` |
| `UploadMemoryScreen` | Upload foto | - |

### Features
- [ ] Masonry grid layout
- [ ] Filter by tahun/dekade
- [ ] Sepia effect untuk foto lama
- [ ] Upload foto jadul
- [ ] Admin approval

---

## Phase 10: Polish & Testing (Week 11-12)

### 10.1 UI Polish
- [ ] Loading shimmer effects
- [ ] Empty state illustrations
- [ ] Error state UI
- [ ] Pull-to-refresh
- [ ] Smooth animations & transitions

### 10.2 Offline Support
- [ ] Cache news & events dengan Drift
- [ ] Offline indicator
- [ ] Queue pending actions

### 10.3 Testing
- [ ] Unit tests (BLoC, Repository)
- [ ] Widget tests
- [ ] Integration tests
- [ ] E2E testing

### 10.4 Deployment
- [ ] App icons & splash screen
- [ ] Build Android APK/AAB
- [ ] Build iOS IPA
- [ ] Play Store submission
- [ ] App Store submission

---

## Timeline Summary

| Week | Phase | Deliverables |
|------|-------|--------------|
| 1-2 | Foundation | Project setup, core modules, PocketBase |
| 2-3 | Auth | Login, register, splash, onboarding |
| 3-4 | Home | Dashboard, navigation, profile |
| 4-5 | E-KTA & Directory | Alumni card, directory search |
| 5-7 | Events | Event detail, booking, e-ticket |
| 7-8 | Donations | Campaigns, payment, history |
| 8-9 | News & Forum | Articles, discussions |
| 9-10 | Loker & Market | Jobs, marketplace |
| 10-11 | Memory | Photo gallery |
| 11-12 | Polish | Testing, optimization, deployment |

**Estimated Total: 12 Weeks**

---

## Role-Based Access Matrix

| Feature | Alumni (Verified) | Public | Guest |
|---------|-------------------|--------|-------|
| Home Dashboard | ✅ Full | ✅ Limited | ❌ |
| E-KTA | ✅ | ❌ | ❌ |
| Directory | ✅ Full | ❌ | ❌ |
| Events - View | ✅ | ✅ | ✅ |
| Events - Register | ✅ | ✅ | ❌ |
| Donations - View | ✅ | ✅ | ✅ |
| Donations - Donate | ✅ | ✅ | ✅ |
| News | ✅ | ✅ | ✅ |
| Forum - View | ✅ | ✅ | ❌ |
| Forum - Post | ✅ | ❌ | ❌ |
| Loker - View | ✅ Full | ✅ Limited | ❌ |
| Loker - Post | ✅ | ❌ | ❌ |
| Market - View | ✅ | ✅ | ❌ |
| Market - Sell | ✅ | ❌ | ❌ |
| Memory | ✅ | ❌ | ❌ |

---

## API Endpoints (PocketBase)

```
# Auth
POST   /api/collections/users/auth-with-password
POST   /api/collections/users/records
POST   /api/collections/users/confirm-verification

# Users
GET    /api/collections/users/records
GET    /api/collections/users/records/:id
PATCH  /api/collections/users/records/:id

# Events
GET    /api/collections/events/records
GET    /api/collections/events/records/:id
GET    /api/collections/event_tickets/records?filter=(event=':id')
GET    /api/collections/event_sub_events/records?filter=(event=':id')
POST   /api/collections/event_registrations/records

# Donations
GET    /api/collections/donations/records
GET    /api/collections/donations/records/:id
POST   /api/collections/donation_transactions/records
GET    /api/collections/donation_transactions/records?filter=(user=':id')

# News
GET    /api/collections/news/records?filter=(status='published')
GET    /api/collections/news/records/:id

# Forum
GET    /api/collections/forum_posts/records
POST   /api/collections/forum_posts/records
POST   /api/collections/forum_comments/records
POST   /api/collections/forum_likes/records

# Loker
GET    /api/collections/loker/records?filter=(status='approved')
POST   /api/collections/loker/records
GET    /api/collections/loker/records?filter=(user=':id')

# Market
GET    /api/collections/market/records?filter=(status='approved')
POST   /api/collections/market/records
GET    /api/collections/market/records?filter=(user=':id')

# Memory
GET    /api/collections/memories/records?filter=(is_approved=true)
POST   /api/collections/memories/records
```

---

## Next Steps

1. **Setup PocketBase** - Deploy dan import schema
2. **Create Flutter Project** - Dengan struktur folder
3. **Implement Auth** - Login/Register flow
4. **Build Home Screen** - Dashboard layout
5. **Iterate per feature** - Sesuai timeline
