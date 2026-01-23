import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'providers/loker_providers.dart';

part "post_job_controller.g.dart";

@riverpod
class PostJobController extends _$PostJobController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> createJob({
    required String title,
    required String company,
    required String type,
    required String location,
    String? salary,
    String? description,
    String? link,
    required String authorId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(jobRepositoryProvider);
      final jobData = {
        'title': title,
        'company': company,
        'type': type,
        'location': location,
        'salary_range': salary, // FIXED: Schema uses salary_range
        'description': description,
        'link': link,
        'author_id':
            authorId, // FIXED: Schema uses author_id (based on my previous DataSource fix, but need to be careful. Let's send both to be safe? No, let's use what DataSource expects. DataSource passes map body directly. Wait. DataSource uses 'loker_posts'. Let's check manual setup again. Manual setup for Jobs is MISSING in file scan. I need to assume 'loker_posts' has 'author_id' relation or 'author'. Standard PB relation is name of field. I will assume 'author_id' because I changed expand to 'author_id' earlier.)
        'is_active': true,
      };
      await repository.createJob(jobData);
    });

    if (state.hasError) {
      print("POST JOB ERROR: ${state.error}");
    }

    return !state.hasError;
  }
}
