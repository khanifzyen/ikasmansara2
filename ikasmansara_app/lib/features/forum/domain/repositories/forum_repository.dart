import 'dart:io';
import 'package:ikasmansara_app/features/forum/domain/entities/comment_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/entities/post_entity.dart';

abstract class ForumRepository {
  /// Fetch list of posts with optional filtering
  Future<List<PostEntity>> getPosts({
    String? category, // Filter by category
    String? query, // Search content
    int page = 1,
    int perPage = 20,
  });

  /// Create a new post with optional images
  Future<PostEntity> createPost({
    required String content,
    required String category,
    List<File>? images,
  });

  /// Get details of a single post
  Future<PostEntity> getPostDetail(String id);

  /// Toggle like status for a post
  /// Returns the new `isLiked` status
  Future<bool> toggleLike(String postId);

  /// Fetch comments for a specific post
  Future<List<CommentEntity>> getComments(String postId);

  /// Add a comment to a post
  Future<CommentEntity> addComment({
    required String postId,
    required String content,
  });

  /// Delete a post (only by author)
  Future<void> deletePost(String postId);
}
