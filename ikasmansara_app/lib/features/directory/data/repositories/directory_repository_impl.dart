import '../../domain/entities/alumni_entity.dart';
import '../../domain/repositories/directory_repository.dart';
import '../datasources/directory_remote_data_source.dart';

class DirectoryRepositoryImpl implements DirectoryRepository {
  final DirectoryRemoteDataSource remoteDataSource;

  DirectoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AlumniEntity>> searchAlumni({
    String? query,
    int? angkatan,
    String? jobType,
    String? domicile,
    int page = 1,
    int limit = 20,
  }) async {
    final models = await remoteDataSource.searchAlumni(
      query: query,
      angkatan: angkatan,
      jobType: jobType,
      domicile: domicile,
      page: page,
      limit: limit,
    );
    return models;
  }
}
