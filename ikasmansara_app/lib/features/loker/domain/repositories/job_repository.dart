import '../entities/job_entity.dart';

abstract class JobRepository {
  Future<List<JobEntity>> getJobs({
    String? query,
    String? type,
    int page = 1,
    int perPage = 20,
  });
  Future<JobEntity> getJobDetail(String id);
  Future<void> createJob(Map<String, dynamic> jobData);
}
