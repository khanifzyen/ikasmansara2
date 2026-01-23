import 'package:ikasmansara_app/features/profile/domain/entities/profile_entity.dart';
import 'package:ikasmansara_app/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfile {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  Future<ProfileEntity> call(String userId) {
    return repository.getUserProfile(userId);
  }
}
