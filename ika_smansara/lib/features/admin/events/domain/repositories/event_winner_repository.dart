import '../../domain/entities/event_winner_entity.dart';

abstract class EventWinnerRepository {
  Future<List<EventWinnerEntity>> getWinnersByEvent(String eventId);
  Future<EventWinnerEntity> createWinner(EventWinnerEntity winner);
}
