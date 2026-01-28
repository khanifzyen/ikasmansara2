part of 'forum_bloc.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class FetchForumPosts extends ForumEvent {
  final String? category;
  const FetchForumPosts({this.category});

  @override
  List<Object?> get props => [category];
}

class RefreshForumPosts extends ForumEvent {
  final String? category;
  const RefreshForumPosts({this.category});

  @override
  List<Object?> get props => [category];
}

class CreatePostEvent extends ForumEvent {
  final String content;
  final String category;
  final String visibility;
  final List<String> images;

  const CreatePostEvent({
    required this.content,
    required this.category,
    required this.visibility,
    this.images = const [],
  });
}

class LikePostEvent extends ForumEvent {
  final String postId;
  const LikePostEvent(this.postId);
}
