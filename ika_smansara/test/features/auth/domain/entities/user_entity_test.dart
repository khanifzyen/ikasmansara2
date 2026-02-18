import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserRole Enum', () {
    test('should have correct enum values', () {
      // Assert
      expect(UserRole.values.length, equals(3));
      expect(UserRole.alumni, isNotNull);
      expect(UserRole.public, isNotNull);
      expect(UserRole.admin, isNotNull);
    });

    test('fromString should parse correctly', () {
      // Act & Assert
      expect(UserRole.fromString('alumni'), equals(UserRole.alumni));
      expect(UserRole.fromString('public'), equals(UserRole.public));
      expect(UserRole.fromString('admin'), equals(UserRole.admin));
      expect(UserRole.fromString('invalid'), equals(UserRole.public));
    });

    test('fromString should return public for invalid values', () {
      // Arrange
      const invalidRoles = ['invalid', 'unknown', 'random'];

      // Act & Assert
      for (final role in invalidRoles) {
        expect(UserRole.fromString(role), equals(UserRole.public));
      }
    });
  });

  group('JobStatus Enum', () {
    test('should have correct enum values', () {
      // Assert
      expect(JobStatus.values.length, equals(5));
      expect(JobStatus.swasta, isNotNull);
      expect(JobStatus.pnsBumn, isNotNull);
      expect(JobStatus.wirausaha, isNotNull);
      expect(JobStatus.mahasiswa, isNotNull);
      expect(JobStatus.lainnya, isNotNull);
    });

    test('fromString should parse standard values', () {
      // Act & Assert
      expect(JobStatus.fromString('swasta'), equals(JobStatus.swasta));
      expect(JobStatus.fromString('wirausaha'), equals(JobStatus.wirausaha));
      expect(JobStatus.fromString('mahasiswa'), equals(JobStatus.mahasiswa));
      expect(JobStatus.fromString('lainnya'), equals(JobStatus.lainnya));
    });

    test('fromString should parse pns_bumn correctly', () {
      // Act
      final result = JobStatus.fromString('pns_bumn');

      // Assert
      expect(result, equals(JobStatus.pnsBumn));
    });

    test('fromString should return lainnya for invalid values', () {
      // Arrange
      const invalidValues = ['invalid', 'unknown', 'random'];

      // Act & Assert
      for (final value in invalidValues) {
        expect(JobStatus.fromString(value), equals(JobStatus.lainnya));
      }
    });

    test('toApiValue should return correct format', () {
      // Act & Assert
      expect(JobStatus.swasta.toApiValue(), equals('swasta'));
      expect(JobStatus.pnsBumn.toApiValue(), equals('pns_bumn'));
      expect(JobStatus.wirausaha.toApiValue(), equals('wirausaha'));
      expect(JobStatus.mahasiswa.toApiValue(), equals('mahasiswa'));
      expect(JobStatus.lainnya.toApiValue(), equals('lainnya'));
    });

    test('displayName should return correct Indonesian text', () {
      // Act & Assert
      expect(JobStatus.swasta.displayName, equals('Swasta'));
      expect(JobStatus.pnsBumn.displayName, equals('PNS/BUMN'));
      expect(JobStatus.wirausaha.displayName, equals('Wirausaha'));
      expect(JobStatus.mahasiswa.displayName, equals('Mahasiswa'));
      expect(JobStatus.lainnya.displayName, equals('Lainnya'));
    });
  });

  group('UserEntity', () {
    test('should create UserEntity instance correctly', () {
      // Arrange & Act
      final user = UserEntity(
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
        verifiedAt: DateTime(2025),
      );

      // Assert
      expect(user.id, equals('1'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.angkatan, equals(2020));
      expect(user.role, equals(UserRole.alumni));
      expect(user.isAlumni, isTrue);
      expect(user.isVerified, isTrue);
    });

    test('should create UserEntity with minimal required fields', () {
      // Arrange & Act
      final minimalUser = UserEntity(
        id: '2',
        email: 'minimal@example.com',
        name: 'Minimal User',
        phone: '08987654321',
        role: UserRole.public,
      );

      // Assert
      expect(minimalUser.avatar, isNull);
      expect(minimalUser.angkatan, isNull);
      expect(minimalUser.jobStatus, isNull);
      expect(minimalUser.company, isNull);
      expect(minimalUser.domisili, isNull);
      expect(minimalUser.noUrutAngkatan, isNull);
      expect(minimalUser.noUrutGlobal, isNull);
      expect(minimalUser.isVerified, isFalse);
      expect(minimalUser.verified, isFalse);
      expect(minimalUser.verifiedAt, isNull);
    });

    test('isAlumni should return true only for alumni role', () {
      // Arrange
      final alumni = UserEntity(
        id: '1',
        email: 'a@b.com',
        name: 'Alumni',
        phone: '1',
        role: UserRole.alumni,
      );
      final admin = UserEntity(
        id: '2',
        email: 'a@c.com',
        name: 'Admin',
        phone: '2',
        role: UserRole.admin,
      );
      final public = UserEntity(
        id: '3',
        email: 'a@d.com',
        name: 'Public',
        phone: '3',
        role: UserRole.public,
      );

      // Assert
      expect(alumni.isAlumni, isTrue);
      expect(admin.isAlumni, isFalse);
      expect(public.isAlumni, isFalse);
    });

    test('isAdmin should return true only for admin role', () {
      // Arrange
      final admin = UserEntity(
        id: '1',
        email: 'admin@test.com',
        name: 'Admin',
        phone: '1',
        role: UserRole.admin,
      );
      final alumni = UserEntity(
        id: '2',
        email: 'alumni@test.com',
        name: 'Alumni',
        phone: '2',
        role: UserRole.alumni,
      );

      // Assert
      expect(admin.isAdmin, isTrue);
      expect(alumni.isAdmin, isFalse);
    });

    test('nomorEkta should return formatted string', () {
      // Arrange
      final userWithEkta = UserEntity(
        id: '1',
        email: 'a@b.com',
        name: 'User',
        phone: '1',
        angkatan: 2020,
        noUrutAngkatan: 123,
        noUrutGlobal: 456,
        role: UserRole.alumni,
      );

      // Act
      final result = userWithEkta.nomorEkta;

      // Assert
      expect(result, equals('2020.0123.456'));
    });

    test('nomorEkta should return dash when missing data', () {
      // Arrange
      final userWithoutEkta = UserEntity(
        id: '1',
        email: 'a@b.com',
        name: 'User',
        phone: '1',
        role: UserRole.alumni,
      );

      // Act
      final result = userWithoutEkta.nomorEkta;

      // Assert
      expect(result, equals('-'));
    });

    test('should implement Equatable', () {
      // Arrange
      final user1 = UserEntity(
        id: '1',
        email: 'test@test.com',
        name: 'Test',
        phone: '1',
        role: UserRole.public,
      );
      final user2 = UserEntity(
        id: '1',
        email: 'test@test.com',
        name: 'Test',
        phone: '1',
        role: UserRole.public,
      );
      final user3 = UserEntity(
        id: '2',
        email: 'test2@test.com',
        name: 'Test2',
        phone: '2',
        role: UserRole.alumni,
      );

      // Assert
      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('should handle different job statuses', () {
      // Arrange
      final pnsUser = UserEntity(
        id: '1',
        email: 'pns@test.com',
        name: 'PNS User',
        phone: '1',
        role: UserRole.alumni,
        jobStatus: JobStatus.pnsBumn,
      );

      // Assert
      expect(pnsUser.jobStatus, equals(JobStatus.pnsBumn));
      expect(pnsUser.jobStatus?.displayName, equals('PNS/BUMN'));
    });

    test('should handle verified status with timestamp', () {
      // Arrange
      final verifiedTime = DateTime(2025, 2, 18, 10, 30);
      final verifiedUser = UserEntity(
        id: '1',
        email: 'verified@test.com',
        name: 'Verified',
        phone: '1',
        role: UserRole.alumni,
        verifiedAt: verifiedTime,
        verified: true,
        isVerified: true,
      );

      // Assert
      expect(verifiedUser.verifiedAt, equals(verifiedTime));
      expect(verifiedUser.verified, isTrue);
      expect(verifiedUser.isVerified, isTrue);
    });
  });
}
