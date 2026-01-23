import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/core/network/pocketbase_service.dart';
import 'package:ikasmansara_app/features/forum/data/datasources/forum_remote_data_source.dart';
import 'package:ikasmansara_app/features/forum/data/repositories/forum_repository_impl.dart';
import 'package:ikasmansara_app/features/forum/domain/entities/comment_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/repositories/forum_repository.dart';
import 'package:ikasmansara_app/features/forum/domain/usecases/add_comment.dart';
import 'package:ikasmansara_app/features/forum/domain/usecases/create_post.dart';
import 'package:ikasmansara_app/features/forum/domain/usecases/get_comments.dart';
import 'package:ikasmansara_app/features/forum/domain/usecases/get_posts.dart';
import 'package:ikasmansara_app/features/forum/domain/usecases/toggle_like_post.dart';

// Data Source
final forumRemoteDataSourceProvider = Provider<ForumRemoteDataSource>((ref) {
  return ForumRemoteDataSourceImpl(PocketBaseService());
});

// Repository
final forumRepositoryProvider = Provider<ForumRepository>((ref) {
  final remoteDataSource = ref.watch(forumRemoteDataSourceProvider);
  return ForumRepositoryImpl(remoteDataSource);
});

// Use Cases
final getPostsProvider = Provider<GetPosts>((ref) {
  return GetPosts(ref.watch(forumRepositoryProvider));
});

final createPostProvider = Provider<CreatePost>((ref) {
  return CreatePost(ref.watch(forumRepositoryProvider));
});

final toggleLikePostProvider = Provider<ToggleLikePost>((ref) {
  return ToggleLikePost(ref.watch(forumRepositoryProvider));
});

final getCommentsProvider = Provider<GetComments>((ref) {
  return GetComments(ref.watch(forumRepositoryProvider));
});

final addCommentProvider = Provider<AddComment>((ref) {
  return AddComment(ref.watch(forumRepositoryProvider));
});

// Presentation Providers
final getPostCommentsProvider =
    FutureProvider.family<List<CommentEntity>, String>((ref, postId) {
      final getComments = ref.watch(getCommentsProvider);
      return getComments(postId);
    });
