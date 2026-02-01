# Agent Guidelines for IKA SMANSARA

This repository contains a Flutter mobile app (ika_smansara), HTML prototypes (lofi, lofi-admin), PocketBase hooks (pb_hooks), and migration scripts. This guide focuses on the Flutter app.

## Build, Lint, and Test Commands

### Flutter App (ika_smansara/)
```bash
# Install dependencies
flutter pub get

# Generate code (freezed, json_serializable, injectable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Build for release
flutter build apk                    # Android APK
flutter build appbundle              # Android App Bundle
flutter build ios                    # iOS
flutter build web                    # Web

# Analyze code (linting)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run tests matching a pattern
flutter test --name="App should start"

# Format code
dart format .

# Check code coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html  # requires lcov installed
```

### Migration Scripts (migration/)
```bash
# Install dependencies
npm install

# Run all migrations
npm run migrate

# Run specific collection migrations
npm run migrate:users
npm run migrate:events
npm run migrate:donations
npm run migrate:news
npm run migrate:forum
npm run migrate:loker
npm run migrate:market
npm run migrate:memory

# Run seeders
npm run seed
npm run seed:down
npm run seed:relations
```

## Project Structure

The Flutter app follows **Clean Architecture** with feature-based organization:

```
lib/
├── core/
│   ├── constants/         # App-wide constants (colors, text styles, etc.)
│   ├── di/               # Dependency injection (injection.dart)
│   ├── errors/           # Failure classes for error handling
│   ├── network/          # PocketBase client setup
│   ├── router/           # GoRouter configuration
│   ├── theme/            # App theme configuration
│   ├── utils/            # Utility functions
│   └── widgets/          # Reusable widgets (buttons, inputs, shimmers)
└── features/
    └── [feature_name]/
        ├── data/
        │   ├── datasources/    # Remote and local data sources
        │   ├── models/         # DTOs with freezed annotations
        │   └── repositories/   # Repository implementations
        ├── domain/
        │   ├── entities/       # Domain entities
        │   ├── failures/       # Feature-specific failures
        │   ├── repositories/   # Repository interfaces
        │   └── usecases/       # Business logic use cases
        └── presentation/
            ├── bloc/           # BLoC (events, states, bloc)
            └── pages/          # UI pages/screens
```

## Code Style Guidelines

### File Organization

- Start every file with `library;` directive
- Use triple-slash (`///`) for file-level documentation comments
- Group imports: dart → flutter → package → project
- Use relative imports for files within the same feature
- Use absolute imports from `lib/` for cross-feature imports

```dart
/// Feature BLoC - Handle feature state
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/feature_model.dart';
import '../domain/entities/feature_entity.dart';
import '../domain/repositories/feature_repository.dart';
import 'feature_event.dart';
import 'feature_state.dart';
```

### Naming Conventions

- **Files**: `snake_case.dart` (e.g., `auth_repository.dart`, `user_model.dart`)
- **Classes**: `PascalCase` (e.g., `AuthRepository`, `UserModel`)
- **Functions/Methods**: `camelCase` (e.g., `getCurrentUser`, `onLoginRequested`)
- **Variables**: `camelCase` (e.g., `userName`, `isLoading`)
- **Constants**: `lowerCamelCase` for class-level (e.g., `const defaultTimeout = 30`)
- **Private members**: Prefix with `_` (e.g., `_authRepository`, `_handleSubmit`)
- **Enums**: `PascalCase` for enum, `camelCase` for values
- **Files with multiple exports**: `widgets.dart`, `bloc.dart` for barrel files

### Type Annotations

- Always specify return types for functions and methods
- Type all public APIs; let inference handle local variables when obvious
- Use `Future<T>` for async operations
- Use `void` when return value is ignored
- Avoid `dynamic` - use `Object?` or specific types

```dart
// Good
Future<Result<User>> getUser(String id) async {
  final user = await _fetchUser(id);
  return user;
}

// Bad
getUser(id) async {  // Missing return type
  final user = await _fetchUser(id);  // Parameter type missing
  return user;
}
```

