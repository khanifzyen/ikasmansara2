import '../entities/event_ticket.dart';
import '../repositories/event_repository.dart';

class GetEventTickets {
  final EventRepository _repository;

  GetEventTickets(this._repository);

  Future<List<EventTicket>> call(String eventId) {
    return _repository.getEventTickets(eventId);
  }
}
