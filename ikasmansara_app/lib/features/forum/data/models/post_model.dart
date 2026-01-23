import 'package:ikasmansara_app/features/auth/data/models/user_model.dart';
import 'package:ikasmansara_app/features/forum/domain/entities/post_entity.dart';
import 'package:pocketbase/pocketbase.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    super.author,
    required super.content,
    required super.images,
    required super.category,
    required super.likesCount,
    required super.isLiked,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromRecord(RecordModel record, {String? currentUserId}) {
    List<String> images = [];
    if (record.data['images'] is List) {
      images = (record.data['images'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (record.data['images'] is String) {
      // Single image or empty
      if ((record.data['images'] as String).isNotEmpty) {
        images = [record.data['images']];
      }
    }

    // Handle expand 'author'
    UserModel? author;
    try {
      if (record.expand['author'] != null &&
          record.expand['author']!.isNotEmpty) {
        author = UserModel.fromRecord(record.expand['author']![0]);
      }
    } catch (e) {
      // Author expansion failed or missing
    }

    // Handle 'likes' count and status
    List<String> likes = [];
    if (record.data['likes'] is List) {
      likes = (record.data['likes'] as List).map((e) => e.toString()).toList();
    }

    // Check if current user liked this post
    bool isLiked = false;
    if (currentUserId != null) {
      isLiked = likes.contains(currentUserId);
    }

    return PostModel(
      id: record.id,
      author: author,
      content: record.getStringValue('content'),
      images: images,
      category: record.getStringValue('category', 'Umum'),
      likesCount: likes.length,
      isLiked: isLiked,
      createdAt: DateTime.parse(record.created),
      updatedAt: DateTime.parse(record.updated),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'category': category,
      // 'author' and 'likes' are handled by relation updates
    };
  }
}
