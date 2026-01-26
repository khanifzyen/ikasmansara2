import 'package:injectable/injectable.dart';
import '../entities/news.dart';
import '../repositories/news_repository.dart';

@injectable
class GetNewsList {
  final NewsRepository _repository;

  GetNewsList(this._repository);

  Future<List<News>> call({int page = 1, int perPage = 10, String? category}) {
    return _repository.getNewsList(
      page: page,
      perPage: perPage,
      category: category,
    );
  }
}
