import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetEventDetail {
  final EventRepository _repository;

  GetEventDetail(this._repository);

  Future<Event> call(String id) {
    return _repository.getEventDetail(id);
  }
}
