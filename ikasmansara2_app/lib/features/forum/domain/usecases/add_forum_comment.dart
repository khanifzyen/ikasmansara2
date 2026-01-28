import '../entities/forum_post.dart';
import '../repositories/forum_repository.dart';

class AddForumComment {
  final ForumRepository repository;

  AddForumComment(this.repository);

  Future<ForumComment> call({required String postId, required String content}) {
    return repository.addComment(postId, content);
  }
}
