import '../entities/forum_post.dart';
import '../repositories/forum_repository.dart';

class GetForumPosts {
  final ForumRepository repository;

  GetForumPosts(this.repository);

  Future<List<ForumPost>> call({String? category}) {
    return repository.getPosts(category: category);
  }
}
