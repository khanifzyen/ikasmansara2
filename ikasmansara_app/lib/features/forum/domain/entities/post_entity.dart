import 'package:ikasmansara_app/features/auth/domain/entities/user_entity.dart';

class PostEntity {
  final String id;
  final UserEntity? author; // Populated from 'author' relation
  final String content;
  final List<String> images; // List of image URLs
  final String category; // 'Umum', 'Karir', 'Event', 'Diskusi'
  final int likesCount;
  final bool
  isLiked; // Derived from checking if current user ID is in 'likes' list
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    this.author,
    required this.content,
    required this.images,
    required this.category,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  // Empty/Loading state
  factory PostEntity.empty() {
    return PostEntity(
      id: '',
      content: '',
      images: [],
      category: 'Umum',
      likesCount: 0,
      isLiked: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
