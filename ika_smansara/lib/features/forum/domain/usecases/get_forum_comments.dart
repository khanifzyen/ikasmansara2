import '../entities/forum_post.dart';
import '../repositories/forum_repository.dart';

class GetForumComments {
  final ForumRepository repository;

  GetForumComments(this.repository);

  Future<List<ForumComment>> call(String postId) {
    return repository.getComments(postId);
  }
}
