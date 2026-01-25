# Spesifikasi Teknis Aplikasi IKA SMANSARA (Mobile App)

Dokumen ini berisi spesifikasi teknis, arsitektur, dan alur kerja aplikasi mobile IKA SMANSARA yang akan dibangun ulang menggunakan **Flutter** dan **PocketBase**.

## 1. Tech Stack & Libraries

*   **Framework:** Flutter (Stable Channel)
*   **Language:** Dart
*   **Backend & Auth:** PocketBase
*   **Architecture:** Clean Architecture + Feature-First
*   **State Management:** BLoC Pattern (`flutter_bloc`)

### Key Packages
| Kategori | Package | Kegunaan |
| :--- | :--- | :--- |
| **State Management** | `flutter_bloc`, `bloc` | Manajemen state yang terprediksi |
| **Code Generation** | `freezed`, `json_serializable` | Immutable state, Union Types, JSON parsing |
| **Dependency Injection** | `get_it`, `injectable` | Service locator & auto-generation DI |
| **Routing** | `go_router` | Navigasi dengan support Deep Link & Redirection |
| **Functional Programming** | `fpdart` | Error handling functional (`Either<Failure, Success>`) |
| **HTTP Client** | `dio` (Recommended) / `http` | Koneksi API (atau internal PocketBase SDK) |
| **Local Database** | `drift` (`sqlite3`) | Penyimpanan data lokal (Cache, Draft) |
| **Secure Storage** | `flutter_secure_storage` | Menyimpan Token & Session sensitif |
| **UI Components** | `google_fonts`, `flutter_svg` | Typography & Assets |

## 2. Arsitektur Aplikasi

Aplikasi menerapkan **Clean Architecture** dengan struktur folder **Feature-First**.

### Layering (Lapisan)
1.  **Presentation Layer**
    *   **Pages/Screens:** UI Widget.
    *   **BLoC/Cubit:** Logika presentasi & state mapping.
2.  **Domain Layer** (Pure Dart, No Flutter UI, No Third Party Implementations)
    *   **Entities:** Bisnis objek murni.
    *   **UseCases:** Logika bisnis tunggal (opsional, jika kompleks).
    *   **Repository Interfaces:** Kontrak (abstract class) untuk mengambil data.
3.  **Data Layer**
    *   **Models/DTOs:** Representasi data JSON/DB.
    *   **Data Sources:** Akses langsung ke API (PocketBase) atau Local DB (Drift).
    *   **Repository Impl:** Implementasi interface repository, menggabungkan Remote & Local source.

### Struktur Folder
```text
lib/
├── core/                   # Shared logic/utils
│   ├── errors/             # Failure definitions
│   ├── network/            # Dio/PocketBase client connection
│   ├── router/             # GoRouter configuration
│   └── di/                 # Injection container (GetIt)
├── features/               # Fitur modular
│   ├── auth/               # Login, Register, Splash
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/               # Dashboard, Navigation
│   ├── directory/          # Direktori Alumni
│   ├── jobs/               # Loker
│   ├── donation/           # Donasi
│   ├── market/             # Marketplace
│   └── ...
└── main.dart
```

## 3. Hak Akses Pengguna (Roles)

1.  **Alumni (Full Access)**
    *   Syarat: Verifikasi (Tahun Angkatan/NIS).
    *   Hak: E-KTA, Direktori Full, Loker (Post/View), Market (Jual/Beli), Forum, Donasi.
2.  **Masyarakat Umum (Public) / Guest**
    *   Hak: Berita Sekolah, Donasi (View/Pay), Market (View Only).
    *   Batasan: Tidak punya E-KTA, Loker terbatas/hidden, tidak bisa post Forum.

## 4. Skema Database (PocketBase)

### `users`
*   `role`: 'alumni' | 'public'
*   `graduation_year`: Number (Alumni)
*   `is_verified`: Bool
*   `avatar`: File

### `donations` & `donation_logs`
*   Tracking program donasi dan riwayat transaksi.

### `jobs` (Loker)
*   Lowongan kerja, relasi ke user poster.

### `products` (Market)
*   Jual beli, relasi ke seller (user).

### `news`
*   Berita/Artikel.

*(Detail skema field mengikuti rancangan sebelumnya dan disesuaikan saat development)*

## 5. Rencana Implementasi

### Step 1: Foundation Setup
*   `flutter create`
*   Setup `build_runner`, `freezed`, `injectable`.
*   Setup `go_router` & base layouts.
*   Setup PocketBase Client & `drift` Database connection.

### Step 2: Authentication Feature
*   Data Layer: Auth Remote Source (PocketBase), Auth Local Source (Secure Storage).
*   Domain Layer: Login, Register, CheckAuthStatus UseCases.
*   Presentation: Login Page, Register UI, Splash Screen routing logic.

### Step 3: Core Features (Phase 1)
*   **Home Dashboard**: Menyesuaikan tampilan by Role.
*   **E-KTA (Alumni)**: Generate QR/Card view.
*   **News**: Fetch list berita dari PocketBase.

### Step 4: Transaction & Data Features (Phase 2)
*   **Donations**: CRUD Donasi, Payment Gateway Simulation.
*   **Jobs (Loker)**: List & Detail Loker.
*   **Local Storage Sync**: Cache data user/news menggunakan **Drift** untuk offline support (optional).

### Step 5: Polishing
*   Error Handling global (Functional approach).
*   Loading Shimmers.
*   Unit Testing (BLoC & Repositories).
