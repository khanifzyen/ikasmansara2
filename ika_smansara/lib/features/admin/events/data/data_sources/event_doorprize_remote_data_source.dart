import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../models/event_prize_model.dart';
import '../models/event_winner_model.dart';

class EventDoorprizeRemoteDataSource {
  final PocketBase pb;

  EventDoorprizeRemoteDataSource(this.pb);

  // Prizes
  Future<List<EventPrizeModel>> getPrizesByEvent(String eventId) async {
    final records = await pb
        .collection('event_prizes')
        .getFullList(filter: 'event = "$eventId"', sort: '-created');
    return records.map((e) => EventPrizeModel.fromJson(e.toJson())).toList();
  }

  Future<EventPrizeModel> createPrize(
    EventPrizeModel prize, {
    String? imagePath,
  }) async {
    final body = prize.toJson()
      ..remove('id')
      ..remove('created')
      ..remove('updated');

    late RecordModel record;
    if (imagePath != null) {
      record = await pb
          .collection('event_prizes')
          .create(
            body: body,
            files: [await http.MultipartFile.fromPath('image', imagePath)],
          );
    } else {
      record = await pb.collection('event_prizes').create(body: body);
    }

    return EventPrizeModel.fromJson(record.toJson());
  }

  Future<EventPrizeModel> updatePrize(
    String id,
    EventPrizeModel prize, {
    String? imagePath,
  }) async {
    final body = prize.toJson()
      ..remove('id')
      ..remove('created')
      ..remove('updated');

    late RecordModel record;
    if (imagePath != null) {
      record = await pb
          .collection('event_prizes')
          .update(
            id,
            body: body,
            files: [await http.MultipartFile.fromPath('image', imagePath)],
          );
    } else {
      record = await pb.collection('event_prizes').update(id, body: body);
    }
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
          expand:
              'prize,booking_ticket,booking_ticket.booking,booking_ticket.booking.user',
        );
    // Note: We might need a separate complex model if we want to show user details,
    // but for the basic entity, EventWinnerModel is enough.
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

  Future<void> deleteWinner(String id) async {
    await pb.collection('event_winners').delete(id);
  }
}
