import 'package:pocketbase/pocketbase.dart';
import '../../../../../core/network/pb_client.dart';
import '../../../../events/data/models/event_model.dart';
import '../../../../events/domain/entities/event.dart';

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
  Future<void> createEvent(Map<String, dynamic> data) async {
    await _pb.collection('events').create(body: data);
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
          filter: 'event = "$eventId" && payment_status = "paid"',
        );
    return result.totalItems;
  }
}
