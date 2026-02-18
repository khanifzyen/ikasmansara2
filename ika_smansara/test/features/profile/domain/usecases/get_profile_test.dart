import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/auth/domain/entities/user_entity.dart';
import 'package:ika_smansara/features/profile/domain/repositories/profile_repository.dart';
import 'package:ika_smansara/features/profile/domain/usecases/get_profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ProfileRepository>()])
import 'get_profile_test.mocks.dart';

void main() {
  late GetProfile useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfile(mockRepository);
  });

  group('GetProfile UseCase', () {
    final tUser = UserEntity(
      id: '1',
      email: 'test@example.com',
      name: 'Test User',
      phone: '08123456789',
      avatar: 'avatar.jpg',
      angkatan: 2020,
      role: UserRole.alumni,
      jobStatus: JobStatus.swasta,
      company: 'Tech Corp',
      domisili: 'Jakarta',
      noUrutAngkatan: 100,
      noUrutGlobal: 500,
      isVerified: true,
      verified: true,
      verifiedAt: DateTime(2025, 2, 18),
    );

    test('should get user profile from repository', () async {
      // Arrange
      when(mockRepository.getProfile())
          .thenAnswer((_) async => tUser);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(tUser));
      expect(result.id, equals('1'));
      expect(result.name, equals('Test User'));
      expect(result.email, equals('test@example.com'));
      expect(result.isAlumni, isTrue);
      verify(mockRepository.getProfile());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Not authenticated');
      when(mockRepository.getProfile()).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(exception),
      );
      verify(mockRepository.getProfile());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository only once', () async {
      // Arrange
      when(mockRepository.getProfile())
          .thenAnswer((_) async => tUser);

      // Act
      await useCase();

      // Assert
      verify(mockRepository.getProfile()).called(1);
    });

    test('should handle unverified user', () async {
      // Arrange
      final unverifiedUser = UserEntity(
        id: '2',
        email: 'unverified@example.com',
        name: 'Unverified',
        phone: '08987654321',
        role: UserRole.public,
        isVerified: false,
        verified: false,
      );
      when(mockRepository.getProfile())
          .thenAnswer((_) async => unverifiedUser);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isVerified, isFalse);
      expect(result.verified, isFalse);
      expect(result.verifiedAt, isNull);
    });

    test('should handle user without ekta data', () async {
      // Arrange
      final noEktaUser = UserEntity(
        id: '3',
        email: 'noekta@example.com',
        name: 'No Ekta',
        phone: '0811111111',
        role: UserRole.public,
      );
      when(mockRepository.getProfile())
          .thenAnswer((_) async => noEktaUser);

      // Act
      final result = await useCase();

      // Assert
      expect(result.nomorEkta, equals('-'));
      expect(result.angkatan, isNull);
      expect(result.noUrutAngkatan, isNull);
      expect(result.noUrutGlobal, isNull);
    });

    test('should handle different user roles', () async {
      // Arrange
      final roles = [
        UserRole.alumni,
        UserRole.public,
        UserRole.admin,
      ];

      for (final role in roles) {
        final user = UserEntity(
          id: '1',
          email: 'test@test.com',
          name: 'Test',
          phone: '1',
          role: role,
        );
        when(mockRepository.getProfile())
            .thenAnswer((_) async => user);

        // Act
        final result = await useCase();

        // Assert
        expect(result.role, equals(role));
      }
      verify(mockRepository.getProfile()).called(roles.length);
    });

    test('should handle admin user', () async {
      // Arrange
      final adminUser = UserEntity(
        id: 'admin1',
        email: 'admin@example.com',
        name: 'Admin User',
        phone: '0811111111',
        role: UserRole.admin,
        isVerified: true,
      );
      when(mockRepository.getProfile())
          .thenAnswer((_) async => adminUser);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isAdmin, isTrue);
      expect(result.isAlumni, isFalse);
    });
  });
}
