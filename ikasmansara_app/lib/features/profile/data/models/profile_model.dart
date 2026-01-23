import 'package:ikasmansara_app/core/network/api_endpoints.dart';
import 'package:ikasmansara_app/features/profile/domain/entities/profile_entity.dart';
import 'package:pocketbase/pocketbase.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatarUrl,
    required super.role,
    super.isVerified,
    super.angkatan,
    super.bio,
    super.job,
    super.phone,
    super.linkedin,
    super.instagram,
  });

  factory ProfileModel.fromRecord(RecordModel record) {
    return ProfileModel(
      id: record.id,
      email: record.getStringValue('email'),
      name: record.getStringValue('name'),
      avatarUrl: record.getStringValue('avatar').isNotEmpty
          ? '${ApiEndpoints.baseUrl}/api/files/${record.collectionId}/${record.id}/${record.getStringValue('avatar')}'
          : null,
      role: record.getStringValue('role'),
      isVerified: record.getBoolValue('verified'),
      angkatan: record.getIntValue('angkatan'),
      bio: record.getStringValue('bio'),
      job: record.getStringValue('job'),
      phone: record.getStringValue('phone'),
      linkedin: record.getStringValue('linkedin'),
      instagram: record.getStringValue('instagram'),
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      isVerified: entity.isVerified,
      angkatan: entity.angkatan,
      bio: entity.bio,
      job: entity.job,
      phone: entity.phone,
      linkedin: entity.linkedin,
      instagram: entity.instagram,
    );
  }
}