### Null Safety

- Use `?` for nullable types (e.g., `String? name`)
- Use `!` only when you're certain the value is non-null
- Prefer null-aware operators (`?.`, `??`, `??=`)
- Use `late` only for values assigned after constructor but before use

```dart
// Good
String? name;
print(name?.toUpperCase() ?? 'No name');

// Bad
String name;
print(name!.toUpperCase());  // Runtime error if null
```

### Constants and Immutability

- Use `const` for compile-time constants
- Use `final` for runtime constants
- Use `@freezed` for immutable data classes
- Prefer `const` constructors for widgets

```dart
// Good
const primaryColor = Colors.blue;
final user = UserModel(name: 'John');
const PrimaryButton(text: 'Submit');

// Bad
var color = Colors.red;  // Should be const or final
```

### BLoC Pattern

- Use sealed classes with `@sealed` or regular abstract classes for Events/States
- Extend `Equatable` for all Event and State classes
- Use `const` constructors for Event/State classes
- Emit loading states before async operations
- Handle errors gracefully, emit error states

```dart
// Events
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

// States
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final AuthFailure failure;
  const AuthError(this.failure);
  @override
  List<Object?> get props => [failure];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );
    if (result.failure != null) {
      emit(AuthError(result.failure!));
    } else if (result.data != null) {
      emit(AuthAuthenticated(result.data!));
    }
  }
}
```

### Error Handling

- Use custom Failure classes from `core/errors/failures.dart`
- Return result-like records: `({T? data, Failure? failure})`
- Log errors with `debugPrint()` (not `print()`)
- Provide user-friendly error messages in Indonesian
- Map exceptions to appropriate Failure types

```dart
// Good
Future<AuthResult<User>> login({required String email, required String password}) async {
  try {
    final user = await _remoteDataSource.login(email: email, password: password);
    return (data: user.toEntity(), failure: null);
  } on ClientException catch (e) {
    debugPrint('Network error: $e');
    return (data: null, failure: const NetworkFailure());
  } catch (e) {
    return (data: null, failure: _mapException(e));
  }
}
```

### Freezed Models

- Use `@freezed` annotation for immutable data classes
- Use `@JsonKey` for field name mapping
- Use `@Default()` for default values
- Include `part` directives for generated files

```dart
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    required String name,
    @JsonKey(name: 'job_status') String? jobStatus,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    name: name,
    // ... mapping
  );
}
```

### Dependency Injection

- Use GetIt with Injectable
- Register singletons for repositories and data sources
- Register factories for BLoCs (new instance each time)
- Use lazy registration where appropriate

```dart
// Core
getIt.registerLazySingleton<PBClient>(() => PBClient.instance);

// Data Sources
getIt.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSource(getIt<PBClient>()),
);

// Repositories
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    getIt<AuthRemoteDataSource>(),
    getIt<AuthLocalDataSource>(),
  ),
);

// Use Cases
getIt.registerLazySingleton(() => GetDonations(getIt<DonationRepository>()));

// BLoCs (factory = new instance each time)
getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
```

### Widget Guidelines

- Use `const` constructors wherever possible
- Extract reusable widgets to separate files
- Use `SizedBox` for spacing (not `Padding` widget alone)
- Prefer `ListView.builder` over `Column` for long lists
- Use `Expanded`/`Flexible` within `Row`/`Column` for responsive layouts
- Handle loading states with shimmer widgets
- Provide meaningful keys for widgets

```dart
// Good
class UserList extends StatelessWidget {
  final List<User> users;
  const UserList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => UserTile(user: users[index]),
    );
  }
}

// Bad
class UserList extends StatelessWidget {
  final List<User> users;
  UserList({required this.users});  // Missing const constructor

  @override
  Widget build(BuildContext context) {
    return Column(
      children: users.map((user) => UserTile(user: user)).toList(),  // Not efficient for long lists
    );
  }
}
```

### Routing

- Use GoRouter for navigation
- Define routes in `core/router/app_router.dart`
- Use `state.extra` to pass data between routes
- Implement route guards for authentication
- Handle 404 with errorBuilder

