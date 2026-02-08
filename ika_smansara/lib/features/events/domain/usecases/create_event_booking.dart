import '../entities/event_booking.dart';
import '../repositories/event_repository.dart';

class CreateEventBooking {
  final EventRepository repository;

  CreateEventBooking(this.repository);

  Future<EventBooking> call({
    required String eventId,
    required List<Map<String, dynamic>> metadata,
    required int subtotal,
    required int serviceFee,
    required int totalPrice,
    required String paymentMethod,
    String? registrationChannel,
  }) {
    return repository.createBooking(
      eventId: eventId,
      metadata: metadata,
      subtotal: subtotal,
      serviceFee: serviceFee,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      registrationChannel: registrationChannel,
    );
  }
}
