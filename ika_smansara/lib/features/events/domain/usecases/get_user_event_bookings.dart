import '../entities/event_booking.dart';
import '../repositories/event_repository.dart';

class GetUserEventBookings {
  final EventRepository repository;

  GetUserEventBookings(this.repository);

  Future<List<EventBooking>> call(String userId) {
    return repository.getUserBookings(userId);
  }
}
