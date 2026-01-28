import '../../domain/entities/event.dart';
import '../../domain/entities/event_ticket.dart';
import '../../domain/entities/event_sub_event.dart';
import '../../domain/entities/event_sponsor.dart';
import '../../domain/entities/event_booking.dart';
import '../../domain/entities/event_booking_ticket.dart';
import '../../domain/repositories/event_repository.dart';

import '../datasources/event_remote_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _remoteDataSource;

  EventRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Event>> getEvents({
    int page = 1,
    int perPage = 20,
    String? category,
  }) async {
    final models = await _remoteDataSource.getEvents(
      page: page,
      perPage: perPage,
      category: category,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Event> getEventDetail(String id) async {
    final model = await _remoteDataSource.getEventDetail(id);
    return model.toEntity();
  }

  @override
  Future<List<EventTicket>> getEventTickets(String eventId) async {
    final tickets = await _remoteDataSource.getEventTickets(eventId);
    final options = await _remoteDataSource.getEventTicketOptions(eventId);

    return tickets.map((ticketModel) {
      final ticketOptions = options
          .where((option) => option.ticketId == ticketModel.id)
          .map((m) => m.toEntity())
          .toList();
      return ticketModel.toEntity(options: ticketOptions);
    }).toList();
  }

  @override
  Future<List<EventSubEvent>> getEventSubEvents(String eventId) async {
    final models = await _remoteDataSource.getEventSubEvents(eventId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<EventSponsor>> getEventSponsors(String eventId) async {
    final models = await _remoteDataSource.getEventSponsors(eventId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<EventBooking> createBooking({
    required String eventId,
    required List<Map<String, dynamic>> metadata,
    required int totalPrice,
  }) async {
    return await _remoteDataSource.createBooking(
      eventId: eventId,
      metadata: metadata,
      totalPrice: totalPrice,
    );
  }

  @override
  Future<List<EventBooking>> getUserBookings(String userId) async {
    return await _remoteDataSource.getUserBookings(userId);
  }

  @override
  Future<List<EventBookingTicket>> getBookingTickets(String bookingId) async {
    return await _remoteDataSource.getBookingTickets(bookingId);
  }

  @override
  Future<void> cancelBooking(String id) async {
    await _remoteDataSource.cancelBooking(id);
  }

  @override
  Future<void> deleteBooking(String id) async {
    await _remoteDataSource.deleteBooking(id);
  }
}
