import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<UserEntity> call(ProfileUpdateParams params) async {
    return await repository.updateProfile(params);
  }
}
