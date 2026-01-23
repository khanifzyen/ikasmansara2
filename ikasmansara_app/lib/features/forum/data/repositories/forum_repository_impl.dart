import 'dart:io';
import 'package:ikasmansara_app/core/network/network_exceptions.dart';
import 'package:ikasmansara_app/features/forum/data/datasources/forum_remote_data_source.dart';
import 'package:ikasmansara_app/features/forum/domain/entities/comment_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/entities/post_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/repositories/forum_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class ForumRepositoryImpl implements ForumRepository {
  final ForumRemoteDataSource remoteDataSource;

  ForumRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PostEntity>> getPosts({
    String? category,
    String? query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      return await remoteDataSource.getPosts(category: category, query: query);
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }

  @override
  Future<PostEntity> createPost({
    required String content,
    required String category,
    List<File>? images,
  }) async {
    try {
      return await remoteDataSource.createPost(
        content: content,
        category: category,
        images: images,
      );
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }

  @override
  Future<PostEntity> getPostDetail(String id) async {
    try {
      return await remoteDataSource.getPostDetail(id);
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }

  @override
  Future<bool> toggleLike(String postId) async {
    try {
      await remoteDataSource.toggleLike(postId);
      // We don't fetch the updated record here to save bandwidth
      // The controller should handle optimistic update or fetch fresh data if needed
      return true;
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }

  @override
  Future<List<CommentEntity>> getComments(String postId) async {
    try {
      return await remoteDataSource.getComments(postId);
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      return await remoteDataSource.addComment(
        postId: postId,
        content: content,
      );
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }
}
