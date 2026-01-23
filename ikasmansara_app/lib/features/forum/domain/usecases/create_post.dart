import 'dart:io';
import 'package:ikasmansara_app/features/forum/domain/entities/post_entity.dart';
import 'package:ikasmansara_app/features/forum/domain/repositories/forum_repository.dart';

class CreatePost {
  final ForumRepository repository;

  CreatePost(this.repository);

  Future<PostEntity> call({
    required String content,
    required String category,
    List<File>? images,
  }) {
    return repository.createPost(
      content: content,
      category: category,
      images: images,
    );
  }
}
