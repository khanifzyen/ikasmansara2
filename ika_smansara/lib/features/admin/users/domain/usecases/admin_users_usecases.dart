import '../repositories/admin_users_repository.dart';
import '../../../../auth/domain/entities/user_entity.dart';

class GetAllUsers {
  final AdminUsersRepository repository;

  GetAllUsers(this.repository);

  Future<List<UserEntity>> call({
    String? filter,
    int page = 1,
    int perPage = 20,
  }) {
    return repository.getUsers(filter: filter, page: page, perPage: perPage);
  }
}

class GetPendingUsers {
  final AdminUsersRepository repository;

  GetPendingUsers(this.repository);

  Future<List<UserEntity>> call({int page = 1, int perPage = 20}) {
    return repository.getPendingUsers(page: page, perPage: perPage);
  }
}

class GetUserById {
  final AdminUsersRepository repository;

  GetUserById(this.repository);

  Future<UserEntity> call(String id) {
    return repository.getUserById(id);
  }
}

class VerifyUser {
  final AdminUsersRepository repository;

  VerifyUser(this.repository);

  Future<void> call(String userId) {
    return repository.verifyUser(userId);
  }
}

class RejectUser {
  final AdminUsersRepository repository;

  RejectUser(this.repository);

  Future<void> call(String userId) {
    return repository.rejectUser(userId);
  }
}

class SearchUsers {
  final AdminUsersRepository repository;

  SearchUsers(this.repository);

  Future<List<UserEntity>> call(String query) {
    return repository.searchUsers(query);
  }
}
