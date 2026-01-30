import '../entities/event_booking_ticket.dart';
import '../repositories/event_repository.dart';

class GetEventBookingTickets {
  final EventRepository repository;

  GetEventBookingTickets(this.repository);

  Future<List<EventBookingTicket>> call(String bookingId) {
    return repository.getBookingTickets(bookingId);
  }
}
