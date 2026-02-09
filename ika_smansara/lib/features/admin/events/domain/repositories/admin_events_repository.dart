import '../../../../events/domain/entities/event.dart';
import '../../../../events/domain/entities/event_booking.dart';
import '../../../../events/domain/entities/event_booking_ticket.dart';
import '../../../../events/domain/entities/event_ticket.dart';

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
  Future<Event> createEvent(Map<String, dynamic> data);

  /// Create event ticket
  Future<void> createEventTicket(Map<String, dynamic> data);

  /// Update event
  Future<void> updateEvent(String eventId, Map<String, dynamic> data);

  /// Delete event
  Future<void> deleteEvent(String eventId);

  /// Update event status
  Future<void> updateEventStatus(String eventId, String status);

  /// Get event bookings (participants)
  Future<List<EventBooking>> getEventBookings(String eventId);

  /// Get specific booking tickets
  Future<List<EventBookingTicket>> getEventBookingTickets(String bookingId);

  /// Update booking status
  Future<void> updateBookingStatus(String bookingId, String status);

  /// Create manual booking
  Future<void> createManualBooking(Map<String, dynamic> data);

  /// Get event tickets
  Future<List<EventTicket>> getEventTickets(String eventId);

  /// Get event statistics
  Future<Map<String, dynamic>> getEventStats(String eventId);
}
