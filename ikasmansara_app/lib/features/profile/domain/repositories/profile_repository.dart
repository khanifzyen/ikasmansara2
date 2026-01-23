import 'dart:io';
import 'package:ikasmansara_app/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getUserProfile(String userId);
  Future<ProfileEntity> updateProfile({
    required String userId,
    String? name,
    String? bio,
    String? job,
    String? phone,
    String? linkedin,
    String? instagram,
    int? angkatan,
    File? avatar,
  });
}
