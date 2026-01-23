import 'package:ikasmansara_app/features/auth/data/models/user_model.dart';
import 'package:ikasmansara_app/features/forum/domain/entities/comment_entity.dart';
import 'package:pocketbase/pocketbase.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    super.author,
    required super.content,
    required super.postId,
    required super.createdAt,
  });

  factory CommentModel.fromRecord(RecordModel record) {
    // Handle expand 'author'
    UserModel? author;
    try {
      if (record.expand['author'] != null &&
          record.expand['author']!.isNotEmpty) {
        author = UserModel.fromRecord(record.expand['author']![0]);
      }
    } catch (e) {
      // Author expansion failed
    }

    return CommentModel(
      id: record.id,
      author: author,
      content: record.getStringValue('content'),
      postId: record.getStringValue('post'),
      createdAt: DateTime.parse(record.created),
    );
  }
}
