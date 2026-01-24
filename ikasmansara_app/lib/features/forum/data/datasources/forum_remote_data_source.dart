import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ikasmansara_app/core/network/pocketbase_service.dart';
import 'package:ikasmansara_app/features/forum/data/models/comment_model.dart';
import 'package:ikasmansara_app/features/forum/data/models/post_model.dart';

abstract class ForumRemoteDataSource {
  Future<List<PostModel>> getPosts({String? category, String? query});
  Future<PostModel> createPost({
    required String content,
    required String category,
    List<File>? images,
  });
  Future<PostModel> getPostDetail(String id);
  Future<void> toggleLike(String postId);
  Future<List<CommentModel>> getComments(String postId);
  Future<CommentModel> addComment({
    required String postId,
    required String content,
  });
  Future<void> deletePost(String postId);
}

class ForumRemoteDataSourceImpl implements ForumRemoteDataSource {
  final PocketBaseService _pbService;

  ForumRemoteDataSourceImpl(this._pbService);

  @override
  Future<List<PostModel>> getPosts({String? category, String? query}) async {
    // String? filter;
    // if (category != null && category != 'Semua' && category.isNotEmpty) {
    //   filter = 'category = "$category"';
    // }

    // Note: PocketBase search usually requires more complex filter setup for text search
    // For simple implementation, we assume basic filtering

    final records = await _pbService.pb
        .collection('posts')
        .getList(filter: filter, sort: '-created', expand: 'author');

    final currentUserId = _pbService.pb.authStore.model?.id;

    return records.items
        .map(
          (record) =>
              PostModel.fromRecord(record, currentUserId: currentUserId),
        )
        .toList();
  }

  @override
  Future<PostModel> createPost({
    required String content,
    required String category,
    List<File>? images,
  }) async {
    final userId = _pbService.pb.authStore.model?.id;
    if (userId == null) throw Exception('User not authenticated');

    final body = {'content': content, 'category': category, 'author': userId};

    List<http.MultipartFile> files = [];
    if (images != null) {
      for (var image in images) {
        files.add(await http.MultipartFile.fromPath('images', image.path));
      }
    }

    final record = await _pbService.pb
        .collection('posts')
        .create(body: body, files: files, expand: 'author');

    return PostModel.fromRecord(record, currentUserId: userId);
  }

  @override
  Future<PostModel> getPostDetail(String id) async {
    final record = await _pbService.pb
        .collection('posts')
        .getOne(id, expand: 'author');
    final currentUserId = _pbService.pb.authStore.model?.id;
    return PostModel.fromRecord(record, currentUserId: currentUserId);
  }

  @override
  Future<void> toggleLike(String postId) async {
    final userId = _pbService.pb.authStore.model?.id;
    if (userId == null) throw Exception('User not authenticated');

    final record = await _pbService.pb.collection('posts').getOne(postId);
    List<String> likes = [];
    if (record.data['likes'] is List) {
      likes = (record.data['likes'] as List).map((e) => e.toString()).toList();
    }

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await _pbService.pb
        .collection('posts')
        .update(postId, body: {'likes': likes});
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    final records = await _pbService.pb
        .collection('comments')
        .getList(
          filter: 'post = "$postId"',
          sort: 'created', // Oldest first for comments
          expand: 'author',
        );

    return records.items
        .map((record) => CommentModel.fromRecord(record))
        .toList();
  }

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String content,
  }) async {
    final userId = _pbService.pb.authStore.model?.id;
    if (userId == null) throw Exception('User not authenticated');

    final body = {'content': content, 'post': postId, 'author': userId};

    final record = await _pbService.pb
        .collection('comments')
        // .create(body: body, expand: 'author');
        .create(body: body); // DEBUG: Remove expand

    return CommentModel.fromRecord(record);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _pbService.pb.collection('posts').delete(postId);
  }
}
