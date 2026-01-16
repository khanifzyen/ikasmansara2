# 05. Aturan Project & Workflow Developer

Dokumen ini adalah **"Konstitusi"** teknis untuk developer. Wajib dipatuhi untuk menjaga maintainability dan scalability.

## 1. Struktur Folder (Strict Feature-First Clean Architecture)

Kita tidak mengelompokkan by Type (Screen, Widget, Controller), tapi **by Feature**.
Setiap fitur adalah "mini-app" yang mandiri.

```
lib/
├── main.dart                  # Entry Point
├── app.dart                   # Root Widget (MaterialApp + GoRouter)
├── core/                      # Global/Shared Logic (No UI)
│   ├── constants/             # AppColors, AssetsPath, Strings
│   ├── errors/                # Failure Objects (ServerFailure, CacheFailure)
│   ├── theme/                 # AppTheme (ThemeData), TextStyles
│   ├── router/                # GoRouter Configuration
│   ├── network/               # Dio Client, Interceptors
│   └── utils/                 # DateFormatter, CurrencyFormatter, Validators
├── common_widgets/            # Reusable Pure Components (Design System)
│   ├── buttons/               # PrimaryButton, ScaleButton (Interaction)
│   ├── inputs/                # CustomTextField, SearchBar
│   ├── cards/                 # StandardCard, MemberCard, ProductCard
│   └── layout/                # AppScaffold, BottomNavBar
├── features/                  # Modul Fitur (Berdasarkan Lofi Analysis)
│   ├── auth/                  # Login, Register, Forgot Password
│   ├── onboard/               # Splash, Role Selection, Welcome
│   ├── home/                  # Dashboard, Banner Slider
│   ├── directory/             # Alumni List, Search, Detail
│   ├── marketplace/           # Product Grid, Detail, Add Product
│   ├── loker/                 # Job List, Detail, Submit
│   ├── donation/              # Campaign List, Detail, Payment
│   ├── forum/                 # Feed, Create Post, Comments
│   └── profile/               # User Profile, Edit, Digital Card
│       ├── data/              # Repositories Implementation, API DTOs
│       ├── domain/            # Entities, UseCases, Repository Interfaces
│       └── presentation/      # Controllers (Riverpod), UI Screens
└── main.dart
```

---

## 2. Penjelasan Layer (The Rules)

### A. Domain Layer (The "Brain")

- **Posisi**: Inti terdalam. **TIDAK BOLEH** import `flutter`, `data`, atau `presentation`.
- **Isi**:
  1.  **Entities**: Object bisnis murni (e.g., `Product`, `User`). Mutable/Immutable tergantung kebutuhan, prefer `freezed`.
  2.  **Repositories (Interfaces)**: Kontrak `abstract class` (e.g., `abstract class AuthRepository`).
  3.  **Use Cases**: Satu class = Satu logic bisnis (e.g., `LoginUser`, `GetDonationList`).

### B. Data Layer (The "Muscle")

- **Posisi**: Layer terluar yang mengurus "pekerjaan kotor" (API, DB).
- **Isi**:
  1.  **Models**: Turunan Entity dengan `fromJson`/`toJson`. (e.g., `UserModel extends UserEntity`).
  2.  **Data Sources**: Class yang panggil PocketBase SDK/Dio langsung.
  3.  **Repositories (Impl)**: Implementasi kontrak domain. Mengurus `try-catch` dan return `Either<Failure, T>`.

### C. Presentation Layer (The "Face")

- **Posisi**: Layer UI yang dilihat user.
- **Isi**:
  1.  **Controllers**: Gunakan `Riverpod` (`AsyncNotifier` / `Notifier`). Mengurus State UI (Loading, Success, Error).
  2.  **Screens**: Halaman Penuh (`Scaffold`).
  3.  **Widgets**: Komponen kecil spesifik fitur itu.

---

## 3. Rules of Engagement (Aturan Main)

### Strict Logic Separation

- ❌ **DILARANG**: Nulis logic bisnis di UI (e.g., `if (price > 5000) ...` di dalam `build()`).
- ✅ **WAJIB**: Pindahkan logic ke `UseCase` atau minimal `Controller`. UI hanya menampilkan data.

### State Management (Riverpod)

- Gunakan `ref.watch` di dalam `build` untuk rebuild UI.
- Gunakan `ref.read` di dalam callback (e.g., `.onPressed`).
- Manfaatkan `AsyncValue` (`data`, `loading`, `error`) untuk handle state API otomatis.

### Naming Conventions

- **Files**: `snake_case` (e.g., `auth_repository.dart`).
- **Classes**: `PascalCase` (e.g., `AuthRepository`).
- **Variables**: `camelCase` (e.g., `userList`).
- **Enums**: `PascalCase` (e.g., `UserRole.alumni`).

### Environment & Security

- API Key / Base URL masuk ke `.env`.
- Akses `.env` via `flutter_dotenv`.
- **Jangan commit** file `.env` ke git (tambahkan `.env` di `.gitignore`).

### Security Best Practices (WAJIB)

1. **Environment Variables**:

   ```dart
   // .env file
   POCKETBASE_URL=https://your-server.com

   // Usage in code
   final baseUrl = dotenv.get('POCKETBASE_URL');
   ```

2. **Token Storage**:

   - Gunakan `flutter_secure_storage` untuk simpan Auth Token (BUKAN `shared_preferences`).

   ```dart
   final storage = FlutterSecureStorage();
   await storage.write(key: 'auth_token', value: token);
   ```

3. **HTTPS Only**:

   - Semua request ke backend WAJIB HTTPS (kecuali localhost development).
   - Reject HTTP connection di production:

   ```dart
   if (!kDebugMode && !baseUrl.startsWith('https')) {
     throw Exception('Production must use HTTPS!');
   }
   ```

4. **Sensitive Data**:

   - JANGAN log Token, Password, atau PII (Personally Identifiable Information) ke console.
   - Gunakan `kDebugMode` untuk log development-only.

5. **Input Sanitization**:

   - Semua input wajib divalidasi sebelum kirim ke server.
   - Gunakan `validator` di `CustomTextField`.

6. **Hardcoded Secrets**:
   - ❌ DILARANG: `final apiKey = 'abc123';`
   - ✅ WAJIB: `final apiKey = dotenv.get('API_KEY');`

---

## 4. Workflow Kerja

1.  **Buat Entity & UseCase** (Domain) dulu. Tentukan apa yang _ingin_ dilakukan.
2.  **Buat Interface Repository** (Domain).
3.  **Implementasi Data Source & Model** (Data).
4.  **Implementasi Repository** (Data).
5.  **Buat Controller** (Presentation) untuk panggil UseCase.
6.  **Buat Halaman UI** (Presentation) yang consume Controller.
