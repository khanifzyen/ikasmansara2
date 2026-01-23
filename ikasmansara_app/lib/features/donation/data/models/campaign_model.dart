import 'package:ikasmansara_app/core/network/api_endpoints.dart';
import 'package:ikasmansara_app/features/donation/domain/entities/campaign_entity.dart';
import 'package:pocketbase/pocketbase.dart';

class CampaignModel extends CampaignEntity {
  const CampaignModel({
    required super.id,
    required super.title,
    required super.description,
    required super.targetAmount,
    required super.collectedAmount,
    super.imageUrl,
    required super.deadline,
    required super.isUrgent,
    required super.organizer,
  });

  factory CampaignModel.fromRecord(RecordModel record) {
    return CampaignModel(
      id: record.id,
      title: record.getStringValue('title'),
      description: record.getStringValue('description'),
      targetAmount: record.getDoubleValue('target_amount'),
      collectedAmount: record.getDoubleValue('collected_amount'),
      imageUrl: record.getStringValue('banner_image').isNotEmpty
          ? '${ApiEndpoints.baseUrl}/api/files/${record.collectionId}/${record.id}/${record.getStringValue('banner_image')}'
          : null,
      deadline:
          DateTime.tryParse(record.getStringValue('deadline')) ??
          DateTime.now().add(const Duration(days: 30)),
      isUrgent: record.getBoolValue('is_urgent'),
      organizer: record.getStringValue('organizer'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'collected_amount': collectedAmount,
      'deadline': deadline.toIso8601String(),
      'is_urgent': isUrgent,
      'organizer': organizer,
    };
  }
}
