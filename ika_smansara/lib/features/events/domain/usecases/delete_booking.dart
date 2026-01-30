import '../repositories/event_repository.dart';

class DeleteBooking {
  final EventRepository repository;

  DeleteBooking(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteBooking(id);
  }
}
