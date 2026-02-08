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
    super.snapToken,
    super.snapRedirectUrl,
    super.event,
    super.registrationChannel,
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
      metadata: record.data['metadata'] is List ? record.data['metadata'] : [],
      subtotal: record.getIntValue('subtotal'),
      serviceFee: record.getIntValue('service_fee'),
      totalPrice: record.getIntValue('total_price'),
      paymentStatus: record.getStringValue('payment_status'),
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
    };
  }
}
