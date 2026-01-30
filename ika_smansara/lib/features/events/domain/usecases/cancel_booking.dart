import '../repositories/event_repository.dart';

class CancelBooking {
  final EventRepository repository;

  CancelBooking(this.repository);

  Future<void> call(String id) async {
    return await repository.cancelBooking(id);
  }
}
