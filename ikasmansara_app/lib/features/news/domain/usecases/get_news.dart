import '../entities/news_entity.dart';
import '../repositories/news_repository.dart';

class GetNews {
  final NewsRepository repository;

  GetNews(this.repository);

  Future<List<NewsEntity>> execute({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getNews(
      category: category,
      query: query,
      page: page,
      limit: limit,
    );
  }
}
