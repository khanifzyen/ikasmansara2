import 'package:ikasmansara_app/features/forum/domain/repositories/forum_repository.dart';

class ToggleLikePost {
  final ForumRepository repository;

  ToggleLikePost(this.repository);

  Future<bool> call(String postId) {
    return repository.toggleLike(postId);
  }
}
