import '../../../../core/errors/app_exception.dart';
import '../entities/alumni_entity.dart';
import '../repositories/directory_repository.dart';

class SearchAlumni {
  final DirectoryRepository repository;

  SearchAlumni(this.repository);

  Future<List<AlumniEntity>> call({
    String? query,
    int? angkatan,
    String? jobType,
    String? domicile,
  }) async {
    try {
      return await repository.searchAlumni(
        query: query,
        angkatan: angkatan,
        jobType: jobType,
        domicile: domicile,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.unknown(
        message: 'Gagal mencari alumni: ${e.toString()}',
      );
    }
  }
}
