import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterAlumni {
  final AuthRepository repository;

  RegisterAlumni(this.repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int graduationYear,
  }) async {
    return await repository.registerAlumni(
      name: name,
      email: email,
      password: password,
      phone: phone,
      graduationYear: graduationYear,
    );
  }
}
