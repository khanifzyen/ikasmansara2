import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/donation_transaction.dart';

class DonationTransactionModel extends DonationTransaction {
  const DonationTransactionModel({
    required super.id,
    super.donationId,
    super.eventId,
    super.userId,
    required super.donorName,
    required super.amount,
    super.message,
    required super.isAnonymous,
    required super.paymentStatus,
    super.paymentMethod,
    required super.transactionId,
    required super.created,
  });

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

  factory DonationTransactionModel.fromJson(Map<String, dynamic> json) {
    return DonationTransactionModel(
      id: json['id'] as String? ?? '',
      donationId: json['donation'] as String?,
      eventId: json['event'] as String?,
      userId: json['user'] as String?,
      donorName: json['donor_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      paymentStatus: json['payment_status'] as String? ?? '',
      paymentMethod: json['payment_method'] as String?,
      transactionId: json['transaction_id'] as String? ?? '',
      created: DateTime.parse(json['created'] as String),
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
