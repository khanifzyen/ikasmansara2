import '../../domain/repositories/admin_users_repository.dart';
import '../datasources/admin_users_remote_data_source.dart';
import '../../../../auth/domain/entities/user_entity.dart';

class AdminUsersRepositoryImpl implements AdminUsersRepository {
  final AdminUsersRemoteDataSource _dataSource;

  AdminUsersRepositoryImpl(this._dataSource);

  @override
  Future<List<UserEntity>> getUsers({
    String? filter,
    int page = 1,
    int perPage = 20,
  }) {
    return _dataSource.getUsers(filter: filter, page: page, perPage: perPage);
  }

  @override
  Future<List<UserEntity>> getPendingUsers({int page = 1, int perPage = 20}) {
    return _dataSource.getPendingUsers(page: page, perPage: perPage);
  }

  @override
  Future<UserEntity> getUserById(String id) {
    return _dataSource.getUserById(id);
  }

  @override
  Future<void> verifyUser(String userId) {
    return _dataSource.verifyUser(userId);
  }

  @override
  Future<void> rejectUser(String userId) {
    return _dataSource.rejectUser(userId);
  }

  @override
  Future<void> updateUserRole(String userId, UserRole role) {
    return _dataSource.updateUserRole(userId, role);
  }

  @override
  Future<void> deleteUser(String userId) {
    return _dataSource.deleteUser(userId);
  }

  @override
  Future<List<UserEntity>> searchUsers(String query) {
    return _dataSource.searchUsers(query);
  }
}
