/// Unit tests for AdminUsersRepositoryImpl
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ika_smansara/features/admin/users/data/repositories/admin_users_repository_impl.dart';
import 'package:ika_smansara/features/admin/users/data/datasources/admin_users_remote_data_source.dart';
import 'package:ika_smansara/features/auth/domain/entities/user_entity.dart';

@GenerateNiceMocks([
  MockSpec<AdminUsersRemoteDataSource>(),
])
import 'admin_users_repository_impl_test.mocks.dart';

void main() {
  late AdminUsersRepositoryImpl repository;
  late MockAdminUsersRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAdminUsersRemoteDataSource();
    repository = AdminUsersRepositoryImpl(mockDataSource);
  });

  group('AdminUsersRepositoryImpl - getUsers', () {
    final tUsers = [
      UserEntity(
        id: '1',
        email: 'user1@example.com',
        name: 'Test User 1',
        phone: '08123456789',
        role: UserRole.alumni,
        angkatan: 2010,
        isVerified: true,
        verified: true,
      ),
      UserEntity(
        id: '2',
        email: 'user2@example.com',
        name: 'Test User 2',
        phone: '08123456780',
        role: UserRole.alumni,
        angkatan: 2011,
        isVerified: false,
        verified: false,
      ),
    ];

    test('should get users from data source', () async {
      // Arrange
      when(mockDataSource.getUsers(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tUsers);

      // Act
      final result = await repository.getUsers(
        filter: 'role="alumni"',
        page: 1,
        perPage: 20,
      );

      // Assert
      expect(result, tUsers);
      verify(mockDataSource.getUsers(
        filter: 'role="alumni"',
        page: 1,
        perPage: 20,
      )).called(1);
    });

    test('should get users with default parameters', () async {
      // Arrange
      when(mockDataSource.getUsers(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tUsers);

      // Act
      await repository.getUsers();

      // Assert
      verify(mockDataSource.getUsers(
        filter: null,
        page: 1,
        perPage: 20,
      )).called(1);
    });

    test('should propagate getUsers exception', () async {
      // Arrange
      when(mockDataSource.getUsers(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenThrow(Exception('Failed to get users'));

      // Act & Assert
      expect(
        () => repository.getUsers(),
        throwsException,
      );
    });
  });

  group('AdminUsersRepositoryImpl - getPendingUsers', () {
    final tPendingUsers = [
      UserEntity(
        id: '1',
        email: 'pending@example.com',
        name: 'Pending User',
        phone: '08123456789',
        role: UserRole.alumni,
        angkatan: 2010,
        isVerified: false,
        verified: false,
      ),
    ];

    test('should get pending users from data source', () async {
      // Arrange
      when(mockDataSource.getPendingUsers(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tPendingUsers);

      // Act
      final result = await repository.getPendingUsers(page: 1, perPage: 20);

      // Assert
      expect(result, tPendingUsers);
      verify(mockDataSource.getPendingUsers(page: 1, perPage: 20)).called(1);
    });

    test('should get pending users with default parameters', () async {
      // Arrange
      when(mockDataSource.getPendingUsers(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tPendingUsers);

      // Act
      await repository.getPendingUsers();

      // Assert
      verify(mockDataSource.getPendingUsers(page: 1, perPage: 20)).called(1);
    });

    test('should propagate getPendingUsers exception', () async {
      // Arrange
      when(mockDataSource.getPendingUsers(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenThrow(Exception('Failed to get pending users'));

      // Act & Assert
      expect(
        () => repository.getPendingUsers(),
        throwsException,
      );
    });
  });

  group('AdminUsersRepositoryImpl - getUserById', () {
    final tUser = UserEntity(
      id: '1',
      email: 'test@example.com',
      name: 'Test User',
      phone: '08123456789',
      role: UserRole.alumni,
      angkatan: 2010,
      isVerified: true,
      verified: true,
    );

    test('should get user by id from data source', () async {
      // Arrange
      when(mockDataSource.getUserById('1'))
          .thenAnswer((_) async => tUser);

      // Act
      final result = await repository.getUserById('1');

      // Assert
      expect(result, tUser);
      verify(mockDataSource.getUserById('1')).called(1);
    });

    test('should propagate getUserById exception', () async {
      // Arrange
      when(mockDataSource.getUserById('invalid'))
          .thenThrow(Exception('User not found'));

      // Act & Assert
      expect(
        () => repository.getUserById('invalid'),
        throwsException,
      );
    });
  });

  group('AdminUsersRepositoryImpl - verifyUser', () {
    test('should verify user through data source', () async {
      // Arrange
      when(mockDataSource.verifyUser('user123'))
          .thenAnswer((_) async => {});

      // Act
      await repository.verifyUser('user123');

      // Assert
      verify(mockDataSource.verifyUser('user123')).called(1);
    });

    test('should propagate verifyUser exception', () async {
      // Arrange
      when(mockDataSource.verifyUser(any))
          .thenThrow(Exception('Failed to verify user'));

      // Act & Assert
      expect(
        () => repository.verifyUser('user123'),
        throwsException,
      );
    });
  });

  group('AdminUsersRepositoryImpl - rejectUser', () {
    test('should reject user through data source', () async {
      // Arrange
      when(mockDataSource.rejectUser('user123'))
          .thenAnswer((_) async => {});

      // Act
      await repository.rejectUser('user123');

      // Assert
      verify(mockDataSource.rejectUser('user123')).called(1);
    });

    test('should propagate rejectUser exception', () async {
      // Arrange
      when(mockDataSource.rejectUser(any))
          .thenThrow(Exception('Failed to reject user'));

      // Act & Assert
      expect(
        () => repository.rejectUser('user123'),
        throwsException,
      );
    });
  });

  group('AdminUsersRepositoryImpl - updateUserRole', () {
    test('should update user role through data source', () async {
      // Arrange
      when(mockDataSource.updateUserRole('user123', UserRole.admin))
          .thenAnswer((_) async => {});

      // Act
      await repository.updateUserRole('user123', UserRole.admin);

      // Assert
      verify(mockDataSource.updateUserRole('user123', UserRole.admin))
          .called(1);
    });

    test('should propagate updateUserRole exception', () async {
      // Arrange
      when(mockDataSource.updateUserRole(any, any))
          .thenThrow(Exception('Failed to update role'));

      // Act & Assert
      expect(
        () => repository.updateUserRole('user123', UserRole.admin),
        throwsException,
      );
    });
  });

  group('AdminUsersRepositoryImpl - deleteUser', () {
    test('should delete user through data source', () async {
      // Arrange
      when(mockDataSource.deleteUser('user123'))
          .thenAnswer((_) async => {});

      // Act
      await repository.deleteUser('user123');

      // Assert
      verify(mockDataSource.deleteUser('user123')).called(1);
    });

    test('should propagate deleteUser exception', () async {
      // Arrange
      when(mockDataSource.deleteUser(any))
          .thenThrow(Exception('Failed to delete user'));

      // Act & Assert
      expect(
        () => repository.deleteUser('user123'),
        throwsException,
      );
    });
  });

  group('AdminUsersRepositoryImpl - searchUsers', () {
    final tSearchResults = [
      UserEntity(
        id: '1',
        email: 'search@example.com',
        name: 'Search Result',
        phone: '08123456789',
        role: UserRole.alumni,
        angkatan: 2010,
        isVerified: true,
        verified: true,
      ),
    ];

    test('should search users from data source', () async {
      // Arrange
      when(mockDataSource.searchUsers('john'))
          .thenAnswer((_) async => tSearchResults);

      // Act
      final result = await repository.searchUsers('john');

      // Assert
      expect(result, tSearchResults);
      verify(mockDataSource.searchUsers('john')).called(1);
    });

    test('should propagate searchUsers exception', () async {
      // Arrange
      when(mockDataSource.searchUsers(any))
          .thenThrow(Exception('Failed to search users'));

      // Act & Assert
      expect(
        () => repository.searchUsers('john'),
        throwsException,
      );
    });
  });
}
