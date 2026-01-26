import '../../domain/entities/event.dart';
import '../../domain/entities/event_ticket.dart';
import '../../domain/entities/event_sub_event.dart';
import '../../domain/entities/event_sponsor.dart';
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

  @override
  Future<List<EventTicket>> getEventTickets(String eventId) async {
    final models = await _remoteDataSource.getEventTickets(eventId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<EventSubEvent>> getEventSubEvents(String eventId) async {
    final models = await _remoteDataSource.getEventSubEvents(eventId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<EventSponsor>> getEventSponsors(String eventId) async {
    final models = await _remoteDataSource.getEventSponsors(eventId);
    return models.map((m) => m.toEntity()).toList();
  }
}
