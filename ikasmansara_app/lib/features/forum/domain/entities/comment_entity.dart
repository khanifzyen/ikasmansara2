import 'package:ikasmansara_app/features/auth/domain/entities/user_entity.dart';

class CommentEntity {
  final String id;
  final UserEntity? author;
  final String content;
  final String postId;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    this.author,
    required this.content,
    required this.postId,
    required this.createdAt,
  });
}
