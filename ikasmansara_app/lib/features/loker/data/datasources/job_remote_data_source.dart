import 'package:pocketbase/pocketbase.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/job_model.dart';
import '../../domain/entities/job_entity.dart';

abstract class JobRemoteDataSource {
  Future<List<JobEntity>> getJobs({
    String? query,
    String? type,
    int page = 1,
    int perPage = 20,
  });
  Future<JobEntity> getJobDetail(String id);
  Future<void> createJob(Map<String, dynamic> data);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final PocketBase pb;

  JobRemoteDataSourceImpl(this.pb);

  @override
  Future<List<JobEntity>> getJobs({
    String? query,
    String? type,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final filter = <String>[];
      filter.add('is_active = true');

      if (query != null && query.isNotEmpty) {
        filter.add('(title ~ "$query" || company ~ "$query")');
      }

      if (type != null && type != 'Semua') {
        filter.add('type = "$type"');
      }

      final result = await pb
          .collection('loker_posts')
          .getList(
            page: page,
            perPage: perPage,
            // filter: filter.join(' && '), // DISABLE FILTER (DEBUG)
            // sort: '-created', // DISABLE SORT (DEBUG)
            // expand: 'author_id', // DISABLE EXPAND (DEBUG)
          );

      return result.items.map((record) => JobModel.fromRecord(record)).toList();
    } catch (e) {
      print("JOB LIST ERROR: $e"); // Debug print
      if (e is ClientException) {
        throw mapPocketBaseError(e as ClientException);
      }
      throw AppException.unknown(message: e.toString());
    }
  }

  @override
  Future<JobEntity> getJobDetail(String id) async {
    try {
      final record = await pb
          .collection('loker_posts')
          .getOne(id, expand: 'author_id');
      return JobModel.fromRecord(record);
    } catch (e) {
      if (e is ClientException) {
        throw mapPocketBaseError(e as ClientException);
      }
      throw AppException.unknown(message: e.toString());
    }
  }

  @override
  Future<void> createJob(Map<String, dynamic> data) async {
    try {
      await pb.collection('loker_posts').create(body: data);
    } catch (e) {
      if (e is ClientException) {
        throw mapPocketBaseError(e as ClientException);
      }
      throw AppException.unknown(message: e.toString());
    }
  }
}
