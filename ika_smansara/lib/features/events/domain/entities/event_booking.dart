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
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? snapToken;
  final String? snapRedirectUrl;
  final DateTime created;
  final Event? event;
  final String? registrationChannel;
  final String? coordinatorName;
  final String? coordinatorPhone;
  final int? coordinatorAngkatan;
  final int? manualTicketCount;
  final String? manualTicketType;
  final String? paymentProof;
  final String? notes;
  final String? userName;
  final String? userPhone;
  final String? userAngkatan;

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
    this.paymentMethod,
    this.paymentDate,
    this.snapToken,
    this.snapRedirectUrl,
    this.event,
    this.registrationChannel,
    this.coordinatorName,
    this.coordinatorPhone,
    this.coordinatorAngkatan,
    this.manualTicketCount,
    this.manualTicketType,
    this.paymentProof,
    this.notes,
    this.userName,
    this.userPhone,
    this.userAngkatan,
  });

  String get displayName {
    if (registrationChannel == 'app' || userId.isNotEmpty) {
      return userName ?? 'User App';
    }
    return '(Koordinator) ${coordinatorName ?? '-'}';
  }

  String get displayPhone {
    if (registrationChannel == 'app' || userId.isNotEmpty) {
      return userPhone ?? '-';
    }
    return coordinatorPhone ?? '-';
  }

  String get displayAngkatan {
    if (registrationChannel == 'app' || userId.isNotEmpty) {
      return userAngkatan ?? '-';
    }
    return coordinatorAngkatan?.toString() ?? '-';
  }

  String get displayNotes {
    if (registrationChannel == 'app' || userId.isNotEmpty) {
      if (metadata.isEmpty) return '-';
      List<String> details = [];
      for (var item in metadata) {
        final options = item['options'];
        if (options is Map && options.isNotEmpty) {
          options.forEach((key, value) {
            if (value != null) details.add(value.toString());
          });
        }
      }
      return details.isNotEmpty ? details.join(', ') : '-';
    }
    return notes ?? '-';
  }

  int get displayPrice {
    if (subtotal > 0) return subtotal;
    return totalPrice;
  }

  int get displayTicketCount {
    if (registrationChannel == 'app' || userId.isNotEmpty) {
      int count = 0;
      for (var item in metadata) {
        final qty = item['quantity'];
        if (qty is int) {
          count += qty;
        } else if (qty is String) {
          count += int.tryParse(qty) ?? 0;
        }
      }
      return count > 0 ? count : metadata.length;
    }
    return manualTicketCount ?? 0;
  }

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
    paymentMethod,
    paymentDate,
    snapToken,
    snapRedirectUrl,
    event,
    registrationChannel,
    coordinatorName,
    coordinatorPhone,
    coordinatorAngkatan,
    manualTicketCount,
    manualTicketType,
    paymentProof,
    notes,
    userName,
    userPhone,
    userAngkatan,
  ];
}
