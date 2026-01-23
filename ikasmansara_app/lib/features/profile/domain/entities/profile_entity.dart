import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String role;
  final bool isVerified;
  final int? angkatan;
  final String? bio;
  final String? job;
  final String? phone;
  final String? linkedin;
  final String? instagram;

  const ProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.isVerified = false,
    this.angkatan,
    this.bio,
    this.job,
    this.phone,
    this.linkedin,
    this.instagram,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    avatarUrl,
    role,
    isVerified,
    angkatan,
    bio,
    job,
    phone,
    linkedin,
    instagram,
  ];
}
