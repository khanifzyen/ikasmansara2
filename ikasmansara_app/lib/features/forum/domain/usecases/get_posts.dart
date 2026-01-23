import 'package:ikasmansara_app/features/forum/domain/entities/post_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/repositories/forum_repository.dart';

class GetPosts {
  final ForumRepository repository;

  GetPosts(this.repository);

  Future<List<PostEntity>> call({String? category, String? query}) {
    return repository.getPosts(category: category, query: query);
  }
}
