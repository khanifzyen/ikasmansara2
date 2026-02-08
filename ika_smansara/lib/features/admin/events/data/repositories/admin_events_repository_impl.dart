import '../../domain/repositories/admin_events_repository.dart';
import '../datasources/admin_events_remote_data_source.dart';
import '../../../../events/domain/entities/event.dart';

class AdminEventsRepositoryImpl implements AdminEventsRepository {
  final AdminEventsRemoteDataSource _dataSource;

  AdminEventsRepositoryImpl(this._dataSource);

  @override
  Future<List<Event>> getEvents({
    String? filter,
    int page = 1,
    int perPage = 20,
  }) {
    return _dataSource.getEvents(filter: filter, page: page, perPage: perPage);
  }

  @override
  Future<Event> getEventById(String id) {
    return _dataSource.getEventById(id);
  }

  @override
  Future<Event> createEvent(Map<String, dynamic> data) {
    return _dataSource.createEvent(data);
  }

  @override
  Future<void> createEventTicket(Map<String, dynamic> data) {
    return _dataSource.createEventTicket(data);
  }

  @override
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) {
    return _dataSource.updateEvent(eventId, data);
  }

  @override
  Future<void> deleteEvent(String eventId) {
    return _dataSource.deleteEvent(eventId);
  }

  @override
  Future<void> updateEventStatus(String eventId, String status) {
    return _dataSource.updateEventStatus(eventId, status);
  }
}
