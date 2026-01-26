import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/news.dart';

part 'news_model.freezed.dart';
part 'news_model.g.dart';

@freezed
class NewsModel with _$NewsModel {
  const NewsModel._();

  const factory NewsModel({
    required String id,
    required String title,
    required String slug,
    required String category,
    String? thumbnail,
    required String summary,
    required String content,
    @JsonKey(name: 'author') required String authorId,
    @JsonKey(name: 'expand') Map<String, dynamic>? expand,
    @JsonKey(name: 'publish_date') required DateTime publishDate,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
  }) = _NewsModel;

  factory NewsModel.fromJson(Map<String, dynamic> json) =>
      _$NewsModelFromJson(json);

  factory NewsModel.fromRecord(RecordModel record) {
    return NewsModel.fromJson(record.toJson());
  }

  News toEntity() {
    String? authorName;
    String? authorAvatar;

    if (expand != null && expand!.containsKey('author')) {
      final authorRecord = expand!['author'];
      if (authorRecord is Map<String, dynamic>) {
        authorName = authorRecord['name'] as String?;
        // Construct avatar URL manually as it's not directly in record json
        // We'll handle full URL construction in the UI or Helper
        final avatarFilename = authorRecord['avatar'] as String?;
        final authorId = authorRecord['id'] as String?;
        final collectionId = authorRecord['collectionId'] as String?;
        if (avatarFilename != null &&
            authorId != null &&
            collectionId != null &&
            avatarFilename.isNotEmpty) {
          authorAvatar = '$collectionId/$authorId/$avatarFilename';
        }
      } else if (authorRecord is RecordModel) {
        authorName = authorRecord.getStringValue('name');
        final avatarFilename = authorRecord.getStringValue('avatar');
        if (avatarFilename.isNotEmpty) {
          authorAvatar =
              '${authorRecord.collectionId}/${authorRecord.id}/$avatarFilename';
        }
      }
    }

    return News(
      id: id,
      title: title,
      slug: slug,
      category: category,
      thumbnail: thumbnail,
      summary: summary,
      content: content,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      publishDate: publishDate,
      viewCount: viewCount,
    );
  }
}
