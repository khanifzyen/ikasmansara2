# 11. Error Handling Strategy

Dokumen ini mendefinisikan **bagaimana aplikasi menangani error secara konsisten** di semua layer (Domain, Data, Presentation).

---

## 1. Prinsip Error Handling

1. **User-Friendly Messages**: Semua error ditampilkan dalam Bahasa Indonesia yang mudah dipahami.
2. **Global Handler**: Semua error dari backend dimapped ke `AppException`.
3. **Recoverable vs Fatal**: Pisahkan error yang bisa di-retry (network timeout) vs yang fatal (unauthorized).

---

## 2. Error Types (Enum)

### File: `lib/core/errors/app_error_type.dart`

```dart
enum AppErrorType {
  network,        // Tidak ada internet / Timeout
  authentication, // Token expired / Wrong credentials
  validation,     // Input user salah (email invalid, password terlalu pendek)
  notFound,       // Data tidak ditemukan (404)
  serverError,    // Server down (500)
  unauthorized,   // User tidak punya akses (403)
  unknown,        // Error yang tidak terduga
}
```

---

## 3. Custom Exception Class

### File: `lib/core/errors/app_exception.dart`

```dart
import 'app_error_type.dart';

class AppException implements Exception {
  final String message;
  final AppErrorType type;
  final int? statusCode;
  final dynamic originalError; // Untuk debugging

  const AppException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;

  // Factory untuk mapping dari berbagai error source
  factory AppException.fromNetworkException(dynamic error) {
    if (error is NetworkException) {
      return AppException(
        message: error.message,
        type: _mapStatusCodeToType(error.statusCode),
        statusCode: error.statusCode,
        originalError: error,
      );
    }
    return AppException(
      message: 'Terjadi kesalahan yang tidak diketahui',
      type: AppErrorType.unknown,
      originalError: error,
    );
  }

  static AppErrorType _mapStatusCodeToType(int? code) {
    switch (code) {
      case 400:
        return AppErrorType.validation;
      case 401:
        return AppErrorType.authentication;
      case 403:
        return AppErrorType.unauthorized;
      case 404:
        return AppErrorType.notFound;
      case 500:
      case 502:
      case 503:
        return AppErrorType.serverError;
      default:
        return AppErrorType.network;
    }
  }
}
```

---

## 4. Error Handling di Layer

### A. **Data Layer** (DataSource)

```dart
class AuthRemoteDataSource {
  Future<RecordAuth> login(String email, String password) async {
    try {
      return await _pbService.pb.collection('users').authWithPassword(email, password);
    } on ClientException catch (e) {
      // Map PocketBase error ke NetworkException
      throw mapPocketBaseError(e);
    } catch (e) {
      // Catch-all untuk error yang tidak terduga
      throw NetworkException('Koneksi gagal: ${e.toString()}');
    }
  }
}
```

### B. **Domain Layer** (UseCase)

```dart
class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<AppException, UserEntity>> call(String email, String password) async {
    try {
      final user = await repository.login(email, password);
      return Right(user);
    } on NetworkException catch (e) {
      // Map NetworkException ke AppException
      return Left(AppException.fromNetworkException(e));
    } catch (e) {
      return Left(AppException(
        message: 'Login gagal: ${e.toString()}',
        type: AppErrorType.unknown,
        originalError: e,
      ));
    }
  }
}
```

**Note**: Kita pakai `Either` dari package `dartz` atau `fpdart` untuk functional error handling.

### C. **Presentation Layer** (Controller)

```dart
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final useCase = ref.read(loginUserProvider);
    final result = await useCase(email, password);

    result.fold(
      (error) {
        // Left = Error
        state = AsyncError(error, StackTrace.current);
      },
      (user) {
        // Right = Success
        state = const AsyncData(null);
      },
    );
  }
}
```

---

## 5. UI Error Handling Pattern

### A. **Snackbar untuk Error Sementara**

```dart
ref.listen(loginControllerProvider, (previous, next) {
  if (next.hasError) {
    final error = next.error as AppException;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: AppColors.error,
        action: error.type == AppErrorType.network
            ? SnackBarAction(label: 'Coba Lagi', onPressed: _retry)
            : null,
      ),
    );
  }
});
```

### B. **Dialog untuk Error Fatal**

```dart
if (error.type == AppErrorType.authentication) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Sesi Berakhir'),
      content: Text(error.message),
      actions: [
        TextButton(
          onPressed: () {
            context.go('/login'); // Redirect ke login
          },
          child: Text('Login Ulang'),
        ),
      ],
    ),
  );
}
```

### C. **Empty State untuk Not Found**

```dart
if (state.hasError && state.error is AppException) {
  final error = state.error as AppException;
  if (error.type == AppErrorType.notFound) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.search_off, size: 100, color: AppColors.textGrey),
          Text('Data tidak ditemukan'),
        ],
      ),
    );
  }
}
```

---

## 6. Global Error Logger (Production)

Untuk production, kita perlu log error ke service seperti Sentry atau Firebase Crashlytics.

### File: `lib/core/errors/error_logger.dart`

```dart
class ErrorLogger {
  static void log(AppException error) {
    // Development: Print ke console
    if (kDebugMode) {
      print('❌ ERROR: ${error.type} - ${error.message}');
      print('   Original: ${error.originalError}');
    }

    // Production: Kirim ke Sentry
    // Sentry.captureException(error.originalError);
  }
}
```

**Cara Pakai**:

```dart
state = AsyncError(error, StackTrace.current);
ErrorLogger.log(error); // Log error
```

---

## 7. Testing Error Handling

```dart
test('Login with wrong credentials should return AppException', () async {
  final mockRepo = MockAuthRepository();
  final useCase = LoginUser(mockRepo);

  when(() => mockRepo.login(any(), any()))
      .thenThrow(NetworkException('Invalid credentials', 401));

  final result = await useCase('wrong@email.com', 'wrong');

  expect(result.isLeft(), true);
  result.fold(
    (error) {
      expect(error.type, AppErrorType.authentication);
      expect(error.message, contains('Sesi'));
    },
    (_) => fail('Should return error'),
  );
});
```

---

## 8. Checklist Implementation

Setiap kali handle error, pastikan:

- [ ] Error di-map ke `AppException` dengan `type` yang benar.
- [ ] Message user-friendly (Bahasa Indonesia).
- [ ] Error di-log (di development mode minimal).
- [ ] UI memberikan feedback jelas (Snackbar/Dialog/Empty State).

---

> [!WARNING] > **Jangan pernah tampilkan raw error message dari server ke user!**  
> Contoh buruk: "ClientException: 401 Unauthorized Token Expired".  
> Contoh baik: "Sesi Anda telah berakhir. Silakan login kembali."
