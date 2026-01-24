import 'package:equatable/equatable.dart';

class NewsEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? image;
  final String category;
  final DateTime created;
  final String? authorName;

  const NewsEntity({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    required this.category,
    required this.created,
    this.authorName,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    image,
    category,
    created,
    authorName,
  ];
}
