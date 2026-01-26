import '../entities/event.dart';
import '../entities/event_ticket.dart';
import '../entities/event_sub_event.dart';
import '../entities/event_sponsor.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents({
    int page = 1,
    int perPage = 20,
    String? category,
  });
  Future<Event> getEventDetail(String id);
  Future<List<EventTicket>> getEventTickets(String eventId);
  Future<List<EventSubEvent>> getEventSubEvents(String eventId);
  Future<List<EventSponsor>> getEventSponsors(String eventId);
}
