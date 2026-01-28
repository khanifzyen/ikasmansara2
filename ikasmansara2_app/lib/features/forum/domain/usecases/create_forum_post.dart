import '../entities/forum_post.dart';
import '../repositories/forum_repository.dart';

class CreateForumPost {
  final ForumRepository repository;

  CreateForumPost(this.repository);

  Future<ForumPost> call({
    required String content,
    required String category,
    required String visibility,
    required List<String> images,
  }) {
    return repository.createPost(content, category, visibility, images);
  }
}
