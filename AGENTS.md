# Agent Guidelines for IKA SMANSARA

Aplikasi mobile Flutter untuk Ikatan Alumni SMAN 1 Jepara (IKA SMANSARA) dengan Clean Architecture, BLoC state management, dan PocketBase backend.

## Build, Lint, and Test Commands

### Flutter App (ika_smansara/)
```bash
flutter pub get                                    # Install dependencies
flutter pub run build_runner build --delete-conflicting-outputs  # Generate Freezed/injectable code
flutter run                                         # Run app
flutter build apk / flutter build appbundle        # Build release
flutter analyze                                     # Lint code
flutter test                                        # Run all tests
flutter test test/widget_test.dart                 # Run single test file
flutter test --name="App should start"            # Run tests matching pattern
dart format .                                       # Format code
```

### Migration Scripts (migration/)
```bash
npm install                                        # Install dependencies
npm run migrate                                    # Run all migrations
npm run migrate:users / events / donations / news / forum / loker / market / memory
npm run seed / seed:down / seed:relations
```

## Project Structure

```
lib/
├── core/
│   ├── constants/         # App-wide constants (colors, text styles)
│   ├── di/               # GetIt dependency injection (injection.dart)
│   ├── errors/           # Failure classes for error handling
│   ├── network/          # PocketBase client setup (PBClient)
│   ├── router/           # GoRouter configuration (app_router.dart)
│   ├── services/         # Services (printer, etc.)
│   ├── theme/            # App theme configuration
│   ├── utils/            # Utility functions (app_logger.dart)
│   └── widgets/          # Reusable widgets (buttons, inputs, shimmers)
└── features/
    ├── admin/            # Admin features (events, users)
    └── [feature_name]/   # auth, donations, events, news, forum, etc.
        ├── data/         # datasources/, models/, repositories/
        ├── domain/       # entities/, failures/, repositories/, usecases/
        └── presentation/ # bloc/ (events, states, bloc), pages/
```

## Code Style Guidelines

### File Organization
- Start every file with `/// Description` and `library;` directive
- Group imports: dart → flutter → package → project (relative within feature, absolute for cross-feature)
- Use triple-slash (`///`) for documentation; avoid inline comments

```dart
/// Auth BLoC - Handle authentication state
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
```

### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `auth_repository.dart`, `user_model.dart`)
- **Classes**: `PascalCase` (e.g., `AuthRepository`, `UserModel`)
- **Functions/Methods/Variables**: `camelCase` (e.g., `getCurrentUser`, `_authRepository`)
- **Constants**: `lowerCamelCase` (e.g., `const defaultTimeout = 30`)
- **Private members**: Prefix with `_`

### Type Annotations & Null Safety
- Always specify return types; type all public APIs
- Use `Future<T>` for async operations; avoid `dynamic`
- Use `?` for nullable types; prefer null-aware operators (`?.`, `??`)

### BLoC Pattern
- Use sealed classes for Events/States; extend `Equatable`; use `const` constructors
- Emit loading → data/error states; use `on<Event>((event, emit) => ...)` handlers
- Log with `log.withContext(context, LogLevel.level, message)` for errors

```dart
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

// In Bloc:
on<AuthLoginRequested>((event, emit) async {
  emit(const AuthLoading());
  final result = await _authRepository.login(email: event.email, password: event.password);
  if (result.failure != null) {
    log.withContext('AuthBloc', LogLevel.error, 'Login failed', error: result.failure!.message);
    emit(AuthError(result.failure!));
  } else {
    emit(AuthAuthenticated(result.data!));
  }
});
```

### Failure & Error Handling
- Use sealed failure classes extending `Equatable` in `domain/failures/`
- Return result-like records: `({T? data, Failure? failure})`
- Map PocketBase exceptions to domain failures in repositories
- Use Indonesian error messages for UI; English for technical logs

```dart
sealed class AuthFailure extends Equatable {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Email atau password salah');
}

// Repository exception mapping:
AuthFailure _mapException(dynamic e) {
  if (e is ClientException && e.statusCode == 400) {
    return const InvalidCredentialsFailure();
  }
  return ServerFailure(e.toString());
}
```

### Freezed Models
- Add `// ignore_for_file: invalid_annotation_target` at top
- Use `@freezed`, `@JsonKey(name: 'field_name')`, `@Default()` for defaults
- Add `fromRecord(RecordModel)` factory for PocketBase integration
- Include `toEntity()` method to convert to domain entity

```dart
// ignore_for_file: invalid_annotation_target
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();
  const factory UserModel({
    required String id,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _UserModel;
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  factory UserModel.fromRecord(RecordModel record) {
    return UserModel(id: record.id, isVerified: record.getBoolValue('is_verified'));
  }
  
  UserEntity toEntity() => UserEntity(id: id, isVerified: isVerified);
}
```

### Dependency Injection (injection.dart)
- Register `PBClient` as singleton first; initialize auth with `await getIt<PBClient>().initAuth()`
- Data sources and repositories: `registerLazySingleton`
- Use cases: `registerLazySingleton`
- BLoCs: `registerFactory` (new instance each time)

```dart
getIt.registerLazySingleton<PBClient>(() => PBClient.instance);
await getIt<PBClient>().initAuth();
getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AuthRemoteDataSource>(), getIt<AuthLocalDataSource>()));
getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
```

### Widget & Routing
- Use `const` constructors; `ListView.builder` for lists; `SizedBox` for spacing
- GoRouter in `lib/core/router/app_router.dart`
- Pass data via `state.extra` for simple types, `state.pathParameters` for URL params

```dart
context.push('/event-detail', extra: eventId);
GoRoute(path: '/event-detail', builder: (context, state) => EventDetailPage(eventId: state.extra as String));
GoRoute(path: '/admin/users/:userId', builder: (context, state) => AdminUserDetailPage(userId: state.pathParameters['userId']!));
```

## Project-Specific Patterns

### PocketBase Integration
- Use `PBClient.instance` (from `lib/core/network/pb_client.dart`) for API calls
- Models must have `fromRecord(RecordModel)` factory using `record.getStringValue()`, `getIntValue()`, etc.
- Store auth tokens via `AuthLocalDataSource` with `flutter_secure_storage`
- Use `record.id` for PocketBase record IDs

### Logging (app_logger.dart)
- Import from `core/utils/app_logger.dart`: `import '../../../../core/utils/app_logger.dart' as log;`
- Use `log.debug()`, `log.info()`, `log.warning()`, `log.error()` with optional `context` parameter
- For structured logging: `log.withContext('FeatureName', LogLevel.error, 'message', error: e)`

### Payment Integration (Midtrans)
- Use `snap_token` field for payment initiation
- Handle payment callbacks via `pb_hooks/midtrans_notification.pb.js`

### Printer Service
- Use `PrinterService` for thermal ticket printing
- Configure printer settings via `SettingsBloc` and `SettingsLocalDataSource`

## Language & Localization
- UI text: **Indonesian (Bahasa Indonesia)**
- Error messages: user-friendly Indonesian
- Technical terms (HTTP, API, BLoC): English

## Performance & Security
- Use `const` widgets; `cached_network_image` for images
- Store tokens securely via `flutter_secure_storage`
- Never commit `.env` files; use HTTPS for all API calls

## Testing
- Widget tests for UI flows; unit tests for business logic
- Mock PocketBase (`PBClient`) and local storage dependencies
- Place tests in `test/` directory matching `lib/` structure

## Git Workflow
- Branches: `feature/`, `fix/`
- Commits: `feat:`, `fix:`, `refactor:`, `docs:`
- Run `flutter analyze` and `flutter test` before pushing
