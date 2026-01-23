import 'package:ikasmansara_app/features/forum/domain/entities/comment_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/repositories/forum_repository.dart';

class GetComments {
  final ForumRepository repository;

  GetComments(this.repository);

  Future<List<CommentEntity>> call(String postId) {
    return repository.getComments(postId);
  }
}
