import '../repositories/event_repository.dart';
import '../entities/event.dart';

class GetEvents {
  final EventRepository _repository;

  GetEvents(this._repository);

  Future<List<Event>> call({int page = 1, int perPage = 20, String? category}) {
    return _repository.getEvents(
      page: page,
      perPage: perPage,
      category: category,
    );
  }
}
