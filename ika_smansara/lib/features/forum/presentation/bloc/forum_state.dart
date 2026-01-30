part of 'forum_bloc.dart';

abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {}

class ForumLoading extends ForumState {}

class ForumLoaded extends ForumState {
  final List<ForumPost> posts;
  final bool hasReachedMax;

  const ForumLoaded({required this.posts, this.hasReachedMax = false});

  @override
  List<Object?> get props => [posts, hasReachedMax];

  ForumLoaded copyWith({List<ForumPost>? posts, bool? hasReachedMax}) {
    return ForumLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ForumError extends ForumState {
  final String message;

  const ForumError(this.message);

  @override
  List<Object?> get props => [message];
}

class ForumPostCreated extends ForumState {}
