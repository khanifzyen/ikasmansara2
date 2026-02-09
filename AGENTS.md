# Agent Guidelines for IKA SMANSARA

Aplikasi mobile Flutter untuk Ikatan Alumni SMAN 1 Jepara (IKA SMANSARA) dengan Clean Architecture, BLoC state management, dan PocketBase backend.

## Build, Lint, and Test Commands

### Flutter App (ika_smansara/)
```bash
flutter pub get                                    # Install dependencies
flutter pub run build_runner build --delete-conflicting-outputs  # Generate code
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

### PocketBase Hooks (pb_hooks/)
```bash
# Deploy hooks to PocketBase instance
pb_deploy deploy pb_hooks/ --target <pb-instance>
```

## Project Structure

```
lib/
├── core/
│   ├── constants/         # App-wide constants (colors, text styles)
│   ├── di/               # GetIt dependency injection (injection.dart)
│   ├── errors/           # Failure classes for error handling
│   ├── network/          # PocketBase client setup (PBClient)
│   ├── router/           # GoRouter configuration
│   ├── services/         # Services (printer, etc.)
│   ├── theme/            # App theme configuration
│   ├── utils/            # Utility functions
│   └── widgets/          # Reusable widgets (buttons, inputs, shimmers)
└── features/
    ├── admin/            # Admin features (events, users)
    │   ├── core/
    │   ├── events/
    │   └── users/
    └── [feature_name]/   # auth, donations, events, news, forum, etc.
        ├── data/         # datasources/, models/, repositories/
        ├── domain/       # entities/, failures/, repositories/, usecases/
        └── presentation/ # bloc/ (events, states, bloc), pages/
```

## Code Style Guidelines

### File Organization
- Start every file with `/// Description` and `library;` directive
- Group imports: dart → flutter → package → project (relative within feature, absolute for cross-feature)
- Use triple-slash (`///`) for documentation

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
- Use sealed classes with `@sealed` for Events/States
- Extend `Equatable`; use `const` constructors
- Emit loading → data/error states

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
```

### Error Handling
- Return result-like records: `({T? data, Failure? failure})`
- Log errors with `debugPrint()`; use Indonesian error messages

### Freezed Models
- Use `@freezed`, `@JsonKey(name: 'field_name')`, `@Default()` for defaults
- Add `fromRecord(RecordModel)` factory for PocketBase models

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
  factory UserModel.fromRecord(RecordModel record) { /* ... */ }
  UserEntity toEntity() { /* ... */ }
}
```

### Dependency Injection
- Singletons for repositories/data sources; factories for BLoCs

```dart
getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));
getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
```

### Widget & Routing
- Use `const` constructors; `ListView.builder` for lists; `SizedBox` for spacing
- GoRouter with `state.extra` for data passing

```dart
context.push('/event-detail', extra: eventId);
GoRoute(path: '/event-detail', builder: (context, state) => EventDetailPage(eventId: state.extra as String));
```

## Project-Specific Patterns

### PocketBase Integration
- Use `PBClient.instance` for API calls
- Models should have `fromRecord(RecordModel)` factory
- Store auth tokens via `AuthLocalDataSource` with `flutter_secure_storage`

### Payment Integration (Midtrans)
- Use `snap_token` for payment initiation
- Handle payment callbacks via `pb_hooks/midtrans_notification.pb.js`

### Printer Service
- Use `PrinterService` for thermal ticket printing
- Configure printer settings via `SettingsBloc`

### Admin Features
- Admin routes located in `features/admin/`
- Manual event booking with coordinator info
- Ticket check-in and shirt pickup tracking

## Language & Localization
- UI text: **Indonesian (Bahasa Indonesia)**
- Error messages: user-friendly Indonesian
- Technical terms (HTTP, API, BLoC): English

## Performance & Security
- Use `const` widgets; `cached_network_image` for images
- Store tokens securely via `flutter_secure_storage`
- Never commit `.env` files; use HTTPS

## Testing
- Widget tests for UI flows; unit tests for business logic
- Mock PocketBase and local storage dependencies

## Git Workflow
- Branches: `feature/`, `fix/`
- Commits: `feat:`, `fix:`, `refactor:`, `docs:`
- Run `flutter analyze` and `flutter test` before pushing

## IDE Setup
- Enable Dart assistant; install Flutter/Dart plugins
- Use BLoC extension for state debugging
