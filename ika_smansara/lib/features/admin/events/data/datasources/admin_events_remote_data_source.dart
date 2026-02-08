import 'package:http/http.dart' as http;
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
  Future<Event> createEvent(Map<String, dynamic> data) async {
    // Separate files from body if using specific creates,
    // but PocketBase Dart SDK `create` with `body` handles MultipartFile if passing http.MultipartFile
    // However, explicit `files` param is safer if we want to be strict, but sticking to body for consistency with update
    // as long as the SDK supports it.
    // Checking the SDK, `create` takes `body` and `files`.
    // If we pass `MultipartFile` in `body`, the SDK *might* not extract it to `files` automatically depending on version.
    // Let's use `files` param explicitly if there's a file.

    final List<http.MultipartFile> files = [];
    final Map<String, dynamic> body = Map.from(data);

    // Ensure created_by is set
    if (!body.containsKey('created_by') && _pb.authStore.isValid) {
      body['created_by'] = _pb.authStore.model.id;
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
          filter: 'event = "$eventId" && payment_status = "paid"',
        );
    return result.totalItems;
  }
}
