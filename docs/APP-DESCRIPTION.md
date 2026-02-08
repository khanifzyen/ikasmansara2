# Dokumentasi Aplikasi Flutter: IKA SMANSARA

Dokumentasi komprehensif aplikasi Flutter `ika_smansara` yang merupakan implementasi mobile dari platform IKA SMANSARA (Ikatan Alumni SMA Negeri 1 Jepara).

---

## Daftar Isi

1. [Gambaran Umum](#1-gambaran-umum)
2. [Tech Stack](#2-tech-stack)
3. [Arsitektur Aplikasi](#3-arsitektur-aplikasi)
4. [Struktur Folder](#4-struktur-folder)
5. [Sistem User & Role](#5-sistem-user--role)
6. [Halaman & Fitur](#6-halaman--fitur)
7. [Data Models & Entities](#7-data-models--entities)
8. [Navigation Flow](#8-navigation-flow)
9. [State Management](#9-state-management)

---

## 1. Gambaran Umum

| Aspek | Detail |
|-------|--------|
| **Nama Aplikasi** | IKA SMANSARA |
| **Versi** | 2.0.1+32 |
| **SDK** | Flutter ^3.10.7 |
| **Backend** | PocketBase |
| **Payment Gateway** | Midtrans (Snap) |
| **Target Platform** | Android, iOS, Web, Desktop |

### Fitur Utama
- 🎓 **E-KTA Digital**: Kartu tanda anggota alumni digital dengan QR Code
- 📅 **Event Management**: Pendaftaran, pemesanan tiket, dan pembayaran event
- 💰 **Donasi**: Program penggalangan dana dengan payment gateway
- 📰 **Berita**: Kabar terbaru dari SMANSARA
- 💬 **Forum**: Diskusi komunitas alumni
- 💼 **Loker**: Lowongan kerja dari dan untuk alumni
- 🛒 **Market**: Marketplace produk/jasa alumni
- 📷 **Memory**: Galeri kenangan album foto
- 👤 **Profile**: Manajemen profil dan direktori alumni

---

## 2. Tech Stack

### Dependencies Utama

| Package | Versi | Fungsi |
|---------|-------|--------|
| `flutter_bloc` | ^9.1.1 | State management |
| `go_router` | ^17.0.1 | Navigation & routing |
| `get_it` | ^9.2.0 | Dependency injection |
| `injectable` | ^2.7.1 | DI code generation |
| `pocketbase` | ^0.23.2 | Backend SDK |
| `dio` | ^5.9.0 | HTTP client |
| `freezed` | ^3.2.4 | Immutable data classes |
| `cached_network_image` | ^3.4.1 | Image caching |
| `qr_flutter` | ^4.1.0 | QR code generation |
| `mobile_scanner` | ^7.1.4 | QR code scanning |
| `webview_flutter` | ^4.13.1 | Payment webview |
| `print_bluetooth_thermal` | ^1.1.9 | Bluetooth printing |

### Dev Dependencies

| Package | Fungsi |
|---------|--------|
| `build_runner` | Code generation |
| `freezed` | Immutable models |
| `json_serializable` | JSON serialization |
| `injectable_generator` | DI generation |
| `flutter_launcher_icons` | App icons |
| `flutter_native_splash` | Splash screen |

---

## 3. Arsitektur Aplikasi

### Clean Architecture

```
┌─────────────────────────────────────────────────────┐
│                  PRESENTATION                        │
│  ┌─────────────────────────────────────────────────┐│
│  │  Pages (UI) ←→ BLoC (State) ←→ Widgets          ││
│  └─────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────┤
│                    DOMAIN                            │
│  ┌─────────────────────────────────────────────────┐│
│  │  Entities ←─ UseCases ─→ Repository (abstract)  ││
│  └─────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────┤
│                     DATA                             │
│  ┌─────────────────────────────────────────────────┐│
│  │  Models ←─ Repository (impl) ─→ DataSources     ││
│  └─────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
             ↓
    ┌────────────────┐
    │   PocketBase   │
    │   (Backend)    │
    └────────────────┘
```

### Pattern yang Digunakan

| Layer | Pattern | Deskripsi |
|-------|---------|-----------|
| Presentation | BLoC | Business Logic Component untuk state management |
| Domain | Repository | Abstract contract untuk data access |
| Domain | Use Cases | Single responsibility business operations |
| Data | DTO/Model | Data transfer objects dengan JSON serialization |
| Core | DI (Get_it) | Dependency injection container |

---

## 4. Struktur Folder

```
lib/
├── main.dart                    # Entry point
├── core/                        # Shared infrastructure
│   ├── constants/               # App-wide constants
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   ├── di/                      # Dependency injection
│   │   └── injection.dart
│   ├── errors/                  # Error handling
│   ├── network/                 # Network layer
│   │   └── pb_client.dart       # PocketBase client
│   ├── router/                  # Navigation
│   │   └── app_router.dart
│   ├── services/                # Shared services
│   │   └── printer_service.dart
│   ├── theme/                   # App theming
│   │   └── app_theme.dart
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Reusable widgets
│       ├── buttons.dart
│       └── inputs.dart
│
└── features/                    # Feature modules
    ├── admin/                   # Admin panel (19 files)
    ├── auth/                    # Authentication (17 files)
    ├── directory/               # Alumni directory
    ├── donations/               # Donation campaigns (19 files)
    ├── ekta/                    # E-KTA digital card
    ├── events/                  # Event management (42 files)
    ├── forum/                   # Community forum (18 files)
    ├── home/                    # Home dashboard
    ├── loker/                   # Job listings
    ├── news/                    # News articles (13 files)
    ├── profile/                 # User profile (8 files)
    └── settings/                # App settings (21 files)
```

---

## 5. Sistem User & Role

### User Roles

| Role | Akses | Kemampuan |
|------|-------|-----------|
| **Alumni** | Full member | Semua fitur, E-KTA, direktori alumni |
| **Public** | Limited | Berita, donasi publik, event publik |
| **Admin** | Full + Admin Panel | Semua fitur + mengelola semua konten |

### User Entity

```dart
class UserEntity {
  String id;
  String email;
  String name;
  String phone;
  String? avatar;
  int? angkatan;           // Tahun lulus
  UserRole role;           // alumni, public, admin
  JobStatus? jobStatus;    // swasta, pnsBumn, wirausaha, mahasiswa, lainnya
  String? company;
  String? domisili;
  int? noUrutAngkatan;     // Nomor urut dalam angkatan
  int? noUrutGlobal;       // Nomor urut global
  bool isVerified;
  DateTime? verifiedAt;
}
```

### E-KTA Numbering

Format: `{ANGKATAN}.{NO_URUT_ANGKATAN}.{NO_URUT_GLOBAL}`

Contoh: `2010.0042.1234`
- **2010** = Tahun lulus
- **0042** = Urutan ke-42 dalam angkatan 2010
- **1234** = ID member global ke-1234

---

## 6. Halaman & Fitur

### 6.1 Authentication Flow

| Halaman | Route | Deskripsi |
|---------|-------|-----------|
| `SplashPage` | `/` | Logo + auto-login check → onboarding/home |
| `OnboardingPage` | `/onboarding` | 3 slides (Connect, Career, Contribute) |
| `RoleSelectionPage` | `/role-selection` | Pilih Alumni atau Umum |
| `LoginPage` | `/login` | Email + password login |
| `RegisterAlumniPage` | `/register/alumni` | Form pendaftaran alumni (detail) |
| `RegisterPublicPage` | `/register/public` | Form pendaftaran umum (sederhana) |
| `ForgotPasswordPage` | `/forgot-password` | Reset password via email |

**Flow Diagram**:
```
Splash → Auth Check?
   ↓ Yes (logged in)     → Home
   ↓ No (first time)     → Onboarding → Role Selection
   ↓ No (returning)      → Role Selection → Login/Register
```

---

### 6.2 Main Shell (Bottom Navigation)

| Tab | Route | Halaman | Deskripsi |
|-----|-------|---------|-----------|
| Home | `/home` | `HomePage` | Dashboard utama |
| Donasiku | `/donations` | `MyDonationsPage` | Riwayat donasi user |
| Tiketku | `/tickets` | `MyTicketsPage` | Tiket event user |
| Loker | `/loker` | `LokerListPage` | Daftar lowongan kerja |

---

### 6.3 Home Page

**Component Structure**:
```
┌─────────────────────────────────────┐
│ Header: Nama + Avatar + Admin/Scan  │
├─────────────────────────────────────┤
│ E-KTA Preview Card                  │
│ ┌─────────────────────────────────┐ │
│ │ ANGKATAN 2010                   │ │
│ │ 2010.0042.1234                  │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Menu Grid 4×2                       │
│ [Donasi][Kegiatan][Berita][Loker]  │
│ [Market][Forum][Direktori][Profil] │
├─────────────────────────────────────┤
│ Agenda Kegiatan (Horizontal Scroll) │
│ [Event Card] [Event Card] ...       │
├─────────────────────────────────────┤
│ Program Donasi (Horizontal Scroll)  │
│ [Donation Card] [Donation Card]...  │
├─────────────────────────────────────┤
│ Kabar SMANSARA (Vertical List)      │
│ [News Card]                         │
│ [News Card]                         │
│ [News Card]                         │
└─────────────────────────────────────┘
```

**Data Fetching**:
- `DonationListBloc` → `FetchDonations()`
- `EventsBloc` → `FetchEvents()`
- `NewsBloc` → `FetchNewsList()`

**Conditional Rendering**:
- Admin Panel button: hanya untuk `user.isAdmin == true`
- QR Scanner button: tersedia untuk semua user

---

### 6.4 Event Module

| Halaman | Route | Deskripsi |
|---------|-------|-----------|
| `EventListPage` | `/events` | Daftar semua event |
| `EventDetailPage` | `/event-detail` | Detail event + tabs |
| `MyTicketsPage` | `/tickets` | Tiket yang dimiliki |
| `MyTicketDetailPage` | - | Detail tiket + QR |
| `TicketDetailPage` | `/ticket-detail` | Preview tiket |
| `MidtransPaymentPage` | `/payment` | WebView pembayaran |
| `TicketScannerPage` | `/ticket-scanner` | QR scanner untuk absensi |

**Event Detail Tabs**:
1. **Info** - Deskripsi event
2. **Tiket** - Pilih dan pesan tiket
3. **Sub-Event** - Kegiatan pendukung (opsional)
4. **Sponsor** - Daftar sponsor (opsional)
5. **Donasi** - Donasi event (opsional)

**Booking Flow**:
```
Event Detail → Pilih Tiket → Cart Summary
    ↓
Create Booking (status: pending)
    ↓
Get Snap Token → Open Payment WebView
    ↓
Complete Payment → Webhook update
    ↓
Booking Status: paid → Generate Tickets
```

---

### 6.5 Donation Module

| Halaman | Route | Deskripsi |
|---------|-------|-----------|
| `DonationListPage` | `/donation-list` | Daftar kampanye donasi |
| `DonationDetailPage` | `/donation-detail` | Detail + bayar donasi |
| `MyDonationsPage` | `/my-donations` | Riwayat donasi user |

**Donation Entity**:
```dart
class Donation {
  String id;
  String title;
  String description;
  double targetAmount;
  double collectedAmount;
  DateTime deadline;
  String banner;
  String organizer;
  String category;        // infrastruktur, pendidikan, sosial, kesehatan
  String priority;        // normal, urgent
  String status;          // active, completed
  int donorCount;
}
```

**Progress Calculation**:
- `progress = collectedAmount / targetAmount`
- Clamped to 0.0 - 1.0

---

### 6.6 News Module

| Halaman | Route | Deskripsi |
|---------|-------|-----------|
| `NewsListPage` | `/news` | Daftar berita |
| `NewsDetailPage` | `/news-detail` | Detail berita (HTML rendered) |

---

### 6.7 Forum Module

| Halaman | Route | Deskripsi |
|---------|-------|-----------|
| `ForumPage` | `/forum` | Feed forum |
| `CreatePostPage` | `/create-post` | Buat postingan baru |
| `ForumDetailPage` | `/forum-detail` | Detail + komentar |

---

### 6.8 Profile & Settings

| Halaman | Route | Deskripsi |
|---------|-------|-----------|
| `ProfilePage` | `/profile` | Profil user |
| `EditProfilePage` | - | Edit profil |
| `SettingsPage` | - | Pengaturan aplikasi |
| `ChangePasswordPage` | - | Ganti password |
| `PrinterSettingsPage` | - | Pengaturan printer Bluetooth |
| `AboutPage` | - | Tentang aplikasi |

---

### 6.9 Admin Module

| Halaman | Route | Deskripsi |
|---------|-------|-----------|
| `AdminDashboardPage` | `/admin` | Dashboard statistik |
| `AdminUsersPage` | `/admin/users` | Kelola user |
| `AdminUserDetailPage` | `/admin/users/:id` | Detail user |
| `AdminEventsPage` | `/admin/events` | Kelola event |
| `AdminEventDetailPage` | `/admin/events/:id` | Dashboard event |
| `AdminPlaceholderPage` | Various | Coming soon placeholders |

**Dashboard Stats**:
```dart
AdminStatsLoaded {
  int totalUsers;
  int totalEvents;
  int totalDonations;
  int totalNews;
  int pendingUsers;      // User menunggu verifikasi
  int pendingLokers;     // Loker menunggu approval
  int pendingMarkets;    // Market menunggu approval
  int pendingMemories;   // Memory menunggu approval
}
```

**Pending Items**:
- User pending verifikasi → Badge warning
- Loker/Market/Memory pending approval → Badge info

**Quick Actions**:
- Tambah Event
- Tulis Berita
- Scan QR

---

## 7. Data Models & Entities

### Event

```dart
class Event {
  String id;
  String title;
  String description;
  DateTime date;
  String time;
  String location;
  String? banner;
  String status;              // active, draft, completed
  bool isRegistrationOpen;    // status == 'active'
}
```

### Event Booking

```dart
class EventBooking {
  String id;
  String eventId;
  String userId;
  String bookingId;           // Format: {CODE}-{YEAR}-{SEQ}
  List<dynamic> metadata;     // Cart items (ticket options, quantities)
  int totalPrice;
  String paymentStatus;       // pending, paid, expired, cancelled
  String? snapToken;          // Midtrans snap token
  String? snapRedirectUrl;    // Payment URL
  Event? event;               // Expanded relation
}
```

### Event Supporting Entities

| Entity | Fields |
|--------|--------|
| `EventTicket` | id, eventId, bookingId, ticketNumber, qrCode, metadata, status |
| `EventTicketOption` | id, name, price, description, includes, quota |
| `EventSubEvent` | id, name, description, location, quota, registered |
| `EventSponsor` | id, name, logo, tier, amount |

---

## 8. Navigation Flow

### Authentication Guard

```dart
static String? _handleRedirect(BuildContext context, GoRouterState state) {
  final isLoggedIn = PBClient.instance.isAuthenticated;
  
  // Auth routes (accessible when NOT logged in)
  final isAuthRoute = ['/login', '/register/*', '/forgot-password', 
                       '/role-selection', '/onboarding', '/'].contains(path);
  
  // If logged in + accessing auth route → redirect to /home
  if (isLoggedIn && isAuthRoute && path != '/') return '/home';
  
  // If NOT logged in + accessing protected route → redirect to /login
  if (!isLoggedIn && !isAuthRoute) return '/login';
  
  return null; // No redirect
}
```

### Shell Navigation

```
StatefulShellRoute.indexedStack
├── Branch 0: /home       → HomePage
├── Branch 1: /donations  → MyDonationsPage
├── Branch 2: /tickets    → MyTicketsPage
└── Branch 3: /loker      → LokerListPage
```

### External Routes (Outside Shell)

```
/profile, /directory, /ekta, /forum
/events, /event-detail, /ticket-detail
/donation-list, /donation-detail
/news, /news-detail
/payment, /ticket-scanner
/admin/*
```

---

## 9. State Management

### BLoC Pattern

Setiap feature memiliki BLoC sendiri:

| Feature | BLoC | Events | States |
|---------|------|--------|--------|
| Auth | `AuthBloc` | Login, Logout, CheckAuth | Authenticated, Unauthenticated, Error |
| Settings | `SettingsBloc` | LoadSettings | SettingsLoaded |
| Events | `EventsBloc` | FetchEvents | EventsLoaded, EventsError |
| Event Booking | `EventBookingBloc` | CreateBooking, Pay | BookingCreated, PaymentPending |
| Donations | `DonationListBloc` | FetchDonations | DonationsLoaded |
| Donation Detail | `DonationDetailBloc` | LoadDetail, Donate | DetailLoaded |
| News | `NewsBloc` | FetchNewsList | NewsLoaded |
| Admin | `AdminStatsBloc` | LoadStats | StatsLoaded |

### Global Providers

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
    ),
    BlocProvider<SettingsBloc>(
      create: (_) => getIt<SettingsBloc>()..add(LoadAppSettings()),
    ),
  ],
  child: MaterialApp.router(...),
)
```

### Theme Mode

```dart
BlocBuilder<SettingsBloc, SettingsState>(
  builder: (context, state) {
    ThemeMode themeMode = ThemeMode.system;
    if (state is SettingsLoaded) {
      themeMode = state.settings.themeMode;  // 'light', 'dark', 'system'
    }
    return MaterialApp.router(
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  },
)
```

---

## 10. Integrasi External

### PocketBase

```dart
class PBClient {
  static final PBClient instance = PBClient._();
  late final PocketBase pb;
  
  PBClient._() {
    pb = PocketBase(AppConstants.pocketBaseUrl);
  }
  
  bool get isAuthenticated => pb.authStore.isValid;
}
```

### Midtrans Payment

```dart
class MidtransPaymentPage extends StatelessWidget {
  final String paymentUrl;      // Snap redirect URL
  final String bookingId;
  final bool fromEventDetail;
  
  // WebView loads paymentUrl
  // On success/failure, callback handled
}
```

### Bluetooth Printer

```dart
class PrinterService {
  // Permission handling for Android 12+
  // Device discovery
  // Connect to thermal printer
  // ESC/POS formatting for tickets
}
```

---

## 11. Assets

```yaml
flutter:
  assets:
    - .env
    - assets/images/
    - assets/images/onboarding/
```

### Key Images
- `logo-ika.png` - Logo aplikasi
- `logo-ika-1.png` - Splash & launcher icon
- `placeholder_event.png` - Event fallback
- `placeholder_news.png` - News fallback

---

## 12. Environment

```env
# .env
POCKETBASE_URL=https://your-pocketbase-url.com
```

---

*Dokumentasi ini dibuat untuk referensi developer dalam memahami struktur dan flow aplikasi Flutter IKA SMANSARA.*
