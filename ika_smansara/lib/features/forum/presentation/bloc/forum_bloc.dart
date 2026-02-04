import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/forum_post.dart';

import '../../domain/usecases/create_forum_post.dart';
import '../../domain/usecases/get_forum_posts.dart';
import '../../domain/usecases/toggle_forum_like.dart';

part 'forum_event.dart';
part 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final GetForumPosts getForumPosts;
  final CreateForumPost createForumPost;
  final ToggleForumLike toggleForumLike;

  ForumBloc({
    required this.getForumPosts,
    required this.createForumPost,
    required this.toggleForumLike,
  }) : super(ForumInitial()) {
    on<FetchForumPosts>(_onFetchForumPosts);
    on<RefreshForumPosts>(_onRefreshForumPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<LikePostEvent>(_onLikePost);
  }

  Future<void> _onFetchForumPosts(
    FetchForumPosts event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      final posts = await getForumPosts(category: event.category);
      emit(ForumLoaded(posts: posts));
    } catch (e) {
      log.error('ForumBloc: Failed to fetch posts', error: e);
      emit(const ForumError('Gagal memuat postingan forum.'));
    }
  }

  Future<void> _onRefreshForumPosts(
    RefreshForumPosts event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final posts = await getForumPosts(category: event.category);
      emit(ForumLoaded(posts: posts));
    } catch (e) {
      log.error('ForumBloc: Failed to refresh posts', error: e);
      emit(const ForumError('Gagal memuat ulang postingan.'));
    }
  }

  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<ForumState> emit,
  ) async {
    emit(ForumLoading());
    try {
      await createForumPost(
        content: event.content,
        category: event.category,
        visibility: event.visibility,
        images: event.images,
      );
      emit(ForumPostCreated());
      // Optionally re-fetch
      add(FetchForumPosts(category: event.category));
    } catch (e) {
      log.error('ForumBloc: Failed to create post', error: e);
      emit(const ForumError('Gagal membuat postingan.'));
    }
  }

  Future<void> _onLikePost(
    LikePostEvent event,
    Emitter<ForumState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is ForumLoaded) {
        final isLiked = await toggleForumLike(event.postId);

        final posts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              likeCount: isLiked
                  ? post.likeCount + 1
                  : (post.likeCount > 0 ? post.likeCount - 1 : 0),
              isLiked: isLiked,
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(posts: posts));
      }
    } catch (e) {
      log.error('ForumBloc: Failed to like post', error: e);
      // Handle error quietly or show snackbar via listener if needed
      // For now just stay in current state
    }
  }
}
