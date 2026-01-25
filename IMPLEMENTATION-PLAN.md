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

## Phase 1: Foundation (Week 1-2)

### 1.1 Project Setup
- [ ] Create Flutter project: `flutter create ika_smansara`
- [ ] Setup folder structure (Clean Architecture + Feature-First)
- [ ] Install dependencies menggunakan `flutter pub add`:
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

### 1.2 Core Setup
- [ ] Setup GetIt + Injectable
- [ ] Create PocketBase client wrapper (`core/network/pb_client.dart`)
- [ ] Setup GoRouter dengan route guards
- [ ] Create base widgets (Button, Input, Card, etc.)
- [ ] Setup app theme (colors, typography dari design system)

### 1.3 PocketBase Backend
- [ ] Deploy PocketBase (local atau cloud)
- [ ] Import schema dari `SKEMA.md`
- [ ] Setup API rules dan permissions
- [ ] Create admin account

---

## Phase 2: Authentication (Week 2-3)

### 2.1 Data Layer
- [ ] `AuthRemoteDataSource` - PocketBase auth API
- [ ] `AuthLocalDataSource` - Secure storage untuk token
- [ ] `UserModel` - DTO dengan freezed

### 2.2 Domain Layer
- [ ] `User` entity
- [ ] `AuthRepository` interface
- [ ] UseCases: `Login`, `Register`, `Logout`, `GetCurrentUser`

### 2.3 Presentation Layer

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `SplashScreen` | Check auth status, routing | `index.html` |
| `OnboardingScreen` | Intro app (first time) | `onboarding.html` |
| `RoleSelectionScreen` | Pilih Alumni/Umum | `role-selection.html` |
| `LoginScreen` | Email + Password login | `login.html` |
| `RegisterAlumniScreen` | Form pendaftaran alumni | `register-alumni.html` |
| `RegisterPublicScreen` | Form pendaftaran umum | `register-public.html` |

### 2.4 BLoC
- [ ] `AuthBloc` - Handle login, register, logout
- [ ] `SplashCubit` - Check auth → route

---

## Phase 3: Home & Navigation (Week 3-4)

### 3.1 Screens

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `HomeScreen` | Dashboard utama (role-based) | `home.html`, `home-public.html` |
| `MainShell` | Bottom navigation + drawer | - |
| `ProfileScreen` | Profil user | `profile.html` |
| `EditProfileScreen` | Edit profil | `edit-profile.html` |

### 3.2 Features
- [ ] Greeting card dengan nama user
- [ ] Quick stats (upcoming events, donations)
- [ ] News carousel
- [ ] Menu shortcuts
- [ ] Bottom navigation (Home, Donasiku, Tiketku, Loker, More)
- [ ] Side drawer menu

---

## Phase 4: E-KTA & Directory (Week 4-5)

### 4.1 E-KTA (Alumni Only)

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `EKTAScreen` | Kartu alumni digital + QR | `ekta.html` |

- [ ] Generate QR code dari user ID
- [ ] Card flip animation
- [ ] Share/download kartu

### 4.2 Directory

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `DirectoryScreen` | List alumni dengan filter | `directory.html` |
| `DirectoryDetailScreen` | Detail profil alumni | - |

- [ ] Search by nama, angkatan
- [ ] Filter by domisili, pekerjaan
- [ ] Infinite scroll pagination

---

## Phase 5: Events & Tickets (Week 5-7)

### 5.1 Screens

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `EventDetailScreen` | Detail event + booking | `event-detail.html` |
| `TicketListScreen` | List tiket user | `tiketku.html` |
| `TicketDetailScreen` | Detail tiket + QR | - |

### 5.2 Features
- [ ] Event detail dengan countdown
- [ ] Ticket booking flow (qty, size, sub-events)
- [ ] Payment integration (VA simulation)
- [ ] E-ticket dengan QR code
- [ ] Sub-event registration
- [ ] Shirt pickup status

---

## Phase 6: Donations (Week 7-8)

### 6.1 Screens

| Screen | Deskripsi | Referensi Lofi |
|--------|-----------|----------------|
| `DonationListScreen` | List campaign donasi | `donation.html` |
| `DonationDetailScreen` | Detail campaign + progress | `donation-detail.html` |
| `DonationPaymentScreen` | Form donasi + payment | `donation-payment.html` |
| `MyDonationsScreen` | Riwayat donasi user | `donasiku.html` |

### 6.2 Features
- [ ] Progress bar dengan animasi
- [ ] Donatur list (recent)
- [ ] Anonymous donation option
- [ ] Payment methods
- [ ] Transaction history dengan filter

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
