import '../../domain/entities/event_prize_entity.dart';

abstract class EventPrizeRepository {
  Future<List<EventPrizeEntity>> getPrizesByEvent(String eventId);
  Future<EventPrizeEntity> createPrize(
    EventPrizeEntity prize, {
    String? imagePath,
  });
  Future<EventPrizeEntity> updatePrize(
    EventPrizeEntity prize, {
    String? imagePath,
  });
  Future<void> deletePrize(String prizeId);
}
