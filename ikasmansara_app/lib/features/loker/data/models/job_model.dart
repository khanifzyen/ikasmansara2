import 'package:pocketbase/pocketbase.dart';

import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    required super.company,
    required super.title,
    required super.description,
    required super.location,
    required super.type,
    super.salaryRange,
    super.link,
    super.isActive,
    super.postedBy,
    super.created,
    super.updated,
  });

  factory JobModel.fromRecord(RecordModel record) {
    return JobModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      company: record.getStringValue('company'),
      title: record.getStringValue('title'),
      description: record.getStringValue('description'),
      location: record.getStringValue('location'),
      type: record.getStringValue('type', 'Fulltime'), // Default value
      salaryRange: record.getStringValue('salary_range'),
      link: record.getStringValue('link'),
      isActive: record.getBoolValue('is_active', true),
      postedBy:
          record.expand['author_id'] != null &&
              record.expand['author_id']!.isNotEmpty
          ? UserModel.fromRecord(record.expand['author_id']!.first)
          : null,
      created: DateTime.tryParse(record.created) ?? DateTime.now(),
      updated: DateTime.tryParse(record.updated) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'company': company,
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'salary_range': salaryRange,
      'link': link,
      'is_active': isActive,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }
}
