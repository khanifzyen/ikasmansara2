import '../../domain/entities/event_prize_entity.dart';
import '../../domain/repositories/event_prize_repository.dart';
import '../data_sources/event_doorprize_remote_data_source.dart';
import '../models/event_prize_model.dart';

class EventPrizeRepositoryImpl implements EventPrizeRepository {
  final EventDoorprizeRemoteDataSource remoteDataSource;

  EventPrizeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<EventPrizeEntity>> getPrizesByEvent(String eventId) async {
    final models = await remoteDataSource.getPrizesByEvent(eventId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<EventPrizeEntity> createPrize(
    EventPrizeEntity prize, {
    String? imagePath,
  }) async {
    final model = EventPrizeModel.fromEntity(prize);
    final result = await remoteDataSource.createPrize(
      model,
      imagePath: imagePath,
    );
    return result.toEntity();
  }

  @override
  Future<EventPrizeEntity> updatePrize(
    EventPrizeEntity prize, {
    String? imagePath,
  }) async {
    final model = EventPrizeModel.fromEntity(prize);
    final result = await remoteDataSource.updatePrize(
      prize.id,
      model,
      imagePath: imagePath,
    );
    return result.toEntity();
  }

  @override
  Future<void> deletePrize(String prizeId) async {
    await remoteDataSource.deletePrize(prizeId);
  }
}
