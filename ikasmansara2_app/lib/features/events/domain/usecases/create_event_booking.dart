import '../entities/event_booking.dart';
import '../repositories/event_repository.dart';

class CreateEventBooking {
  final EventRepository repository;

  CreateEventBooking(this.repository);

  Future<EventBooking> call({
    required String eventId,
    required List<Map<String, dynamic>> metadata,
    required int totalPrice,
  }) {
    return repository.createBooking(
      eventId: eventId,
      metadata: metadata,
      totalPrice: totalPrice,
    );
  }
}
