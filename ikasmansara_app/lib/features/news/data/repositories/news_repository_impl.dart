import '../../domain/entities/news_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_data_source.dart';
import '../models/news_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NewsEntity>> getNews({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    return await remoteDataSource.getNews(
      category: category,
      query: query,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<NewsEntity> getNewsDetail(String id) async {
    return await remoteDataSource.getNewsDetail(id);
  }
}
