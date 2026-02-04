import 'package:equatable/equatable.dart';
import 'event.dart';

class EventBooking extends Equatable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String eventId;
  final String userId;
  final String bookingId;
  final List<dynamic>
  metadata; // Using dynamic for flexibility with JSON cart items
  final int totalPrice;
  final String paymentStatus;
  final String? snapToken;
  final String? snapRedirectUrl;
  final DateTime created;
  final Event? event;
  final int isDeleted;

  const EventBooking({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.eventId,
    required this.userId,
    required this.bookingId,
    required this.created,
    required this.metadata,
    required this.totalPrice,
    required this.paymentStatus,
    this.snapToken,
    this.snapRedirectUrl,
    this.event,
    this.isDeleted = 0,
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
    totalPrice,
    paymentStatus,
    snapToken,
    snapRedirectUrl,
    event,
    isDeleted,
  ];
}
