import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/auth/domain/entities/user_entity.dart';
import 'package:ika_smansara/features/profile/domain/repositories/profile_repository.dart';
import 'package:ika_smansara/features/profile/domain/usecases/update_profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ProfileRepository>()])
import 'update_profile_test.mocks.dart';

void main() {
  late UpdateProfile useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = UpdateProfile(mockRepository);
  });

  group('UpdateProfile UseCase', () {
    final tUpdatedUser = UserEntity(
      id: '1',
      email: 'test@example.com',
      name: 'Updated Name',
      phone: '08123456789',
      role: UserRole.alumni,
      jobStatus: JobStatus.pnsBumn,
      company: 'New Company',
      domisili: 'Bandung',
      angkatan: 2020,
    );

    test('should update profile with all parameters', () async {
      // Arrange
      final params = ProfileUpdateParams(
        name: 'Updated Name',
        phone: '08123456789',
        jobStatus: JobStatus.pnsBumn,
        company: 'New Company',
        domisili: 'Bandung',
      );
      when(mockRepository.updateProfile(params))
          .thenAnswer((_) async => tUpdatedUser);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, equals(tUpdatedUser));
      expect(result.name, equals('Updated Name'));
      expect(result.jobStatus, equals(JobStatus.pnsBumn));
      verify(mockRepository.updateProfile(params));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should update profile with partial parameters', () async {
      // Arrange
      final partialParams = ProfileUpdateParams(
        name: 'New Name Only',
      );
      final partialUser = UserEntity(
        id: '1',
        email: 'test@example.com',
        name: 'New Name Only',
        phone: '08123456789',
        role: UserRole.alumni,
      );
      when(mockRepository.updateProfile(partialParams))
          .thenAnswer((_) async => partialUser);

      // Act
      final result = await useCase(partialParams);

      // Assert
      expect(result.name, equals('New Name Only'));
      verify(mockRepository.updateProfile(partialParams));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Update failed');
      final params = ProfileUpdateParams(
        name: 'Test',
      );
      when(mockRepository.updateProfile(params))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(params),
        throwsA(exception),
      );
      verify(mockRepository.updateProfile(params));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle update with different job statuses', () async {
      // Arrange
      final jobStatuses = [
        JobStatus.swasta,
        JobStatus.pnsBumn,
        JobStatus.wirausaha,
        JobStatus.mahasiswa,
        JobStatus.lainnya,
      ];

      for (final jobStatus in jobStatuses) {
        final params = ProfileUpdateParams(
          jobStatus: jobStatus,
        );
        final user = UserEntity(
          id: '1',
          email: 'test@test.com',
          name: 'Test',
          phone: '1',
          role: UserRole.alumni,
          jobStatus: jobStatus,
        );
        when(mockRepository.updateProfile(params))
            .thenAnswer((_) async => user);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.jobStatus, equals(jobStatus));
      }
    });

    test('should handle empty params', () async {
      // Arrange
      final emptyParams = ProfileUpdateParams();
      final user = UserEntity(
        id: '1',
        email: 'test@test.com',
        name: 'Test',
        phone: '1',
        role: UserRole.alumni,
      );
      when(mockRepository.updateProfile(emptyParams))
          .thenAnswer((_) async => user);

      // Act
      final result = await useCase(emptyParams);

      // Assert
      expect(result, equals(user));
    });

    test('should handle update with avatar file', () async {
      // Arrange
      final params = ProfileUpdateParams(
        avatarFile: null, // In real test would use File
      );
      final user = UserEntity(
        id: '1',
        email: 'test@test.com',
        name: 'Test',
        phone: '1',
        role: UserRole.alumni,
        avatar: 'new_avatar.jpg',
      );
      when(mockRepository.updateProfile(params))
          .thenAnswer((_) async => user);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.avatar, equals('new_avatar.jpg'));
    });

    test('should call repository only once per update', () async {
      // Arrange
      final params = ProfileUpdateParams(
        name: 'Test',
      );
      when(mockRepository.updateProfile(params))
          .thenAnswer((_) async => tUpdatedUser);

      // Act
      await useCase(params);

      // Assert
      verify(mockRepository.updateProfile(params)).called(1);
    });

    test('should handle company and domisili updates', () async {
      // Arrange
      final params = ProfileUpdateParams(
        company: 'Tech StartUp',
        domisili: 'Surabaya',
      );
      final user = UserEntity(
        id: '1',
        email: 'test@test.com',
        name: 'Test',
        phone: '1',
        role: UserRole.alumni,
        company: 'Tech StartUp',
        domisili: 'Surabaya',
      );
      when(mockRepository.updateProfile(params))
          .thenAnswer((_) async => user);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.company, equals('Tech StartUp'));
      expect(result.domisili, equals('Surabaya'));
    });
  });
}
