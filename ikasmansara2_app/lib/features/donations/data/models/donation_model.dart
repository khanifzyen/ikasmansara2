// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/donation.dart';

part 'donation_model.freezed.dart';
part 'donation_model.g.dart';

@freezed
abstract class DonationModel with _$DonationModel {
  const DonationModel._();

  const factory DonationModel({
    required String id,
    required String title,
    required String description,
    @JsonKey(name: 'target_amount') required double targetAmount,
    @JsonKey(name: 'collected_amount') required double collectedAmount,
    required DateTime deadline,
    required String banner,
    required String organizer,
    required String category,
    required String priority,
    required String status,
    @JsonKey(name: 'donor_count') required int donorCount,
    @JsonKey(name: 'created_by') required String createdBy,
  }) = _DonationModel;

  factory DonationModel.fromJson(Map<String, dynamic> json) =>
      _$DonationModelFromJson(json);

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
