import 'dart:io';

import 'package:ikasmansara_app/features/forum/domain/entities/post_entity.dart';
import 'package:ikasmansara_app/features/forum/presentation/providers/forum_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'forum_controller.g.dart';

@riverpod
class ForumController extends _$ForumController {
  @override
  FutureOr<List<PostEntity>> build() async {
    return _fetchPosts();
  }

  Future<List<PostEntity>> _fetchPosts({
    String? category,
    String? query,
  }) async {
    final getPosts = ref.read(getPostsProvider);
    return await getPosts(category: category, query: query);
  }

  Future<void> refresh({String? category}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPosts(category: category));
  }

  Future<void> filterByCategory(String category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPosts(category: category));
  }

  Future<void> createPost({
    required String content,
    required String category,
    List<File>? images,
  }) async {
    final createPost = ref.read(createPostProvider);

    // We don't optimistically update here as creation is complex
    // Instead we wait for success and then refresh
    await createPost(content: content, category: category, images: images);

    // Refresh feed to show new post
    ref.invalidateSelf();
    await future;
  }

  Future<void> toggleLike(String postId) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistically update UI
    final updatedPosts = currentState.map((post) {
      if (post.id == postId) {
        final newIsLiked = !post.isLiked;
        final newLikesCount = newIsLiked
            ? post.likesCount + 1
            : post.likesCount - 1;

        // Return modified copy
        // Since PostEntity is immutable, we need correct constructor or copyWith if available.
        // We defined explicit constructor in PostEntity without copyWith,
        // so we manually reconstruct. ideally should use freeze/copyWith.
        return PostEntity(
          id: post.id,
          author: post.author,
          content: post.content,
          images: post.images,
          category: post.category,
          likesCount: newLikesCount,
          isLiked: newIsLiked,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
        );
      }
      return post;
    }).toList();

    state = AsyncData(updatedPosts);

    try {
      final toggleLike = ref.read(toggleLikePostProvider);
      await toggleLike(postId);
    } catch (e) {
      // Revert if failed
      state = AsyncData(currentState);
      // Optional: Show error snackbar via listener in UI
    }
  }
}
