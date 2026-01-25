/// User Entity - Pure domain representation of a user
library;

import 'package:equatable/equatable.dart';

/// User roles in the application
enum UserRole {
  alumni,
  public,
  admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.public,
    );
  }
}

/// Job status options for alumni
enum JobStatus {
  swasta,
  pnsBumn,
  wirausaha,
  mahasiswa,
  lainnya;

  static JobStatus fromString(String value) {
    switch (value) {
      case 'pns_bumn':
        return JobStatus.pnsBumn;
      default:
        return JobStatus.values.firstWhere(
          (status) => status.name == value,
          orElse: () => JobStatus.lainnya,
        );
    }
  }

  String toApiValue() {
    switch (this) {
      case JobStatus.pnsBumn:
        return 'pns_bumn';
      default:
        return name;
    }
  }

  String get displayName {
    switch (this) {
      case JobStatus.swasta:
        return 'Swasta';
      case JobStatus.pnsBumn:
        return 'PNS/BUMN';
      case JobStatus.wirausaha:
        return 'Wirausaha';
      case JobStatus.mahasiswa:
        return 'Mahasiswa';
      case JobStatus.lainnya:
        return 'Lainnya';
    }
  }
}

/// User entity for domain layer
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final int? angkatan;
  final UserRole role;
  final JobStatus? jobStatus;
  final String? company;
  final String? domisili;
  final bool isVerified;
  final DateTime? verifiedAt;

  const UserEntity({
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
    this.verifiedAt,
  });

  bool get isAlumni => role == UserRole.alumni;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    avatar,
    angkatan,
    role,
    jobStatus,
    company,
    domisili,
    isVerified,
    verifiedAt,
  ];
}
