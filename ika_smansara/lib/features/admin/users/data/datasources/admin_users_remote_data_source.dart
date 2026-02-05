import 'package:pocketbase/pocketbase.dart';
import '../../../../../core/network/pb_client.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../auth/domain/entities/user_entity.dart';

/// Data source for admin user management operations
class AdminUsersRemoteDataSource {
  final PocketBase _pb;

  AdminUsersRemoteDataSource() : _pb = PBClient.instance.pb;

  /// Get all users with optional filter
  Future<List<UserEntity>> getUsers({
    String? filter,
    int page = 1,
    int perPage = 20,
  }) async {
    final result = await _pb
        .collection('users')
        .getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: '-created',
        );

    return result.items.map((record) {
      return UserModel.fromRecord(record).toEntity();
    }).toList();
  }

  /// Get pending verification users (is_verified = false, role = alumni)
  Future<List<UserEntity>> getPendingUsers({
    int page = 1,
    int perPage = 20,
  }) async {
    final result = await _pb
        .collection('users')
        .getList(
          page: page,
          perPage: perPage,
          filter: 'is_verified = false && role = "alumni"',
          sort: '-created',
        );

    return result.items.map((record) {
      return UserModel.fromRecord(record).toEntity();
    }).toList();
  }

  /// Get user by ID
  Future<UserEntity> getUserById(String id) async {
    final record = await _pb.collection('users').getOne(id);
    return UserModel.fromRecord(record).toEntity();
  }

  /// Verify a user
  Future<void> verifyUser(String userId) async {
    await _pb
        .collection('users')
        .update(
          userId,
          body: {
            'is_verified': true,
            'verified_at': DateTime.now().toIso8601String(),
          },
        );
  }

  /// Reject user verification (delete or mark as rejected)
  Future<void> rejectUser(String userId) async {
    // For now, we'll mark as not verified but could also add rejection reason
    await _pb.collection('users').update(userId, body: {'is_verified': false});
  }

  /// Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _pb.collection('users').update(userId, body: {'role': role.name});
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _pb.collection('users').delete(userId);
  }

  /// Search users by name or email
  Future<List<UserEntity>> searchUsers(String query) async {
    final result = await _pb
        .collection('users')
        .getList(
          page: 1,
          perPage: 50,
          filter: 'name ~ "$query" || email ~ "$query"',
          sort: 'name',
        );

    return result.items.map((record) {
      return UserModel.fromRecord(record).toEntity();
    }).toList();
  }
}
