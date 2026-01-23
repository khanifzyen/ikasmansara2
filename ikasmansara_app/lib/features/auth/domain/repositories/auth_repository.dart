import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> registerAlumni({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int graduationYear,
  });
  Future<void> logout();
  Future<bool> isAuthenticated();
}
