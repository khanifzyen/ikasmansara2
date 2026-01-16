import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      return await dataSource.login(email, password);
    } catch (e) {
      throw AppException.fromNetworkException(e);
    }
  }

  @override
  Future<UserEntity> registerAlumni({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int graduationYear,
  }) async {
    try {
      return await dataSource.registerAlumni(
        name: name,
        email: email,
        password: password,
        phone: phone,
        graduationYear: graduationYear,
      );
    } catch (e) {
      throw AppException.fromNetworkException(e);
    }
  }

  @override
  Future<void> logout() async {
    await dataSource.logout();
  }

  @override
  Future<bool> isAuthenticated() async {
    return dataSource.isAuthenticated();
  }
}
