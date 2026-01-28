import '../entities/event.dart';
import '../entities/event_ticket.dart';
import '../entities/event_sub_event.dart';
import '../entities/event_sponsor.dart';
import '../entities/event_booking.dart';
import '../entities/event_booking_ticket.dart';

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
  Future<EventBooking> createBooking({
    required String eventId,
    required List<Map<String, dynamic>> metadata,
    required int totalPrice,
  });
  Future<List<EventBooking>> getUserBookings(String userId);
  Future<List<EventBookingTicket>> getBookingTickets(String bookingId);
  Future<void> cancelBooking(String id);
  Future<void> deleteBooking(String id);
}
