import '../../domain/repositories/admin_events_repository.dart';
import '../datasources/admin_events_remote_data_source.dart';
import '../../../../events/domain/entities/event.dart';
import '../../../../events/domain/entities/event_booking.dart';
import '../../../../events/domain/entities/event_booking_ticket.dart';
import '../../../../events/domain/entities/event_ticket.dart';

class AdminEventsRepositoryImpl implements AdminEventsRepository {
  final AdminEventsRemoteDataSource _dataSource;

  AdminEventsRepositoryImpl(this._dataSource);

  @override
  Future<List<Event>> getEvents({
    String? filter,
    int page = 1,
    int perPage = 20,
  }) {
    return _dataSource.getEvents(filter: filter, page: page, perPage: perPage);
  }

  @override
  Future<Event> getEventById(String id) {
    return _dataSource.getEventById(id);
  }

  @override
  Future<Event> createEvent(Map<String, dynamic> data) {
    return _dataSource.createEvent(data);
  }

  @override
  Future<void> createEventTicket(Map<String, dynamic> data) {
    return _dataSource.createEventTicket(data);
  }

  @override
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) {
    return _dataSource.updateEvent(eventId, data);
  }

  @override
  Future<void> deleteEvent(String eventId) {
    return _dataSource.deleteEvent(eventId);
  }

  @override
  Future<void> updateEventStatus(String eventId, String status) {
    return _dataSource.updateEventStatus(eventId, status);
  }

  @override
  Future<List<EventBooking>> getEventBookings(String eventId) {
    return _dataSource.getEventBookings(eventId);
  }

  @override
  Future<List<EventBookingTicket>> getEventBookingTickets(String bookingId) {
    return _dataSource.getEventBookingTickets(bookingId);
  }

  @override
  Future<void> updateBookingStatus(String bookingId, String status) {
    return _dataSource.updateBookingStatus(bookingId, status);
  }

  @override
  Future<void> createManualBooking(Map<String, dynamic> data) {
    return _dataSource.createManualBooking(data);
  }

  @override
  Future<List<EventTicket>> getEventTickets(String eventId) {
    return _dataSource.getEventTickets(eventId);
  }

  @override
  Future<Map<String, dynamic>> getEventStats(String eventId) {
    return _dataSource.getEventStats(eventId);
  }
}
