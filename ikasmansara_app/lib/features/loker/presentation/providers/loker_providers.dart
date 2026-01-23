import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/pocketbase_service.dart';
import '../../data/datasources/job_remote_data_source.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../domain/usecases/get_jobs.dart';

final jobRepositoryProvider = Provider<JobRepositoryImpl>((ref) {
  final pb = ref.watch(pocketBaseServiceProvider);
  return JobRepositoryImpl(JobRemoteDataSourceImpl(pb));
});

final getJobsUseCaseProvider = Provider<GetJobs>((ref) {
  return GetJobs(ref.watch(jobRepositoryProvider));
});
