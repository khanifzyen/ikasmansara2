import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/donation.dart';

class DonationModel extends Donation {
  const DonationModel({
    required super.id,
    required super.title,
    required super.description,
    required super.targetAmount,
    required super.collectedAmount,
    required super.deadline,
    required super.banner,
    required super.organizer,
    required super.category,
    required super.priority,
    required super.status,
    required super.donorCount,
    required super.createdBy,
  });

  factory DonationModel.fromRecord(RecordModel record) {
    return DonationModel(
      id: record.id,
      title: record.getStringValue('title'),
      description: record.getStringValue('description'),
      targetAmount: record.getDoubleValue('target_amount'),
      collectedAmount: record.getDoubleValue('collected_amount'),
      deadline: DateTime.parse(record.getStringValue('deadline')),
      banner: record.getStringValue('banner'),
      organizer: record.getStringValue('organizer'),
      category: record.getStringValue('category'),
      priority: record.getStringValue('priority'),
      status: record.getStringValue('status'),
      donorCount: record.getIntValue('donor_count'),
      createdBy: record.getStringValue('created_by'),
    );
  }

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0.0,
      collectedAmount: (json['collected_amount'] as num?)?.toDouble() ?? 0.0,
      deadline: DateTime.parse(json['deadline'] as String),
      banner: json['banner'] as String? ?? '',
      organizer: json['organizer'] as String? ?? '',
      category: json['category'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      status: json['status'] as String? ?? '',
      donorCount: json['donor_count'] as int? ?? 0,
      createdBy: json['created_by'] as String? ?? '',
    );
  }

  Donation toEntity() {
    return Donation(
      id: id,
      title: title,
      description: description,
      targetAmount: targetAmount,
      collectedAmount: collectedAmount,
      deadline: deadline,
      banner: banner,
      organizer: organizer,
      category: category,
      priority: priority,
      status: status,
      donorCount: donorCount,
      createdBy: createdBy,
    );
  }
}
