import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/forum_post.dart';

part 'forum_post_model.freezed.dart';
part 'forum_post_model.g.dart';

@freezed
abstract class ForumPostModel with _$ForumPostModel {
  const factory ForumPostModel({
    required String id,
    @JsonKey(name: 'collectionId') required String collectionId,
    @JsonKey(name: 'collectionName') required String collectionName,
    @JsonKey(name: 'created') required String created,
    @JsonKey(name: 'updated') required String updated,
    required String content,
    @Default([])
    List<String> image, // PocketBase might return array for multiple files
    required String category,
    required String visibility,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    required String status,
    @JsonKey(name: 'expand') Map<String, dynamic>? expand,
  }) = _ForumPostModel;

  factory ForumPostModel.fromJson(Map<String, dynamic> json) =>
      _$ForumPostModelFromJson(json);
}

extension ForumPostModelX on ForumPostModel {
  ForumPost toEntity() {
    // Extract author from expand
    final authorData = expand?['user'];
    String authorName = 'Unknown';
    String? authorAvatar;
    String? authorId;

    if (authorData != null) {
      authorId = authorData['id'];
      authorName = authorData['name'] ?? 'Unknown';
      authorAvatar = authorData['avatar'];
    }

    return ForumPost(
      id: id,
      content: content,
      images: image,
      category: category,
      visibility: visibility,
      likeCount: likeCount,
      commentCount: commentCount,
      isPinned: isPinned,
      status: status,
      createdAt: DateTime.parse(created),
      authorId: authorId ?? '',
      authorName: authorName,
      authorAvatar: authorAvatar,
    );
  }
}
