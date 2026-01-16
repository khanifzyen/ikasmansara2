# 10. Service Layer Pattern (PocketBase Integration)

Dokumen ini mendefinisikan **bagaimana Flutter berkomunikasi dengan PocketBase Backend** secara konsisten dan maintainable.

---

## 1. Core Concept: Singleton Service

Kita akan membuat **satu instance global** `PocketBaseService` yang digunakan oleh semua `DataSource`.

**Alasan**:

- Menghindari multiple connection ke server.
- Centralized Token Management.
- Mudah untuk mock saat testing.

---

## 2. Struktur File

```
lib/core/network/
  ├── pocketbase_service.dart    # Singleton PocketBase Client
  ├── api_endpoints.dart          # Konstanta endpoint (collection names)
  └── network_exceptions.dart     # Custom Exception Mapper
```

---

## 3. Implementation Blueprint

### A. `pocketbase_service.dart`

```dart
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PocketBaseService {
  // Singleton Pattern
  static final PocketBaseService _instance = PocketBaseService._internal();
  factory PocketBaseService() => _instance;
  PocketBaseService._internal();

  // PocketBase Client Instance
  late final PocketBase pb;

  // Initialize (dipanggil di main.dart)
  Future<void> init() async {
    final baseUrl = dotenv.get('POCKETBASE_URL', fallback: 'http://127.0.0.1:8090');
    pb = PocketBase(baseUrl);

    // Auto-refresh token jika sudah ada session
    if (pb.authStore.isValid) {
      await _refreshToken();
    }
  }

  // Token Refresh (Auto-called setiap request jika token hampir expired)
  Future<void> _refreshToken() async {
    try {
      await pb.collection('users').authRefresh();
    } catch (e) {
      // Jika refresh gagal, clear auth
      pb.authStore.clear();
    }
  }

  // Helper: Get Current User
  RecordModel? get currentUser => pb.authStore.model;

  // Helper: Check if Authenticated
  bool get isAuthenticated => pb.authStore.isValid;

  // Logout
  void logout() {
    pb.authStore.clear();
  }
}
```

---

### B. `api_endpoints.dart`

```dart
class ApiEndpoints {
  // Collection Names (sesuai PocketBase Schema)
  static const String users = 'users';
  static const String products = 'products';
  static const String jobs = 'loker';
  static const String donations = 'donations';
  static const String forumPosts = 'forum_posts';
  static const String forumComments = 'forum_comments';
}
```

---

### C. `network_exceptions.dart`

```dart
import 'package:pocketbase/pocketbase.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

// Mapper dari ClientException (PocketBase) ke App-Specific Exception
NetworkException mapPocketBaseError(ClientException e) {
  switch (e.statusCode) {
    case 400:
      return NetworkException('Data tidak valid. Periksa input Anda.', 400);
    case 401:
      return NetworkException('Sesi Anda telah berakhir. Silakan login kembali.', 401);
    case 403:
      return NetworkException('Anda tidak memiliki akses ke fitur ini.', 403);
    case 404:
      return NetworkException('Data tidak ditemukan.', 404);
    case 500:
      return NetworkException('Terjadi kesalahan pada server. Coba lagi nanti.', 500);
    default:
      return NetworkException('Koneksi gagal. Periksa internet Anda.', e.statusCode);
  }
}
```

---

## 4. Cara Pakai di DataSource

### Contoh: `AuthRemoteDataSource`

```dart
import '../../../core/network/pocketbase_service.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/network_exceptions.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthRemoteDataSource {
  final PocketBaseService _pbService;

  AuthRemoteDataSource(this._pbService);

  Future<RecordAuth> login(String email, String password) async {
    try {
      final result = await _pbService.pb
          .collection(ApiEndpoints.users)
          .authWithPassword(email, password);

      return result;
    } on ClientException catch (e) {
      throw mapPocketBaseError(e); // Map ke NetworkException
    }
  }
}
```

---

## 5. Riverpod Provider Setup

Di `lib/core/network/providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'pocketbase_service.dart';

part 'providers.g.dart';

@riverpod
PocketBaseService pocketBaseService(PocketBaseServiceRef ref) {
  return PocketBaseService();
}
```

**Cara Pakai di Repository**:

```dart
@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  final pbService = ref.watch(pocketBaseServiceProvider);
  return AuthRemoteDataSource(pbService);
}
```

---

## 6. Environment Variables (.env)

Buat file `.env` di root project:

```env
POCKETBASE_URL=http://127.0.0.1:8090
```

**PENTING**: Tambahkan `.env` ke `.gitignore`!

---

## 7. Initialization di `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await PocketBaseService().init(); // Init PocketBase

  runApp(const ProviderScope(child: IkasmansaraApp()));
}
```

---

## 8. Testing Strategy

Untuk Unit Test, kita akan mock `PocketBaseService`:

```dart
class MockPocketBaseService extends Mock implements PocketBaseService {}

void main() {
  test('Login Success', () async {
    final mockPbService = MockPocketBaseService();
    final dataSource = AuthRemoteDataSource(mockPbService);

    // Set up mock behavior
    when(() => mockPbService.pb.collection('users').authWithPassword(...))
        .thenAnswer((_) async => fakeRecordAuth);

    final result = await dataSource.login('test@test.com', 'password');
    expect(result, isNotNull);
  });
}
```

---

## 9. Network Timeout Configuration

Tambahkan timeout di `PocketBaseService.init()`:

```dart
pb = PocketBase(
  baseUrl,
  httpClientFactory: () => http.Client()..timeout = Duration(seconds: 30),
);
```

---

> [!IMPORTANT] > **Semua DataSource wajib menggunakan `PocketBaseService` singleton.** Jangan pernah buat instance `PocketBase()` baru di DataSource.
