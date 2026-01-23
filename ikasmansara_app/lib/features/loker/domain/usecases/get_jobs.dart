import '../entities/job_entity.dart';
import '../repositories/job_repository.dart';

class GetJobs {
  final JobRepository repository;

  GetJobs(this.repository);

  Future<List<JobEntity>> call({String? query, String? type, int page = 1}) {
    return repository.getJobs(query: query, type: type, page: page);
  }
}
