import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/auth/data/models/user_model.dart';
import 'package:ika_smansara/features/auth/domain/entities/user_entity.dart';
import 'package:ika_smansara/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ika_smansara/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ika_smansara/features/profile/domain/repositories/profile_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ProfileRemoteDataSource>()])
import 'profile_repository_impl_test.mocks.dart';

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(mockRemoteDataSource);
  });

  group('ProfileRepositoryImpl', () {
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

    group('getProfile', () {
      test('should return user profile from data source', () async {
        // Arrange
        when(mockRemoteDataSource.getProfile())
            .thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.getProfile();

        // Assert
        expect(result, equals(tUserEntity));
        expect(result.id, equals('user1'));
        expect(result.name, equals('Test User'));
        expect(result.email, equals('test@example.com'));
        expect(result.isAlumni, isTrue);
        verify(mockRemoteDataSource.getProfile());
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('Failed to load profile');
        when(mockRemoteDataSource.getProfile()).thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.getProfile(),
          throwsA(exception),
        );
        verify(mockRemoteDataSource.getProfile());
      });

      test('should call data source only once', () async {
        // Arrange
        when(mockRemoteDataSource.getProfile())
            .thenAnswer((_) async => tUserModel);

        // Act
        await repository.getProfile();

        // Assert
        verify(mockRemoteDataSource.getProfile()).called(1);
      });

      test('should convert model to entity correctly', () async {
        // Arrange
        when(mockRemoteDataSource.getProfile())
            .thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.getProfile();

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.id, equals(tUserModel.id));
        expect(result.email, equals(tUserModel.email));
        expect(result.name, equals(tUserModel.name));
        expect(result.angkatan, equals(tUserModel.angkatan));
      });

      test('should handle different user roles', () async {
        // Arrange
        final roles = ['alumni', 'public', 'admin'];

        for (final role in roles) {
          final userModel = UserModel(
            id: 'user1',
            email: 'test@test.com',
            name: 'Test',
            phone: '1',
            role: role,
            verified: true,
          );
          when(mockRemoteDataSource.getProfile())
              .thenAnswer((_) async => userModel);

          // Act
          final result = await repository.getProfile();

          // Assert
          expect(result.role.name, equals(role));
        }
      });
    });

    group('updateProfile', () {
      final tParams = ProfileUpdateParams(
        name: 'Updated Name',
        phone: '08987654321',
        jobStatus: JobStatus.pnsBumn,
        company: 'New Company',
        domisili: 'Bandung',
      );

      test('should update profile and return user entity', () async {
        // Arrange
        final updatedModel = UserModel(
          id: 'user1',
          email: 'test@example.com',
          name: 'Updated Name',
          phone: '08987654321',
          angkatan: 2020,
          role: 'alumni',
          jobStatus: 'pns_bumn',
          company: 'New Company',
          domisili: 'Bandung',
          verified: true,
        );
        when(mockRemoteDataSource.updateProfile(tParams))
            .thenAnswer((_) async => updatedModel);

        // Act
        final result = await repository.updateProfile(tParams);

        // Assert
        expect(result.name, equals('Updated Name'));
        expect(result.phone, equals('08987654321'));
        expect(result.jobStatus, equals(JobStatus.pnsBumn));
        expect(result.company, equals('New Company'));
        expect(result.domisili, equals('Bandung'));
        verify(mockRemoteDataSource.updateProfile(tParams));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('Update failed');
        when(mockRemoteDataSource.updateProfile(tParams))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.updateProfile(tParams),
          throwsA(exception),
        );
        verify(mockRemoteDataSource.updateProfile(tParams));
      });

      test('should handle partial update', () async {
        // Arrange
        final partialParams = ProfileUpdateParams(
          name: 'New Name Only',
        );
        when(mockRemoteDataSource.updateProfile(partialParams))
            .thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.updateProfile(partialParams);

        // Assert
        expect(result, isA<UserEntity>());
        verify(mockRemoteDataSource.updateProfile(partialParams));
      });

      test('should convert model to entity after update', () async {
        // Arrange
        when(mockRemoteDataSource.updateProfile(tParams))
            .thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.updateProfile(tParams);

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.id, equals(tUserModel.id));
        expect(result.email, equals(tUserModel.email));
      });

      test('should handle different job statuses', () async {
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
          when(mockRemoteDataSource.updateProfile(params))
              .thenAnswer((_) async => tUserModel);

          // Act
          await repository.updateProfile(params);

          // Assert
          verify(mockRemoteDataSource.updateProfile(params));
        }
      });
    });
  });
}
