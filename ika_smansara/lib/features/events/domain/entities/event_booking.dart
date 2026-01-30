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
  final Event? event;

  const EventBooking({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.eventId,
    required this.userId,
    required this.bookingId,
    required this.metadata,
    required this.totalPrice,
    required this.paymentStatus,
    this.snapToken,
    this.snapRedirectUrl,
    this.event,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    eventId,
    userId,
    bookingId,
    metadata,
    totalPrice,
    paymentStatus,
    snapToken,
    snapRedirectUrl,
    event,
  ];
}
