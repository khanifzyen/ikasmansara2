import '../entities/news_entity.dart';

abstract class NewsRepository {
  Future<List<NewsEntity>> getNews({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  });

  Future<NewsEntity> getNewsDetail(String id);
}
