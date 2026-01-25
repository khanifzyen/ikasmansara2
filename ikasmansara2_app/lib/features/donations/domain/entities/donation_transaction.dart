import 'package:equatable/equatable.dart';

class DonationTransaction extends Equatable {
  final String id;
  final String? donationId;
  final String? eventId;
  final String? userId;
  final String donorName;
  final double amount;
  final String? message;
  final bool isAnonymous;
  final String paymentStatus;
  final String? paymentMethod;
  final String transactionId;
  final DateTime created;

  const DonationTransaction({
    required this.id,
    this.donationId,
    this.eventId,
    this.userId,
    required this.donorName,
    required this.amount,
    this.message,
    required this.isAnonymous,
    required this.paymentStatus,
    this.paymentMethod,
    required this.transactionId,
    required this.created,
  });

  bool get isSuccess => paymentStatus == 'success';
  bool get isPending => paymentStatus == 'pending';
  bool get isFailed => paymentStatus == 'failed';

  @override
  List<Object?> get props => [
    id,
    donationId,
    eventId,
    userId,
    donorName,
    amount,
    message,
    isAnonymous,
    paymentStatus,
    paymentMethod,
    transactionId,
    created,
  ];
}
