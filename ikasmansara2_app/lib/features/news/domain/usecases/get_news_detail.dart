import 'package:injectable/injectable.dart';
import '../entities/news.dart';
import '../repositories/news_repository.dart';

@injectable
class GetNewsDetail {
  final NewsRepository _repository;

  GetNewsDetail(this._repository);

  Future<News> call(String id) {
    return _repository.getNewsDetail(id);
  }
}
