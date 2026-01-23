class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String role; // 'alumni' or 'guest'
  final bool isVerified;
  final int? angkatan;
  final String? bio;
  final String? job;
  final String? phone;
  final String? linkedin;
  final String? instagram;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.role,
    this.isVerified = false,
    this.angkatan,
    this.bio,
    this.job,
    this.phone,
    this.linkedin,
    this.instagram,
  });

  String? get avatarUrl => avatar;
}
