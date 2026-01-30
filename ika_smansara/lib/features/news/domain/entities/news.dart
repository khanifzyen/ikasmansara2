import 'package:equatable/equatable.dart';

class News extends Equatable {
  final String id;
  final String title;
  final String slug;
  final String category;
  final String? thumbnail;
  final String summary;
  final String content;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final DateTime publishDate;
  final int viewCount;

  const News({
    required this.id,
    required this.title,
    required this.slug,
    required this.category,
    this.thumbnail,
    required this.summary,
    required this.content,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    required this.publishDate,
    required this.viewCount,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    category,
    thumbnail,
    summary,
    content,
    authorId,
    authorName,
    authorAvatar,
    publishDate,
    viewCount,
  ];
}
