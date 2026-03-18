import 'package:pocketbase/pocketbase.dart';

import '../models/event_winner_model.dart';

class EventDoorprizeRemoteDataSource {
  final PocketBase pb;

  EventDoorprizeRemoteDataSource(this.pb);

  // Winners
  Future<List<EventWinnerModel>> getWinnersByEvent(String eventId) async {
    final records = await pb
        .collection('event_winners')
        .getFullList(
          filter: 'event = "$eventId"',
          sort: '-created',
          expand: 'booking_ticket,booking_ticket.booking,booking_ticket.booking.user',
        );
    return records.map((e) => EventWinnerModel.fromRecord(e)).toList();
  }

  Future<EventWinnerModel> createWinner(EventWinnerModel winner) async {
    final body = winner.toJson()
      ..remove('id')
      ..remove('created')
      ..remove('updated');

    final record = await pb.collection('event_winners').create(body: body);
    return EventWinnerModel.fromJson(record.toJson());
  }

  Future<void> updateWinnerStatus(String id, String status) async {
    await pb.collection('event_winners').update(id, body: {'status': status});
  }

  Future<void> deleteWinner(String id) async {
    await pb.collection('event_winners').delete(id);
  }
}
