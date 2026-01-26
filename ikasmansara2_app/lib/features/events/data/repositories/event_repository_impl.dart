import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _remoteDataSource;

  EventRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Event>> getEvents({
    int page = 1,
    int perPage = 20,
    String? category,
  }) async {
    final models = await _remoteDataSource.getEvents(
      page: page,
      perPage: perPage,
      category: category,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Event> getEventDetail(String id) async {
    final model = await _remoteDataSource.getEventDetail(id);
    return model.toEntity();
  }
}
