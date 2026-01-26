// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/donation_transaction.dart';

part 'donation_transaction_model.freezed.dart';
part 'donation_transaction_model.g.dart';

@freezed
abstract class DonationTransactionModel with _$DonationTransactionModel {
  const DonationTransactionModel._();

  const factory DonationTransactionModel({
    required String id,
    String? donationId,
    String? eventId,
    String? userId,
    @JsonKey(name: 'donor_name') required String donorName,
    required double amount,
    String? message,
    @JsonKey(name: 'is_anonymous') required bool isAnonymous,
    @JsonKey(name: 'payment_status') required String paymentStatus,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'transaction_id') required String transactionId,
    required DateTime created,
  }) = _DonationTransactionModel;

  factory DonationTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$DonationTransactionModelFromJson(json);

  factory DonationTransactionModel.fromRecord(RecordModel record) {
    return DonationTransactionModel(
      id: record.id,
      donationId: record.getStringValue('donation'),
      eventId: record.getStringValue('event'),
      userId: record.getStringValue('user'),
      donorName: record.getStringValue('donor_name'),
      amount: record.getDoubleValue('amount'),
      message: record.getStringValue('message'),
      isAnonymous: record.getBoolValue('is_anonymous'),
      paymentStatus: record.getStringValue('payment_status'),
      paymentMethod: record.getStringValue('payment_method'),
      transactionId: record.getStringValue('transaction_id'),
      created: DateTime.parse(record.get<String>('created')),
    );
  }

  DonationTransaction toEntity() {
    return DonationTransaction(
      id: id,
      donationId: donationId,
      eventId: eventId,
      userId: userId,
      donorName: donorName,
      amount: amount,
      message: message,
      isAnonymous: isAnonymous,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      created: created,
    );
  }
}
