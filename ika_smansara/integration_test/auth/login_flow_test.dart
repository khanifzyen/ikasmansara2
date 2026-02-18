/// Integration Test: Login Flow (Fixed)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ika_smansara/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ika_smansara/features/auth/presentation/bloc/auth_state.dart';
import 'package:ika_smansara/features/auth/presentation/pages/login_page.dart';

// Mock AuthBloc
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group('Login Flow Integration Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthInitial()));
    });

    Widget createLoginScreen() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginPage(),
        ),
      );
    }

    testWidgets('Login page UI - displays key components', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Verify key UI elements exist
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(2)); // Email + Password
      expect(find.text('Masuk'), findsAtLeastNWidgets(1)); // At least title
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1)); // Login button
      expect(find.byType(IconButton), findsAtLeastNWidgets(1)); // Back button
    });

    testWidgets('Login flow - validation - empty email', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      
      // Leave email empty, fill password
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Email wajib diisi'), findsAtLeastNWidgets(1));
    });

    testWidgets('Login flow - validation - empty password', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      
      // Fill email, leave password empty
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.pumpAndSettle();

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Password wajib diisi'), findsAtLeastNWidgets(1));
    });

    testWidgets('Login flow - validation - invalid email format', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Enter invalid email (no @)
      await tester.enterText(textFields.first, 'invalid-email');
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Masuk');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Email tidak valid'), findsAtLeastNWidgets(1));
    });

    testWidgets('Login flow - valid email and password input', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Enter valid email
      await tester.enterText(textFields.first, 'muhammadshudiardiwinata@gmail.com');
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(textFields.at(1), '123S@nding');
      await tester.pumpAndSettle();

      // Verify text fields have content via controller
      final emailField = tester.widget<TextField>(textFields.first);
      final passwordField = tester.widget<TextField>(textFields.at(1));
      
      expect(emailField.controller?.text, 'muhammadshudiardiwinata@gmail.com');
      expect(passwordField.controller?.text, '123S@nding');
    });

    testWidgets('Login flow - form field interaction', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2));

      // Tap first field (email)
      await tester.tap(textFields.first);
      await tester.pumpAndSettle();

      // Type and verify
      await tester.enterText(textFields.first, 'test@test.com');
      await tester.pumpAndSettle();

      expect(find.text('test@test.com'), findsAtLeastNWidgets(1));

      // Tap second field (password)
      await tester.tap(textFields.at(1));
      await tester.pumpAndSettle();

      await tester.enterText(textFields.at(1), 'password');
      await tester.pumpAndSettle();

      // Verify via controller (password is obscured)
      final passwordField = tester.widget<TextField>(textFields.at(1));
      expect(passwordField.controller?.text, 'password');
    });

    testWidgets('Login flow - back button exists', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Verify back button
      expect(find.byType(IconButton), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.arrow_back), findsAtLeastNWidgets(1));
    });

    testWidgets('Login flow - logo displayed', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Verify logo is present
      expect(find.byType(Image), findsAtLeastNWidgets(1));
    });

    testWidgets('Login flow - responsive layout', (tester) async {
      // Test with different screen sizes
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: MaterialApp(
            home: BlocProvider<AuthBloc>.value(
              value: mockAuthBloc,
              child: const LoginPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI renders correctly
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    });
  });
}
