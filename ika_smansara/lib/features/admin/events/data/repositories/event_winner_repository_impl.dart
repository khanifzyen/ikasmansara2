import '../../domain/entities/event_winner_entity.dart';
import '../../domain/repositories/event_winner_repository.dart';
import '../data_sources/event_doorprize_remote_data_source.dart';
import '../models/event_winner_model.dart';

class EventWinnerRepositoryImpl implements EventWinnerRepository {
  final EventDoorprizeRemoteDataSource remoteDataSource;

  EventWinnerRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<EventWinnerEntity>> getWinnersByEvent(String eventId) async {
    final models = await remoteDataSource.getWinnersByEvent(eventId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<EventWinnerEntity> createWinner(EventWinnerEntity winner) async {
    final model = EventWinnerModel.fromEntity(winner);
    final result = await remoteDataSource.createWinner(model);
    return result.toEntity();
  }
}
