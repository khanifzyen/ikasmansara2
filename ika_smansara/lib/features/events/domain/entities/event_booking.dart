import 'package:equatable/equatable.dart';
import 'event.dart';

class EventBooking extends Equatable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String eventId;
  final String userId;
  final String bookingId;
  final List<Map<String, dynamic>>
  metadata; // Using dynamic for flexibility with JSON cart items
  final int subtotal;
  final int serviceFee;
  final int totalPrice;
  final String paymentStatus;
  final String? snapToken;
  final String? snapRedirectUrl;
  final DateTime created;
  final Event? event;
  final String? registrationChannel;

  const EventBooking({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.eventId,
    required this.userId,
    required this.bookingId,
    required this.created,
    required this.metadata,
    required this.subtotal,
    required this.serviceFee,
    required this.totalPrice,
    required this.paymentStatus,
    this.snapToken,
    this.snapRedirectUrl,
    this.event,
    this.registrationChannel,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    eventId,
    userId,
    bookingId,
    created,
    metadata,
    subtotal,
    serviceFee,
    totalPrice,
    paymentStatus,
    snapToken,
    snapRedirectUrl,
    paymentStatus,
    snapToken,
    snapRedirectUrl,
    event,
    registrationChannel,
  ];
}
