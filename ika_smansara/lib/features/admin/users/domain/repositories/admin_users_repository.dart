import '../../../../auth/domain/entities/user_entity.dart';

/// Repository interface for admin user management
abstract class AdminUsersRepository {
  /// Get all users with optional filter
  Future<List<UserEntity>> getUsers({
    String? filter,
    int page = 1,
    int perPage = 20,
  });

  /// Get pending verification users
  Future<List<UserEntity>> getPendingUsers({int page = 1, int perPage = 20});

  /// Get user by ID
  Future<UserEntity> getUserById(String id);

  /// Verify a user (set is_verified = true)
  Future<void> verifyUser(String userId);

  /// Reject user verification
  Future<void> rejectUser(String userId);

  /// Update user role
  Future<void> updateUserRole(String userId, UserRole role);

  /// Delete user
  Future<void> deleteUser(String userId);

  /// Search users by name or email
  Future<List<UserEntity>> searchUsers(String query);
}