```dart
// Navigation
context.push('/event-detail', extra: eventId);

// Route definition
GoRoute(
  path: '/event-detail',
  name: 'event-detail',
  builder: (context, state) {
    final eventId = state.extra as String;
    return EventDetailPage(eventId: eventId);
  },
);
```

### Environment Configuration

- Use `.env` file for environment variables
- Use `flutter_dotenv` to load environment variables
- Never commit `.env` files (use `.env.example` as template)
- Access via `dotenv.env['KEY']`

### Comments and Documentation

- Use `///` for public API documentation
- Keep comments concise and meaningful
- Avoid obvious comments (e.g., `// Increment counter`)
- Document complex business logic
- Add comments for workarounds or non-obvious implementations

```dart
/// Authenticates a user with email and password.
///
/// Returns [AuthResult] with user data on success or [AuthFailure] on error.
/// Emits [AuthLoading] before starting and [AuthAuthenticated] or [AuthError] on completion.
Future<AuthResult<User>> login({required String email, required String password}) async {
  // ...
}
```

## Language and Localization

- UI text should be in **Indonesian** (Bahasa Indonesia)
- Error messages should be user-friendly Indonesian
- Code comments in English or Indonesian (match existing code style)
- Technical terms (HTTP, API, BLoC) can remain in English

## Common Patterns

### Repository Pattern
```dart
// Domain layer - interface
abstract class AuthRepository {
  Future<AuthResult<User>> login({required String email, required String password});
}

// Data layer - implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<AuthResult<User>> login({required String email, required String password}) async {
    try {
      final user = await _remoteDataSource.login(email: email, password: password);
      return (data: user.toEntity(), failure: null);
    } catch (e) {
      return (data: null, failure: _mapException(e));
    }
  }
}
```

### Use Case Pattern
```dart
class GetDonations {
  final DonationRepository repository;
  GetDonations(this.repository);

  Future<List<Donation>> call() {
    return repository.getDonations();
  }
}
```

## Performance Best Practices

- Use `const` widgets and constructors
- Avoid rebuilding entire widget trees - use `const` or extract parts
- Use `ListView.builder` instead of `Column` for long lists
- Implement pagination for large datasets
- Use `cached_network_image` for remote images
- Optimize images before adding to assets
- Avoid unnecessary `setState()` calls
- Use `RepaintBoundary` for complex animated widgets

## Security Guidelines

- Never hardcode API keys or secrets
- Store tokens securely using `flutter_secure_storage`
- Validate user input on both client and server
- Use HTTPS for all network requests
- Implement proper authentication checks
- Don't log sensitive information (passwords, tokens)

## Testing Guidelines

- Write widget tests for critical UI flows
- Write unit tests for business logic (use cases, repositories)
- Mock external dependencies (PocketBase, local storage)
- Follow the Arrange-Act-Assert pattern
- Run `flutter test` before committing changes

```dart
testWidgets('Login button shows loading state', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(MyApp());
  final loginButton = find.text('Login');

  // Act
  await tester.tap(loginButton);
  await tester.pump();

  // Assert
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Code Generation

- Run `flutter pub run build_runner build --delete-conflicting-outputs` after:
  - Adding/modifying Freezed models
  - Adding/modifying JsonSerializable classes
  - Adding/modifying Injectable annotations
- Use `--delete-conflicting-outputs` to avoid conflicts during development

## Git Workflow

- Feature branches: `feature/feature-name`
- Bug fixes: `fix/bug-description`
- Use conventional commit messages:
  - `feat: add donation history page`
  - `fix: handle login timeout error`
  - `refactor: extract common button widget`
  - `docs: update AGENTS.md guidelines`
- Run `flutter analyze` and `flutter test` before pushing

## IDE Recommendations

- Enable Dart assistant for auto-imports
- Use Flutter Outline for widget tree navigation
- Install Flutter and Dart plugins
- Enable type hierarchy view
- Use BLoC extension for state management debugging
