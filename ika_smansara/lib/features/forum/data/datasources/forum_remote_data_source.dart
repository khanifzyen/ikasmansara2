import '../../../../core/network/pb_client.dart';
import '../models/forum_post_model.dart';
import '../models/forum_comment_model.dart';

abstract class ForumRemoteDataSource {
  Future<List<ForumPostModel>> getPosts({String? category});
  Future<ForumPostModel> createPost(
    String content,
    String category,
    String visibility,
    List<String> images,
  );
  Future<List<ForumCommentModel>> getComments(String postId);
  Future<ForumCommentModel> addComment(String postId, String content);
  Future<bool> toggleLike(String postId);
}

class ForumRemoteDataSourceImpl implements ForumRemoteDataSource {
  final PBClient _client;

  ForumRemoteDataSourceImpl(this._client);

  @override
  Future<List<ForumPostModel>> getPosts({String? category}) async {
    try {
      final filter = StringBuffer('status="active"');
      if (category != null) {
        filter.write(' && category="$category"');
      }

      final records = await _client.pb
          .collection('forum_posts')
          .getList(
            page: 1,
            perPage: 50,
            filter: filter.toString(),
            sort: '-created',
            expand: 'user',
          );

      return records.items
          .map((record) => ForumPostModel.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load forum posts: $e');
    }
  }

  @override
  Future<ForumPostModel> createPost(
    String content,
    String category,
    String visibility,
    List<String> images,
  ) async {
    try {
      final body = {
        'content': content,
        'category': category,
        'visibility': visibility,
        'user': _client.pb.authStore.record?.id,
        'status':
            'active', // Direct active for now, change if moderation needed
        'images':
            images, // Assuming images are already uploaded and we pass IDs/Urls? No, usually IDs or MultipartFile.
        // For simplicity assuming image IDs or separate upload first. Revisit if needed.
      };

      // If handling file upload directly here, we need MultipartFile.
      // For now let's assume images are optional or handled separately.

      final record = await _client.pb
          .collection('forum_posts')
          .create(body: body, expand: 'user');

      return ForumPostModel.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<List<ForumCommentModel>> getComments(String postId) async {
    try {
      final records = await _client.pb
          .collection('forum_comments')
          .getList(filter: 'post="$postId"', sort: 'created', expand: 'user');

      return records.items
          .map((record) => ForumCommentModel.fromJson(record.toJson()))
          .toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  @override
  Future<ForumCommentModel> addComment(String postId, String content) async {
    try {
      final body = {
        'post': postId,
        'content': content,
        'user': _client.pb.authStore.record?.id,
      };

      final record = await _client.pb
          .collection('forum_comments')
          .create(body: body, expand: 'user');

      return ForumCommentModel.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  @override
  Future<bool> toggleLike(String postId) async {
    try {
      final userId = _client.pb.authStore.record?.id;
      // Check if already liked
      final existingLikes = await _client.pb
          .collection('forum_likes')
          .getList(filter: 'post="$postId" && user="$userId"');

      if (existingLikes.items.isNotEmpty) {
        // Unlike
        await _client.pb
            .collection('forum_likes')
            .delete(existingLikes.items.first.id);
        return false;
      } else {
        // Like
        await _client.pb
            .collection('forum_likes')
            .create(body: {'post': postId, 'user': userId});
        return true;
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }
}
