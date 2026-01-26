import '../entities/event_sub_event.dart';
import '../repositories/event_repository.dart';

class GetEventSubEvents {
  final EventRepository _repository;

  GetEventSubEvents(this._repository);

  Future<List<EventSubEvent>> call(String eventId) {
    return _repository.getEventSubEvents(eventId);
  }
}
