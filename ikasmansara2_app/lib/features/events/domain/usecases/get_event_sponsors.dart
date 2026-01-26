import '../entities/event_sponsor.dart';
import '../repositories/event_repository.dart';

class GetEventSponsors {
  final EventRepository _repository;

  GetEventSponsors(this._repository);

  Future<List<EventSponsor>> call(String eventId) {
    return _repository.getEventSponsors(eventId);
  }
}
