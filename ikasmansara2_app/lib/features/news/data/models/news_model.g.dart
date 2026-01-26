// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NewsModel _$NewsModelFromJson(Map<String, dynamic> json) => _NewsModel(
  id: json['id'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String,
  category: json['category'] as String,
  thumbnail: json['thumbnail'] as String?,
  summary: json['summary'] as String,
  content: json['content'] as String,
  authorId: json['author'] as String,
  expand: json['expand'] as Map<String, dynamic>?,
  publishDate: DateTime.parse(json['publish_date'] as String),
  viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$NewsModelToJson(_NewsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'category': instance.category,
      'thumbnail': instance.thumbnail,
      'summary': instance.summary,
      'content': instance.content,
      'author': instance.authorId,
      'expand': instance.expand,
      'publish_date': instance.publishDate.toIso8601String(),
      'view_count': instance.viewCount,
    };
