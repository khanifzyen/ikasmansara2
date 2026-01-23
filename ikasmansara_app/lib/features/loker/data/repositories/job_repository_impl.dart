import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_data_source.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<JobEntity>> getJobs({
    String? query,
    String? type,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return await remoteDataSource.getJobs(
        query: query,
        type: type,
        page: page,
        perPage: perPage,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(message: e.toString());
    }
  }

  @override
  Future<JobEntity> getJobDetail(String id) async {
    try {
      return await remoteDataSource.getJobDetail(id);
    } on NetworkException catch (e) {
      throw AppException.fromNetworkException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(message: e.toString());
    }
  }

  @override
  Future<void> createJob(Map<String, dynamic> jobData) async {
    try {
      await remoteDataSource.createJob(jobData);
    } on NetworkException catch (e) {
      throw AppException.fromNetworkException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(message: e.toString());
    }
  }
}
