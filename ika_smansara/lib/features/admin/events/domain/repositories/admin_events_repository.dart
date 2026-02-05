import '../../../../events/domain/entities/event.dart';

/// Repository interface for admin event management
abstract class AdminEventsRepository {
  /// Get all events with optional filter
  Future<List<Event>> getEvents({
    String? filter,
    int page = 1,
    int perPage = 20,
  });

  /// Get event by ID
  Future<Event> getEventById(String id);

  /// Create new event
  Future<void> createEvent(Map<String, dynamic> data);

  /// Update event
  Future<void> updateEvent(String eventId, Map<String, dynamic> data);

  /// Delete event
  Future<void> deleteEvent(String eventId);

  /// Update event status
  Future<void> updateEventStatus(String eventId, String status);
}
