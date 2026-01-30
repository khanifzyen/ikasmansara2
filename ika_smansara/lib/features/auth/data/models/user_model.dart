// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    required String name,
    required String phone,
    String? avatar,
    int? angkatan,
    required String role,
    @JsonKey(name: 'job_status') String? jobStatus,
    String? company,
    String? domisili,
    @JsonKey(name: 'no_urut_angkatan') int? noUrutAngkatan,
    @JsonKey(name: 'no_urut_global') int? noUrutGlobal,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @Default(false) bool verified,
    @JsonKey(name: 'verified_at') DateTime? verifiedAt,
    DateTime? created,
    DateTime? updated,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromRecord(RecordModel record) {
    return UserModel(
      id: record.id,
      email: record.getStringValue('email'),
      name: record.getStringValue('name'),
      phone: record.getStringValue('phone'),
      avatar: record.getStringValue('avatar'),
      angkatan: record.getIntValue('angkatan'),
      role: record.getStringValue('role'),
      jobStatus: record.getStringValue('job_status'),
      company: record.getStringValue('company'),
      domisili: record.getStringValue('domisili'),
      noUrutAngkatan: record.getIntValue('no_urut_angkatan'),
      noUrutGlobal: record.getIntValue('no_urut_global'),
      isVerified: record.getBoolValue('is_verified'),
      verified: record.getBoolValue('verified'),
      verifiedAt: DateTime.tryParse(record.getStringValue('verified_at')),
      created:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updated:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      avatar: avatar,
      angkatan: angkatan,
      role: UserRole.fromString(role),
      jobStatus: jobStatus != null ? JobStatus.fromString(jobStatus!) : null,
      company: company,
      domisili: domisili,
      noUrutAngkatan: noUrutAngkatan,
      noUrutGlobal: noUrutGlobal,
      isVerified: isVerified,
      verified: verified,
      verifiedAt: verifiedAt,
    );
  }
}
