import 'dart:io';
import 'package:ikasmansara_app/features/profile/domain/entities/profile_entity.dart';
import 'package:ikasmansara_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfile {
  final ProfileRepository repository;

  UpdateUserProfile(this.repository);

  Future<ProfileEntity> call({
    required String userId,
    String? name,
    String? bio,
    String? job,
    String? phone,
    String? linkedin,
    String? instagram,
    int? angkatan,
    File? avatar,
  }) {
    return repository.updateProfile(
      userId: userId,
      name: name,
      bio: bio,
      job: job,
      phone: phone,
      linkedin: linkedin,
      instagram: instagram,
      angkatan: angkatan,
      avatar: avatar,
    );
  }
}
