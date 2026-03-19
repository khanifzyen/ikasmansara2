import 'package:pocketbase/pocketbase.dart';

import '../models/event_winner_model.dart';
import '../models/event_prize_model.dart';

class EventDoorprizeRemoteDataSource {
  final PocketBase pb;

  EventDoorprizeRemoteDataSource(this.pb);

  // Prizes
  Future<List<EventPrizeModel>> getPrizes(String eventId) async {
    final records = await pb.collection('event_prizes').getFullList(
          filter: 'event = "$eventId"',
          sort: 'name',
        );
    return records.map((e) => EventPrizeModel.fromRecord(e)).toList();
  }

  Future<EventPrizeModel> createPrize(EventPrizeModel prize) async {
    final body = prize.toJson()..remove('id');
    final record = await pb.collection('event_prizes').create(body: body);
    return EventPrizeModel.fromJson(record.toJson());
  }

  Future<EventPrizeModel> updatePrize(String id, EventPrizeModel prize) async {
    final body = prize.toJson()..remove('id');
    final record = await pb.collection('event_prizes').update(id, body: body);
    return EventPrizeModel.fromJson(record.toJson());
  }

  Future<void> deletePrize(String id) async {
    await pb.collection('event_prizes').delete(id);
  }

  // Winners
  Future<List<EventWinnerModel>> getWinnersByEvent(String eventId) async {
    final records = await pb
        .collection('event_winners')
        .getFullList(
          filter: 'event = "$eventId"',
          sort: '-created',
          expand: 'prize,booking_ticket,booking_ticket.booking,booking_ticket.booking.user',
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
