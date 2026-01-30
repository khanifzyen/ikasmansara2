import 'package:flutter/foundation.dart';
import '../../../../core/network/pb_client.dart';
import '../models/event_model.dart';
import '../models/event_ticket_model.dart';
import '../models/event_ticket_option_model.dart';
import '../models/event_sub_event_model.dart';
import '../models/event_sponsor_model.dart';
import '../models/event_booking_model.dart';
import '../models/event_booking_ticket_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents({
    int page = 1,
    int perPage = 20,
    String? category,
  });
  Future<EventModel> getEventDetail(String id);
  Future<List<EventTicketModel>> getEventTickets(String eventId);
  Future<List<EventTicketOptionModel>> getEventTicketOptions(String eventId);
  Future<List<EventSubEventModel>> getEventSubEvents(String eventId);
  Future<List<EventSponsorModel>> getEventSponsors(String eventId);
  Future<EventBookingModel> createBooking({
    required String eventId,
    required List<Map<String, dynamic>> metadata,
    required int totalPrice,
    required String paymentMethod,
  });
  Future<List<EventBookingModel>> getUserBookings(String userId);
  Future<List<EventBookingTicketModel>> getBookingTickets(String bookingId);
  Future<void> cancelBooking(String id);
  Future<void> deleteBooking(String id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final PBClient _pbClient;

  EventRemoteDataSourceImpl(this._pbClient);

  @override
  Future<List<EventModel>> getEvents({
    int page = 1,
    int perPage = 20,
    String? category,
  }) async {
    debugPrint(
      'DEBUG: Fetching events list (page: $page, perPage: $perPage)...',
    );
    const filter = 'status = "active"';
    try {
      final result = await _pbClient.pb
          .collection('events')
          .getList(page: page, perPage: perPage, filter: filter, sort: '-date');
      debugPrint(
        'DEBUG: Fetched ${result.items.length} events from PocketBase',
      );
      return result.items
          .map((record) => EventModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching events: $e');
      rethrow;
    }
  }

  @override
  Future<EventModel> getEventDetail(String id) async {
    debugPrint('DEBUG: Fetching event detail for id: $id...');
    try {
      final record = await _pbClient.pb.collection('events').getOne(id);
      debugPrint('DEBUG: Fetched event: ${record.id}');
      return EventModel.fromRecord(record);
    } catch (e) {
      debugPrint('DEBUG: Error fetching event detail: $e');
      rethrow;
    }
  }

  @override
  Future<List<EventTicketModel>> getEventTickets(String eventId) async {
    debugPrint('DEBUG: Fetching tickets for event: $eventId...');
    try {
      final result = await _pbClient.pb
          .collection('event_tickets')
          .getList(filter: 'event = "$eventId"');
      return result.items
          .map((record) => EventTicketModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching event tickets: $e');
      // Return empty list instead of throwing if collection doesn't exist yet
      return [];
    }
  }

  @override
  Future<List<EventSubEventModel>> getEventSubEvents(String eventId) async {
    debugPrint('DEBUG: Fetching sub-events for event: $eventId...');
    try {
      final result = await _pbClient.pb
          .collection('event_sub_events')
          .getList(filter: 'event = "$eventId"');
      return result.items
          .map((record) => EventSubEventModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching event sub-events: $e');
      return [];
    }
  }

  @override
  Future<List<EventSponsorModel>> getEventSponsors(String eventId) async {
    debugPrint('DEBUG: Fetching sponsors for event: $eventId...');
    try {
      final result = await _pbClient.pb
          .collection('event_sponsors')
          .getList(filter: 'event = "$eventId"');
      return result.items
          .map((record) => EventSponsorModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching event sponsors: $e');
      return [];
    }
  }

  @override
  Future<List<EventTicketOptionModel>> getEventTicketOptions(
    String eventId,
  ) async {
    debugPrint('DEBUG: Fetching ticket options for event: $eventId...');
    try {
      final result = await _pbClient.pb
          .collection('event_ticket_options')
          .getList(filter: 'ticket.event = "$eventId"');
      return result.items
          .map((record) => EventTicketOptionModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching ticket options: $e');
      return [];
    }
  }

  @override
  Future<EventBookingModel> createBooking({
    required String eventId,
    required List<Map<String, dynamic>> metadata,
    required int totalPrice,
    required String paymentMethod,
  }) async {
    try {
      final userId = _pbClient.pb.authStore.record?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final body = {
        'event': eventId,
        'user': userId,
        'metadata': metadata,
        'total_price': totalPrice,
        'payment_status': 'pending',
        'payment_method': paymentMethod,
      };

      final record = await _pbClient.pb
          .collection('event_bookings')
          .create(body: body);

      return EventBookingModel.fromRecord(record);
    } catch (e) {
      debugPrint('DEBUG: Error creating booking: $e');
      rethrow;
    }
  }

  @override
  Future<List<EventBookingModel>> getUserBookings(String userId) async {
    debugPrint('DEBUG: Fetching bookings for user: $userId...');
    try {
      final result = await _pbClient.pb
          .collection('event_bookings')
          .getList(
            filter: 'user = "$userId"',
            sort: '-created',
            expand: 'event',
          );
      return result.items
          .map((record) => EventBookingModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching user bookings: $e');
      return [];
    }
  }

  @override
  Future<List<EventBookingTicketModel>> getBookingTickets(
    String bookingId,
  ) async {
    debugPrint('DEBUG: Fetching tickets for booking: $bookingId...');
    try {
      final result = await _pbClient.pb
          .collection('event_booking_tickets')
          .getList(filter: 'booking = "$bookingId"', expand: 'ticket_type');
      return result.items
          .map((record) => EventBookingTicketModel.fromRecord(record))
          .toList();
    } catch (e) {
      debugPrint('DEBUG: Error fetching booking tickets: $e');
      return [];
    }
  }

  @override
  Future<void> cancelBooking(String id) async {
    try {
      await _pbClient.pb
          .collection('event_bookings')
          .update(id, body: {'payment_status': 'cancelled'});
    } catch (e) {
      debugPrint('DEBUG: Error cancelling booking: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBooking(String id) async {
    try {
      await _pbClient.pb.collection('event_bookings').delete(id);
    } catch (e) {
      debugPrint('DEBUG: Error deleting booking: $e');
      rethrow;
    }
  }
}
