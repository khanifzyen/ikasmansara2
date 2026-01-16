# 14. Testing Plan & Strategy

Dokumen ini mendefinisikan **strategi testing** untuk memastikan aplikasi robust dan free dari bug sebelum production.

---

## 1. Testing Pyramid

```
        /\
       /E2E\         ← Integration Tests (5%)
      /------\
     / Widget \       ← Widget Tests (20%)
    /----------\
   /  Unit Test  \    ← Unit Tests (75%)
  /----------------\
```

**Prinsip**: Mayoritas test adalah **Unit Test** (cepat, murah), sedikit **Widget Test**, minimal **E2E** (lambat, mahal).

---

## 2. Test Coverage Target

| Layer        | Coverage Target | Priority |
| :----------- | :-------------- | :------- |
| Domain       | 90%             | HIGH     |
| Data         | 70%             | MEDIUM   |
| Presentation | 50%             | LOW      |

**Rationale**: Domain layer adalah core bisnis logic. Data layer sudah ditest implisit oleh Domain. Presentation mudah berubah (UI/UX).

---

## 3. Unit Testing (Domain Layer)

### A. Testing Use Cases

**File**: `test/features/auth/domain/usecases/login_user_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser useCase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUser(mockRepo);
  });

  group('LoginUser UseCase', () {
    final testUser = UserEntity(id: '123', email: 'test@test.com', name: 'Test');

    test('should return UserEntity when login successful', () async {
      // Arrange
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => testUser);

      // Act
      final result = await useCase('test@test.com', 'password');

      // Assert
      expect(result, Right(testUser));
      verify(() => mockRepo.login('test@test.com', 'password')).called(1);
    });

    test('should return AppException when login fails', () async {
      // Arrange
      when(() => mockRepo.login(any(), any()))
          .thenThrow(NetworkException('Invalid credentials', 401));

      // Act
      final result = await useCase('wrong@email.com', 'wrong');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.type, AppErrorType.authentication),
        (_) => fail('Should return error'),
      );
    });
  });
}
```

---

## 4. Widget Testing (Presentation Layer)

### A. Testing Screens

**File**: `test/features/auth/presentation/login_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('LoginScreen displays email and password fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // Verify widgets exist
    expect(find.text('Email / No HP'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('Shows error when email is empty', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // Tap login button without filling form
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    // Should show validation error
    expect(find.text('Email tidak boleh kosong'), findsOneWidget);
  });
}
```

### B. Testing Custom Widgets

**File**: `test/common_widgets/buttons/primary_button_test.dart`

```dart
testWidgets('PrimaryButton shows loading indicator', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PrimaryButton(
          text: 'Submit',
          isLoading: true,
          onPressed: () {},
        ),
      ),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.text('Submit'), findsNothing);
});
```

---

## 5. Integration Testing (E2E)

### A. Full Flow Test

**File**: `integration_test/login_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete login flow', (tester) async {
    // Launch app
    await tester.pumpWidget(const ProviderScope(child: IkasmansaraApp()));
    await tester.pumpAndSettle();

    // Navigate to login (assuming splash redirects)
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byKey(Key('emailField')), 'admin@gmail.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password');

    // Submit
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Verify navigation to home
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

**Run Command**:

```bash
flutter test integration_test
```

---

## 6. Mock Strategy

### A. Mock Repositories (for UseCase tests)

```dart
class MockAuthRepository extends Mock implements AuthRepository {}
class MockProductRepository extends Mock implements ProductRepository {}
```

### B. Mock DataSources (for Repository tests)

```dart
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
```

### C. Mock PocketBaseService (for DataSource tests)

```dart
class MockPocketBaseService extends Mock implements PocketBaseService {}
```

---

## 7. Test Data Fixtures

### File: `test/fixtures/user_fixture.dart`

```dart
class UserFixture {
  static UserEntity testUser = UserEntity(
    id: 'test-123',
    email: 'test@example.com',
    name: 'Test User',
    angkatan: '2015',
    role: 'alumni',
  );

  static RecordAuth testAuthResponse = RecordAuth(
    record: /* ... */,
    token: 'fake-jwt-token',
  );
}
```

**Usage**:

```dart
when(() => mockRepo.login(any(), any()))
    .thenAnswer((_) async => UserFixture.testUser);
```

---

## 8. Testing Riverpod Providers

### A. Using `ProviderContainer`

```dart
test('loginControllerProvider handles success', () async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );

  when(() => mockRepo.login(any(), any()))
      .thenAnswer((_) async => UserFixture.testUser);

  final controller = container.read(loginControllerProvider.notifier);
  await controller.login('test@test.com', 'password');

  final state = container.read(loginControllerProvider);
  expect(state.hasValue, true);
});
```

---

## 9. Test Folder Structure

```
test/
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       └── login_user_test.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl_test.dart
│   │   └── presentation/
│   │       └── login_screen_test.dart
│   ├── marketplace/...
│   └── directory/...
├── common_widgets/
│   └── buttons/
│       └── primary_button_test.dart
├── core/
│   └── network/
│       └── pocketbase_service_test.dart
├── fixtures/
│   └── user_fixture.dart
└── helpers/
    └── pump_app.dart
```

---

## 10. Coverage Report

**Generate Coverage**:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**View**:
Open `coverage/html/index.html` di browser.

---

## 11. Continuous Integration (GitHub Actions)

**File**: `.github/workflows/test.yml`

```yaml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.27.0"
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter test integration_test
```

---

## 12. Testing Checklist (Per Feature)

Sebelum merge PR, pastikan:

- [ ] UseCase memiliki Unit Test (success & error cases).
- [ ] Repository Implementation ditest dengan Mock DataSource.
- [ ] Screen utama punya Widget Test (minimal render test).
- [ ] Critical flow (Login, Register) punya Integration Test.
- [ ] Coverage ≥ 70% untuk Domain layer.

---

> [!NOTE] > **Testing adalah Investasi, bukan Cost.**  
> 1 jam nulis test = menghemat 10 jam debugging production bug.
