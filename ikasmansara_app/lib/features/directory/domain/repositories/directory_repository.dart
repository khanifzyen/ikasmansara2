import '../entities/alumni_entity.dart';

abstract class DirectoryRepository {
  /// Search alumni with pagination and optional filters.
  /// [query] searches in name, company, or position.
  /// [angkatan] filters by exact year.
  /// [jobType] filters by job category (e.g. Swasta, BUMN).
  /// [domicile] filters by city.
  Future<List<AlumniEntity>> searchAlumni({
    String? query,
    int? angkatan,
    String? jobType,
    String? domicile,
    int page = 1,
    int limit = 20,
  });
}
