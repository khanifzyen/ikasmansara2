import 'package:equatable/equatable.dart';

class ForumPost extends Equatable {
  final String id;
  final String content;
  final List<String> images;
  final String category;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final bool isPinned;
  final String status;
  final DateTime createdAt;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final bool isLiked;

  const ForumPost({
    required this.id,
    required this.content,
    required this.images,
    required this.category,
    required this.visibility,
    required this.likeCount,
    required this.commentCount,
    required this.isPinned,
    required this.status,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.isLiked = false,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    images,
    category,
    visibility,
    likeCount,
    commentCount,
    isPinned,
    status,
    createdAt,
    authorId,
    authorName,
    authorAvatar,
    isLiked,
  ];

  ForumPost copyWith({
    String? id,
    String? content,
    List<String>? images,
    String? category,
    String? visibility,
    int? likeCount,
    int? commentCount,
    bool? isPinned,
    String? status,
    DateTime? createdAt,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    bool? isLiked,
  }) {
    return ForumPost(
      id: id ?? this.id,
      content: content ?? this.content,
      images: images ?? this.images,
      category: category ?? this.category,
      visibility: visibility ?? this.visibility,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isPinned: isPinned ?? this.isPinned,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class ForumComment extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;
  final String authorId;
  final String authorName;
  final String? authorAvatar;

  const ForumComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    createdAt,
    authorId,
    authorName,
    authorAvatar,
  ];
}
