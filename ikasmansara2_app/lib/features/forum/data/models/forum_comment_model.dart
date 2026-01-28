import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/forum_post.dart'; // Reusing for Comment entity if simple, or create separate

part 'forum_comment_model.freezed.dart';
part 'forum_comment_model.g.dart';

@freezed
abstract class ForumCommentModel with _$ForumCommentModel {
  const factory ForumCommentModel({
    required String id,
    @JsonKey(name: 'created') required String created,
    required String content,
    @JsonKey(name: 'expand') Map<String, dynamic>? expand,
  }) = _ForumCommentModel;

  factory ForumCommentModel.fromJson(Map<String, dynamic> json) =>
      _$ForumCommentModelFromJson(json);
}

extension ForumCommentModelX on ForumCommentModel {
  ForumComment toEntity() {
    final authorData = expand?['user'];
    String authorName = 'Unknown';
    String? authorAvatar;
    String authorId = '';

    if (authorData != null) {
      authorId = authorData['id'] ?? '';
      authorName = authorData['name'] ?? 'Unknown';
      authorAvatar = authorData['avatar'];
    }

    return ForumComment(
      id: id,
      content: content,
      createdAt: DateTime.parse(created),
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
    );
  }
}
