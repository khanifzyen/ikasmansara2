import '../entities/forum_post.dart';

abstract class ForumRepository {
  Future<List<ForumPost>> getPosts({String? category});
  Future<ForumPost> createPost(
    String content,
    String category,
    String visibility,
    List<String> images,
  );
  Future<List<ForumComment>> getComments(String postId);
  Future<ForumComment> addComment(String postId, String content);
  Future<bool> toggleLike(String postId);
}
