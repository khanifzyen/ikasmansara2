import '../entities/event.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents({
    int page = 1,
    int perPage = 20,
    String? category,
  });
  Future<Event> getEventDetail(String id);
}
