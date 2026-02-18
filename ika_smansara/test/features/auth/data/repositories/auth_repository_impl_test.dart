import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ika_smansara/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ika_smansara/features/auth/data/models/user_model.dart';
import 'package:ika_smansara/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ika_smansara/features/auth/domain/entities/user_entity.dart';
import 'package:ika_smansara/features/auth/domain/failures/auth_failure.dart';
import 'package:ika_smansara/features/auth/domain/repositories/auth_repository.dart' show RegisterAlumniParams;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<AuthRemoteDataSource>(),
  MockSpec<AuthLocalDataSource>(),
])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
  });

  group('AuthRepositoryImpl', () {
    // Test data
    final tUserModel = UserModel(
      id: 'user1',
      email: 'test@example.com',
      name: 'Test User',
      phone: '08123456789',
      avatar: 'avatar.jpg',
      angkatan: 2020,
      role: 'alumni',
      jobStatus: 'swasta',
      company: 'Tech Corp',
      domisili: 'Jakarta',
      noUrutAngkatan: 100,
      noUrutGlobal: 500,
      verified: true,
      verifiedAt: DateTime(2025, 2, 18),
    );

    final tUserEntity = tUserModel.toEntity();

    group('isAuthenticated getter', () {
      test('should return authentication status from remote data source', () {
        // Arrange
        when(mockRemoteDataSource.isAuthenticated).thenReturn(true);

        // Act
        final result = repository.isAuthenticated;

        // Assert
        expect(result, isTrue);
        verify(mockRemoteDataSource.isAuthenticated);
      });

      test('should return false when not authenticated', () {
        // Arrange
        when(mockRemoteDataSource.isAuthenticated).thenReturn(false);

        // Act
        final result = repository.isAuthenticated;

        // Assert
        expect(result, isFalse);
      });
    });

    group('getCurrentUser', () {
      test('should return user from remote when available', () async {
        // Arrange
        when(mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => tUserModel);
        when(mockLocalDataSource.cacheUser(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.data, equals(tUserEntity));
        expect(result.failure, isNull);
        verify(mockRemoteDataSource.getCurrentUser());
        verify(mockLocalDataSource.cacheUser(tUserModel));
      });

      test('should fallback to local cache when remote fails', () async {
        // Arrange
        when(mockRemoteDataSource.getCurrentUser())
            .thenThrow(Exception('Network error'));
        when(mockLocalDataSource.getLastUser())
            .thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.data, equals(tUserEntity));
        expect(result.failure, isNull);
        verify(mockRemoteDataSource.getCurrentUser());
        verify(mockLocalDataSource.getLastUser());
      });

      test('should return UserNotFoundFailure when no user found', () async {
        // Arrange
        when(mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => null);
        when(mockLocalDataSource.getLastUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.data, isNull);
        expect(result.failure, isA<UserNotFoundFailure>());
      });

      test('should handle repository exception', () async {
        // Arrange
        when(mockRemoteDataSource.getCurrentUser())
            .thenThrow(Exception('Unauthorized'));
        when(mockLocalDataSource.getLastUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result.data, isNull);
        expect(result.failure, isA<AuthFailure>());
      });
    });

    group('login', () {
      const tEmail = 'test@example.com';
      const tPassword = 'password123';

      test('should login successfully and return user', () async {
        // Arrange
        when(mockRemoteDataSource.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => tUserModel);
        when(mockRemoteDataSource.isAuthenticated).thenReturn(true);
        when(mockRemoteDataSource.saveAuth()).thenAnswer((_) async {});
        when(mockLocalDataSource.cacheUser(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result.data, equals(tUserEntity));
        expect(result.failure, isNull);
        verify(mockRemoteDataSource.login(email: tEmail, password: tPassword));
        verify(mockRemoteDataSource.saveAuth());
        verify(mockLocalDataSource.cacheUser(tUserModel));
      });

      test('should return EmailNotVerifiedFailure when email not verified', () async {
        // Arrange
        final unverifiedUser = UserModel(
          id: 'user1',
          email: tEmail,
          name: 'Test',
          phone: '08123456789',
          role: 'alumni',
          verified: false,
        );
        when(mockRemoteDataSource.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => unverifiedUser);
        when(mockRemoteDataSource.logout()).thenAnswer((_) async {});

        // Act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result.data, isNull);
        expect(result.failure, isA<EmailNotVerifiedFailure>());
        verify(mockRemoteDataSource.logout());
      });

      test('should handle login failure', () async {
        // Arrange
        when(mockRemoteDataSource.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Invalid credentials'));

        // Act
        final result = await repository.login(
          email: tEmail,
          password: 'wrongpassword',
        );

        // Assert
        expect(result.data, isNull);
        expect(result.failure, isA<AuthFailure>());
      });
    });

    group('registerAlumni', () {
      final tParams = RegisterAlumniParams(
        email: 'alumni@example.com',
        password: 'password123',
        passwordConfirm: 'password123',
        name: 'Alumni User',
        phone: '08123456789',
        angkatan: 2020,
        jobStatus: JobStatus.swasta,
        company: 'Tech Corp',
        domisili: 'Jakarta',
      );

      test('should register alumni successfully', () async {
        // Arrange
        when(mockRemoteDataSource.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          passwordConfirm: anyNamed('passwordConfirm'),
          name: anyNamed('name'),
          phone: anyNamed('phone'),
          role: anyNamed('role'),
          angkatan: anyNamed('angkatan'),
          jobStatus: anyNamed('jobStatus'),
          company: anyNamed('company'),
          domisili: anyNamed('domisili'),
        )).thenAnswer((_) async => tUserModel);
        when(mockRemoteDataSource.requestVerification(any))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.registerAlumni(tParams);

        // Assert
        expect(result.data, equals(tUserEntity));
        expect(result.failure, isNull);
        verify(mockRemoteDataSource.register(
          email: tParams.email,
          password: tParams.password,
          passwordConfirm: tParams.passwordConfirm,
          name: tParams.name,
          phone: tParams.phone,
          role: 'alumni',
          angkatan: tParams.angkatan,
          jobStatus: 'swasta',
          company: tParams.company,
          domisili: tParams.domisili,
        ));
        verify(mockRemoteDataSource.requestVerification(tParams.email));
      });

      test('should handle registration failure', () async {
        // Arrange
        when(mockRemoteDataSource.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          passwordConfirm: anyNamed('passwordConfirm'),
          name: anyNamed('name'),
          phone: anyNamed('phone'),
          role: anyNamed('role'),
          angkatan: anyNamed('angkatan'),
          jobStatus: anyNamed('jobStatus'),
          company: anyNamed('company'),
          domisili: anyNamed('domisili'),
        )).thenThrow(Exception('Email already exists'));

        // Act
        final result = await repository.registerAlumni(tParams);

        // Assert
        expect(result.data, isNull);
        expect(result.failure, isA<AuthFailure>());
      });
    });

    group('logout', () {
      test('should logout successfully', () async {
        // Arrange
        when(mockRemoteDataSource.logout()).thenAnswer((_) async {});
        when(mockLocalDataSource.clearUser()).thenAnswer((_) async {});

        // Act
        final result = await repository.logout();

        // Assert
        expect(result.failure, isNull);
        verify(mockRemoteDataSource.logout());
        verify(mockLocalDataSource.clearUser());
      });

      test('should handle logout error', () async {
        // Arrange
        when(mockRemoteDataSource.logout())
            .thenThrow(Exception('Logout failed'));

        // Act
        final result = await repository.logout();

        // Assert
        expect(result.failure, isNotNull);
      });
    });

    group('requestPasswordReset', () {
      const tEmail = 'test@example.com';

      test('should request password reset successfully', () async {
        // Arrange
        when(mockRemoteDataSource.requestPasswordReset(tEmail))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.requestPasswordReset(tEmail);

        // Assert
        expect(result.failure, isNull);
        verify(mockRemoteDataSource.requestPasswordReset(tEmail));
      });

      test('should handle request failure', () async {
        // Arrange
        when(mockRemoteDataSource.requestPasswordReset(tEmail))
            .thenThrow(Exception('User not found'));

        // Act
        final result = await repository.requestPasswordReset(tEmail);

        // Assert
        expect(result.failure, isNotNull);
      });
    });
  });
}
