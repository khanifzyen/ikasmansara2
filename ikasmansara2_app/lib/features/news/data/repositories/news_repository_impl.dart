import 'package:injectable/injectable.dart';
import '../../domain/entities/news.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';

@LazySingleton(as: NewsRepository)
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _remoteDataSource;

  NewsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<News>> getNewsList({
    int page = 1,
    int perPage = 10,
    String? category,
  }) async {
    final models = await _remoteDataSource.getNewsList(
      page: page,
      perPage: perPage,
      category: category,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<News> getNewsDetail(String id) async {
    final model = await _remoteDataSource.getNewsDetail(id);
    return model.toEntity();
  }
}
