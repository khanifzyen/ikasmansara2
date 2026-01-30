import '../entities/news.dart';

abstract class NewsRepository {
  Future<List<News>> getNewsList({
    int page = 1,
    int perPage = 10,
    String? category,
  });

  Future<News> getNewsDetail(String id);
}
