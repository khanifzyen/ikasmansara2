import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import '../../../../../core/network/pb_client.dart';
import '../../../../events/data/models/event_booking_model.dart';
import '../../../../events/data/models/event_booking_ticket_model.dart';
import '../../../../events/data/models/event_model.dart';
import '../../../../events/data/models/event_ticket_model.dart';
import '../../../../events/domain/entities/event.dart';
import '../../../../events/domain/entities/event_booking.dart';
import '../../../../events/domain/entities/event_booking_ticket.dart';
import '../../../../events/domain/entities/event_ticket.dart';

/// Data source for admin event management operations
class AdminEventsRemoteDataSource {
  final PocketBase _pb;

  AdminEventsRemoteDataSource() : _pb = PBClient.instance.pb;

  /// Get all events with optional filter
  Future<List<Event>> getEvents({
    String? filter,
    int page = 1,
    int perPage = 20,
  }) async {
    final result = await _pb
        .collection('events')
        .getList(page: page, perPage: perPage, filter: filter, sort: '-date');

    return result.items.map((record) {
      return EventModel.fromRecord(record).toEntity();
    }).toList();
  }

  /// Get event by ID
  Future<Event> getEventById(String id) async {
    final record = await _pb.collection('events').getOne(id);
    return EventModel.fromRecord(record).toEntity();
  }

  /// Create new event
  Future<Event> createEvent(Map<String, dynamic> data) async {
    final List<http.MultipartFile> files = [];
    final Map<String, dynamic> body = Map.from(data);

    // Ensure created_by is set
    if (!body.containsKey('created_by') && _pb.authStore.isValid) {
      body['created_by'] = _pb.authStore.record?.id;
    }

    if (body.containsKey('banner') && body['banner'] is http.MultipartFile) {
      files.add(body['banner'] as http.MultipartFile);
      body.remove('banner');
    }

    final record = await _pb
        .collection('events')
        .create(body: body, files: files);
    return EventModel.fromRecord(record).toEntity();
  }

  /// Create event ticket
  Future<void> createEventTicket(Map<String, dynamic> data) async {
    await _pb.collection('event_tickets').create(body: data);
  }

  /// Update event
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _pb.collection('events').update(eventId, body: data);
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    await _pb.collection('events').delete(eventId);
  }

  /// Update event status
  Future<void> updateEventStatus(String eventId, String status) async {
    await _pb.collection('events').update(eventId, body: {'status': status});
  }

  /// Get event participants count
  Future<int> getParticipantsCount(String eventId) async {
    final result = await _pb
        .collection('event_bookings')
        .getList(
          page: 1,
          perPage: 1,
          filter:
              'event = "$eventId" && payment_status = "paid" && (is_deleted = 0 || is_deleted = null)',
        );
    return result.totalItems;
  }

  /// Get event stats (participants and income)
  Future<Map<String, dynamic>> getEventStats(String eventId) async {
    final confirmedBookings = await _pb
        .collection('event_bookings')
        .getFullList(
          filter:
              'event = "$eventId" && payment_status = "paid" && (is_deleted = 0 || is_deleted = null)',
        );

    int totalParticipants = confirmedBookings.length;
    double totalIncome = 0;

    for (var booking in confirmedBookings) {
      final model = EventBookingModel.fromRecord(booking);
      totalIncome += model.displayPrice.toDouble();
    }

    return {'totalParticipants': totalParticipants, 'totalIncome': totalIncome};
  }

  /// Get event bookings (participants)
  Future<List<EventBooking>> getEventBookings(String eventId) async {
    final result = await _pb
        .collection('event_bookings')
        .getList(
          page: 1,
          perPage: 500, // For now, simple list
          filter:
              'event = "$eventId" && payment_status != "expired" && payment_status != "cancelled" && (is_deleted = 0 || is_deleted = null)',
          sort: '-created',
          expand: 'user',
        );

    return result.items.map((record) {
      return EventBookingModel.fromRecord(record);
    }).toList();
  }

  /// Get specific booking tickets
  Future<List<EventBookingTicket>> getEventBookingTickets(
    String bookingId,
  ) async {
    final result = await _pb
        .collection('event_booking_tickets')
        .getList(
          page: 1,
          perPage: 100,
          filter: 'booking = "$bookingId"',
          expand: 'ticket_type,booking,booking.user',
        );

    return result.items.map((record) {
      return EventBookingTicketModel.fromRecord(record).toEntity();
    }).toList();
  }

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _pb
        .collection('event_bookings')
        .update(
          bookingId,
          body: {
            'payment_status': status,
            if (status == 'paid')
              'payment_date': DateTime.now().toIso8601String(),
          },
        );
  }

  /// Create manual booking
  Future<void> createManualBooking(Map<String, dynamic> data) async {
    await _pb.collection('event_bookings').create(body: data);
  }

  /// Get event tickets
  Future<List<EventTicket>> getEventTickets(String eventId) async {
    final result = await _pb
        .collection('event_tickets')
        .getList(filter: 'event = "$eventId"');

    return result.items.map((record) {
      return EventTicketModel.fromRecord(record).toEntity();
    }).toList();
  }
}
