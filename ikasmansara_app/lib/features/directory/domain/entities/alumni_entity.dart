class AlumniEntity {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int angkatan;
  final String role;
  final String? jobType;
  final String? company;
  final String? position;
  final String? domicile;

  const AlumniEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.angkatan,
    required this.role,
    this.jobType,
    this.company,
    this.position,
    this.domicile,
  });

  // Helper getters
  String get fullJobTitle {
    if (position != null && company != null) {
      return '$position at $company';
    } else if (position != null) {
      return position!;
    } else if (company != null) {
      return company!;
    } else {
      return jobType ?? '-';
    }
  }
}
