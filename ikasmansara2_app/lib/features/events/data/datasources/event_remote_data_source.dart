import 'package:flutter/foundation.dart';
import '../../../../core/network/pb_client.dart';
import '../models/event_model.dart';
import '../models/event_ticket_model.dart';
import '../models/event_sub_event_model.dart';
import '../models/event_sponsor_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents({
    int page = 1,
    int perPage = 20,
    String? category,
  });
  Future<EventModel> getEventDetail(String id);
  Future<List<EventTicketModel>> getEventTickets(String eventId);
  Future<List<EventSubEventModel>> getEventSubEvents(String eventId);
  Future<List<EventSponsorModel>> getEventSponsors(String eventId);
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
}
