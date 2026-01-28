import '../../domain/entities/forum_post.dart';
import '../../domain/repositories/forum_repository.dart';
import '../datasources/forum_remote_data_source.dart';
import '../models/forum_comment_model.dart';
import '../models/forum_post_model.dart';

class ForumRepositoryImpl implements ForumRepository {
  final ForumRemoteDataSource _remoteDataSource;

  ForumRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ForumPost>> getPosts({String? category}) async {
    try {
      final models = await _remoteDataSource.getPosts(category: category);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ForumPost> createPost(
    String content,
    String category,
    String visibility,
    List<String> images,
  ) async {
    try {
      final model = await _remoteDataSource.createPost(
        content,
        category,
        visibility,
        images,
      );
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ForumComment>> getComments(String postId) async {
    try {
      final models = await _remoteDataSource.getComments(postId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ForumComment> addComment(String postId, String content) async {
    try {
      final model = await _remoteDataSource.addComment(postId, content);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> toggleLike(String postId) async {
    try {
      return await _remoteDataSource.toggleLike(postId);
    } catch (e) {
      rethrow;
    }
  }
}
