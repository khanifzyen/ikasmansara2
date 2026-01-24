import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/pocketbase_service.dart';
import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../../domain/usecases/get_news.dart';
import '../../data/datasources/news_remote_data_source.dart';
import '../../data/repositories/news_repository_impl.dart';

part 'news_providers.g.dart';

// Data Source
@riverpod
NewsRemoteDataSource newsRemoteDataSource(Ref ref) {
  final pb = ref.watch(pocketBaseServiceProvider);
  return NewsRemoteDataSourceImpl(pb);
}

// Repository
@riverpod
NewsRepository newsRepository(Ref ref) {
  final dataSource = ref.watch(newsRemoteDataSourceProvider);
  return NewsRepositoryImpl(dataSource);
}

// Use Case
@riverpod
GetNews getNews(Ref ref) {
  final repository = ref.watch(newsRepositoryProvider);
  return GetNews(repository);
}

// State Management
@riverpod
class NewsController extends _$NewsController {
  @override
  FutureOr<List<NewsEntity>> build() {
    return _fetchNews();
  }

  Future<List<NewsEntity>> _fetchNews({String? category, String? query}) async {
    final getNewsUseCase = ref.read(getNewsProvider);
    return await getNewsUseCase.execute(category: category, query: query);
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNews(query: query));
  }

  Future<void> filterByCategory(String category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNews(category: category));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNews());
  }
}

final selectedNewsCategoryProvider = StateProvider<String?>((ref) => 'Semua');
