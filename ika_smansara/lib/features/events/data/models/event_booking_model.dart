import '../../domain/entities/event_booking.dart';
import 'package:pocketbase/pocketbase.dart';
import 'event_model.dart';

class EventBookingModel extends EventBooking {
  const EventBookingModel({
    required super.id,
    required super.collectionId,
    required super.collectionName,
    required super.eventId,
    required super.userId,
    required super.bookingId,
    required super.created,
    required super.metadata,
    required super.subtotal,
    required super.serviceFee,
    required super.totalPrice,
    required super.paymentStatus,
    super.paymentMethod,
    super.paymentDate,
    super.snapToken,
    super.snapRedirectUrl,
    super.event,
    super.registrationChannel,
    super.coordinatorName,
    super.coordinatorPhone,
    super.coordinatorAngkatan,
    super.manualTicketCount,
    super.manualTicketType,
    super.paymentProof,
    super.notes,
    super.userName,
    super.userPhone,
    super.userAngkatan,
  });

  factory EventBookingModel.fromRecord(RecordModel record) {
    return EventBookingModel(
      id: record.id,
      collectionId: record.collectionId,
      collectionName: record.collectionName,
      eventId: record.getStringValue('event'),
      userId: record.getStringValue('user'),
      bookingId: record.getStringValue('booking_id'),
      created: DateTime.parse(record.get<String>('created')),
      metadata: record.data['metadata'] is List
          ? List<Map<String, dynamic>>.from(record.data['metadata'])
          : [],
      subtotal: record.getIntValue('subtotal'),
      serviceFee: record.getIntValue('service_fee'),
      totalPrice: record.getIntValue('total_price'),
      paymentStatus: record.getStringValue('payment_status'),
      paymentMethod: record.getStringValue('payment_method').isNotEmpty
          ? record.getStringValue('payment_method')
          : null,
      paymentDate: record.getStringValue('payment_date').isNotEmpty
          ? DateTime.parse(record.getStringValue('payment_date'))
          : null,
      snapToken: record.getStringValue('snap_token').isNotEmpty
          ? record.getStringValue('snap_token')
          : null,
      snapRedirectUrl: record.getStringValue('snap_redirect_url').isNotEmpty
          ? record.getStringValue('snap_redirect_url')
          : null,
      event: () {
        final expandedEvent = record.get<List<RecordModel>?>('expand.event');
        if (expandedEvent != null && expandedEvent.isNotEmpty) {
          return EventModel.fromRecord(expandedEvent.first).toEntity();
        }
        return null;
      }(),
      registrationChannel:
          record.getStringValue('registration_channel').isNotEmpty
          ? record.getStringValue('registration_channel')
          : null,
      coordinatorName: record.getStringValue('coordinator_name').isNotEmpty
          ? record.getStringValue('coordinator_name')
          : null,
      coordinatorPhone: record.getStringValue('coordinator_phone').isNotEmpty
          ? record.getStringValue('coordinator_phone')
          : null,
      coordinatorAngkatan: record.getIntValue('coordinator_angkatan') > 0
          ? record.getIntValue('coordinator_angkatan')
          : null,
      manualTicketCount: record.getIntValue('manual_ticket_count') > 0
          ? record.getIntValue('manual_ticket_count')
          : null,
      manualTicketType: record.getStringValue('manual_ticket_type').isNotEmpty
          ? record.getStringValue('manual_ticket_type')
          : null,
      paymentProof: record.getStringValue('payment_proof').isNotEmpty
          ? record.getStringValue('payment_proof')
          : null,
      notes: record.getStringValue('notes').isNotEmpty
          ? record.getStringValue('notes')
          : null,
      userName: () {
        final expandedUser = record.get<List<RecordModel>?>('expand.user');
        if (expandedUser != null && expandedUser.isNotEmpty) {
          return expandedUser.first.getStringValue('name');
        }
        return null;
      }(),
      userPhone: () {
        final expandedUser = record.get<List<RecordModel>?>('expand.user');
        if (expandedUser != null && expandedUser.isNotEmpty) {
          return expandedUser.first.getStringValue('phone');
        }
        return null;
      }(),
      userAngkatan: () {
        final expandedUser = record.get<List<RecordModel>?>('expand.user');
        if (expandedUser != null && expandedUser.isNotEmpty) {
          return expandedUser.first.getStringValue('angkatan');
        }
        return null;
      }(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': eventId,
      'user': userId,
      'metadata': metadata,
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'registration_channel': registrationChannel,
      'coordinator_name': coordinatorName,
      'coordinator_phone': coordinatorPhone,
      'coordinator_angkatan': coordinatorAngkatan,
      'manual_ticket_count': manualTicketCount,
      'manual_ticket_type': manualTicketType,
      'notes': notes,
      'user_name': userName,
      'user_phone': userPhone,
      'user_angkatan': userAngkatan,
    };
  }
}
