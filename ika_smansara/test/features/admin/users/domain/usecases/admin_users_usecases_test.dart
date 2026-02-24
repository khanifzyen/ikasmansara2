import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/admin/users/domain/repositories/admin_users_repository.dart';
import 'package:ika_smansara/features/admin/users/domain/usecases/admin_users_usecases.dart';
import 'package:ika_smansara/features/auth/domain/entities/user_entity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<AdminUsersRepository>()])
import 'admin_users_usecases_test.mocks.dart';

void main() {
  late MockAdminUsersRepository mockRepository;

  setUp(() {
    mockRepository = MockAdminUsersRepository();
  });

  // Test data
  final tUsersList = [
    UserEntity(
      id: 'user1',
      email: 'user1@example.com',
      name: 'User One',
      phone: '08123456789',
      role: UserRole.alumni,
      isVerified: true,
      angkatan: 2020,
    ),
    UserEntity(
      id: 'user2',
      email: 'user2@example.com',
      name: 'User Two',
      phone: '08987654321',
      role: UserRole.public,
      isVerified: false,
    ),
  ];

  group('GetAllUsers UseCase', () {
    late GetAllUsers useCase;

    setUp(() {
      useCase = GetAllUsers(mockRepository);
    });

    test('should get users list from repository', () async {
      // Arrange
      when(mockRepository.getUsers(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tUsersList);

      // Act
      final result = await useCase(
        filter: 'alumni',
        page: 1,
        perPage: 20,
      );

      // Assert
      expect(result, equals(tUsersList));
      expect(result, hasLength(2));
      verify(mockRepository.getUsers(
        filter: 'alumni',
        page: 1,
        perPage: 20,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get users without filter', () async {
      // Arrange
      when(mockRepository.getUsers(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tUsersList);

      // Act
      final result = await useCase();

      // Assert
      expect(result, hasLength(2));
      verify(mockRepository.getUsers(
        filter: null,
        page: 1,
        perPage: 20,
      ));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to load users');
      when(mockRepository.getUsers(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(filter: 'test'),
        throwsA(exception),
      );
    });

    test('should handle pagination parameters', () async {
      // Arrange
      when(mockRepository.getUsers(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => []);

      // Act
      await useCase(page: 2, perPage: 50);

      // Assert
      verify(mockRepository.getUsers(
        filter: null,
        page: 2,
        perPage: 50,
      ));
    });

    test('should handle empty users list', () async {
      // Arrange
      when(mockRepository.getUsers(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('GetPendingUsers UseCase', () {
    late GetPendingUsers useCase;

    setUp(() {
      useCase = GetPendingUsers(mockRepository);
    });

    final tPendingUsers = [
      UserEntity(
        id: 'pending1',
        email: 'pending1@example.com',
        name: 'Pending User',
        phone: '0811111111',
        role: UserRole.alumni,
        isVerified: false,
        angkatan: 2021,
      ),
    ];

    test('should get pending users from repository', () async {
      // Arrange
      when(mockRepository.getPendingUsers(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tPendingUsers);

      // Act
      final result = await useCase(page: 1, perPage: 20);

      // Assert
      expect(result, equals(tPendingUsers));
      expect(result, hasLength(1));
      expect(result.first.isVerified, isFalse);
      verify(mockRepository.getPendingUsers(page: 1, perPage: 20));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get pending users with default parameters', () async {
      // Arrange
      when(mockRepository.getPendingUsers(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tPendingUsers);

      // Act
      final result = await useCase();

      // Assert
      expect(result, hasLength(1));
      verify(mockRepository.getPendingUsers(page: 1, perPage: 20));
    });

    test('should handle pagination', () async {
      // Arrange
      when(mockRepository.getPendingUsers(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => []);

      // Act
      await useCase(page: 2, perPage: 50);

      // Assert
      verify(mockRepository.getPendingUsers(page: 2, perPage: 50));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to load pending users');
      when(mockRepository.getPendingUsers(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(exception),
      );
    });

    test('should handle empty pending users', () async {
      // Arrange
      when(mockRepository.getPendingUsers(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('GetUserById UseCase', () {
    late GetUserById useCase;

    setUp(() {
      useCase = GetUserById(mockRepository);
    });

    final tUser = UserEntity(
      id: 'user1',
      email: 'user1@example.com',
      name: 'Test User',
      phone: '08123456789',
      role: UserRole.alumni,
      isVerified: true,
    );

    test('should get user by ID from repository', () async {
      // Arrange
      when(mockRepository.getUserById('user1'))
          .thenAnswer((_) async => tUser);

      // Act
      final result = await useCase('user1');

      // Assert
      expect(result, equals(tUser));
      expect(result.id, equals('user1'));
      expect(result.name, equals('Test User'));
      verify(mockRepository.getUserById('user1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('User not found');
      when(mockRepository.getUserById('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('invalid'),
        throwsA(exception),
      );
      verify(mockRepository.getUserById('invalid'));
    });

    test('should call repository only once', () async {
      // Arrange
      when(mockRepository.getUserById('user1'))
          .thenAnswer((_) async => tUser);

      // Act
      await useCase('user1');

      // Assert
      verify(mockRepository.getUserById('user1')).called(1);
    });

    test('should handle different user IDs', () async {
      // Arrange
      when(mockRepository.getUserById(any))
          .thenAnswer((_) async => tUser);

      // Act
      await useCase('user1');
      await useCase('user2');

      // Assert
      verify(mockRepository.getUserById('user1'));
      verify(mockRepository.getUserById('user2'));
    });
  });

  group('VerifyUser UseCase', () {
    late VerifyUser useCase;

    setUp(() {
      useCase = VerifyUser(mockRepository);
    });

    test('should verify user via repository', () async {
      // Arrange
      when(mockRepository.verifyUser('user1'))
          .thenAnswer((_) async {});

      // Act
      await useCase('user1');

      // Assert
      verify(mockRepository.verifyUser('user1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Verification failed');
      when(mockRepository.verifyUser('user1'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('user1'),
        throwsA(exception),
      );
      verify(mockRepository.verifyUser('user1'));
    });

    test('should handle multiple verification calls', () async {
      // Arrange
      when(mockRepository.verifyUser(any))
          .thenAnswer((_) async {});

      // Act
      await useCase('user1');
      await useCase('user2');
      await useCase('user3');

      // Assert
      verify(mockRepository.verifyUser('user1'));
      verify(mockRepository.verifyUser('user2'));
      verify(mockRepository.verifyUser('user3'));
    });
  });

  group('RejectUser UseCase', () {
    late RejectUser useCase;

    setUp(() {
      useCase = RejectUser(mockRepository);
    });

    test('should reject user via repository', () async {
      // Arrange
      when(mockRepository.rejectUser('user1'))
          .thenAnswer((_) async {});

      // Act
      await useCase('user1');

      // Assert
      verify(mockRepository.rejectUser('user1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Rejection failed');
      when(mockRepository.rejectUser('user1'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('user1'),
        throwsA(exception),
      );
      verify(mockRepository.rejectUser('user1'));
    });

    test('should handle rejection of different users', () async {
      // Arrange
      when(mockRepository.rejectUser(any))
          .thenAnswer((_) async {});

      // Act
      await useCase('user1');
      await useCase('user2');

      // Assert
      verify(mockRepository.rejectUser('user1'));
      verify(mockRepository.rejectUser('user2'));
    });
  });

  group('SearchUsers UseCase', () {
    late SearchUsers useCase;

    setUp(() {
      useCase = SearchUsers(mockRepository);
    });

    final tSearchResults = [
      UserEntity(
        id: 'user1',
        email: 'john@example.com',
        name: 'John Doe',
        phone: '08123456789',
        role: UserRole.alumni,
        isVerified: true,
      ),
      UserEntity(
        id: 'user2',
        email: 'johnny@example.com',
        name: 'Johnny Smith',
        phone: '08987654321',
        role: UserRole.public,
        isVerified: false,
      ),
    ];

    test('should search users by query', () async {
      // Arrange
      when(mockRepository.searchUsers('john'))
          .thenAnswer((_) async => tSearchResults);

      // Act
      final result = await useCase('john');

      // Assert
      expect(result, equals(tSearchResults));
      expect(result, hasLength(2));
      verify(mockRepository.searchUsers('john'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no matches', () async {
      // Arrange
      when(mockRepository.searchUsers('nomatch'))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('nomatch');

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.searchUsers('nomatch'));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Search failed');
      when(mockRepository.searchUsers('test'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('test'),
        throwsA(exception),
      );
    });

    test('should handle empty query', () async {
      // Arrange
      when(mockRepository.searchUsers(''))
          .thenAnswer((_) async => tUsersList);

      // Act
      final result = await useCase('');

      // Assert
      expect(result, hasLength(2));
      verify(mockRepository.searchUsers(''));
    });

    test('should handle search by email', () async {
      // Arrange
      final emailResults = [
        tUsersList.first,
      ];
      when(mockRepository.searchUsers('user1@example.com'))
          .thenAnswer((_) async => emailResults);

      // Act
      final result = await useCase('user1@example.com');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.email, contains('user1'));
    });

    test('should call repository only once per search', () async {
      // Arrange
      when(mockRepository.searchUsers(any))
          .thenAnswer((_) async => tSearchResults);

      // Act
      await useCase('test');

      // Assert
      verify(mockRepository.searchUsers('test')).called(1);
    });
  });
}
