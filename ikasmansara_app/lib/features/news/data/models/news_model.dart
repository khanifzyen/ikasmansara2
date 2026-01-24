import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/news_entity.dart';
import '../../../../core/network/api_endpoints.dart';

class NewsModel extends NewsEntity {
  const NewsModel({
    required super.id,
    required super.title,
    required super.content,
    super.image,
    required super.category,
    required super.created,
    super.authorName,
  });

  factory NewsModel.fromRecord(RecordModel record) {
    return NewsModel(
      id: record.id,
      title: record.getStringValue('title'),
      content: record.getStringValue('content'),
      image: record.getStringValue('image').isEmpty
          ? null
          : record.getStringValue('image'),
      category: record.getStringValue('category'),
      created: DateTime.tryParse(record.created) ?? DateTime.now(),
      authorName: record
          .expand['author_id']?[0]
          .data['name'], // Adjust based on relation
    );
  }

  String getImageUrl(String baseUrl) {
    if (image == null || image!.isEmpty) return '';
    return '$baseUrl/api/files/${ApiEndpoints.news}/$id/$image';
  }
}
