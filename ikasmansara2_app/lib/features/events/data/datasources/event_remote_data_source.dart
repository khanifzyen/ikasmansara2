import 'package:flutter/foundation.dart';
import '../../../../core/network/pb_client.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<List<EventModel>> getEvents({
    int page = 1,
    int perPage = 20,
    String? category,
  });
  Future<EventModel> getEventDetail(String id);
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
}
