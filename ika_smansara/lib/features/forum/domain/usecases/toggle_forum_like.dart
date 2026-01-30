import '../repositories/forum_repository.dart';

class ToggleForumLike {
  final ForumRepository repository;

  ToggleForumLike(this.repository);

  Future<bool> call(String postId) {
    return repository.toggleLike(postId);
  }
}
