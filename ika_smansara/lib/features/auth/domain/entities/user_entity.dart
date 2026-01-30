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
  final String phone;
  final String? avatar;
  final int? angkatan;
  final UserRole role;
  final JobStatus? jobStatus;
  final String? company;
  final String? domisili;
  final int? noUrutAngkatan;
  final int? noUrutGlobal;
  final bool isVerified;
  final bool verified;
  final DateTime? verifiedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.avatar,
    this.angkatan,
    required this.role,
    this.jobStatus,
    this.company,
    this.domisili,
    this.noUrutAngkatan,
    this.noUrutGlobal,
    this.isVerified = false,
    this.verified = false,
    this.verifiedAt,
  });

  bool get isAlumni => role == UserRole.alumni;
  bool get isAdmin => role == UserRole.admin;

  String get nomorEkta {
    if (angkatan == null || noUrutAngkatan == null || noUrutGlobal == null) {
      return '-';
    }
    final paddedNoUrut = noUrutAngkatan.toString().padLeft(4, '0');
    return '$angkatan.$paddedNoUrut.$noUrutGlobal';
  }

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
    noUrutAngkatan,
    noUrutGlobal,
    isVerified,
    isVerified,
    verified,
    verifiedAt,
  ];
}
