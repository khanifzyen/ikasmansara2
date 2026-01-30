import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<UserEntity> call() async {
    return await repository.getProfile();
  }
}
