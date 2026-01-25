/// User Model - DTO for PocketBase users collection
library;

import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/user_entity.dart';

/// User Model - Maps PocketBase record to domain entity
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final int? angkatan;
  final String role;
  final String? jobStatus;
  final String? company;
  final String? domisili;
  final bool isVerified;
  final bool verified;
  final DateTime? verifiedAt;
  final DateTime? created;
  final DateTime? updated;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.angkatan,
    required this.role,
    this.jobStatus,
    this.company,
    this.domisili,
    this.isVerified = false,
    this.verified = false,
    this.verifiedAt,
    this.created,
    this.updated,
  });

  /// Create from PocketBase RecordModel
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
      isVerified: record.getBoolValue('is_verified'),
      verified: record.getBoolValue('verified'), // System field
      verifiedAt: DateTime.tryParse(record.getStringValue('verified_at')),
      created: DateTime.tryParse(record.get<String>('created')),
      updated: DateTime.tryParse(record.get<String>('updated')),
    );
  }

  /// Convert to domain entity
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
      isVerified: isVerified,
      verified: verified,
      verifiedAt: verifiedAt,
    );
  }

  /// Create from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      angkatan: json['angkatan'] as int?,
      role: json['role'] as String? ?? 'public',
      jobStatus: json['job_status'] as String?,
      company: json['company'] as String?,
      domisili: json['domisili'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      verified: json['verified'] as bool? ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'] as String)
          : null,
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
      updated: json['updated'] != null
          ? DateTime.tryParse(json['updated'] as String)
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'angkatan': angkatan,
      'role': role,
      'job_status': jobStatus,
      'company': company,
      'domisili': domisili,
      'is_verified': isVerified,
      'verified': verified,
      'verified_at': verifiedAt?.toIso8601String(),
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }
}
