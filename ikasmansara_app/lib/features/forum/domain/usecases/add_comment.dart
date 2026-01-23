import 'package:ikasmansara_app/features/forum/domain/entities/comment_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/repositories/forum_repository.dart';

class AddComment {
  final ForumRepository repository;

  AddComment(this.repository);

  Future<CommentEntity> call({
    required String postId,
    required String content,
  }) {
    return repository.addComment(postId: postId, content: content);
  }
}
