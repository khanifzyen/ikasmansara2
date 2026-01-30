import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile(ProfileUpdateParams params);
}

class ProfileUpdateParams {
  final String? name;
  final String? phone;
  final JobStatus? jobStatus;
  final String? company;
  final String? domisili;

  ProfileUpdateParams({
    this.name,
    this.phone,
    this.jobStatus,
    this.company,
    this.domisili,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (phone != null) map['phone'] = phone;
    if (jobStatus != null) map['job_status'] = jobStatus!.toApiValue();
    if (company != null) map['company'] = company;
    if (domisili != null) map['domisili'] = domisili;
    return map;
  }
}
