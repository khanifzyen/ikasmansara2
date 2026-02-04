import '../../domain/entities/event_booking_ticket.dart';
import 'package:pocketbase/pocketbase.dart';

class EventBookingTicketModel extends EventBookingTicket {
  const EventBookingTicketModel({
    required super.id,
    required super.bookingId,
    required super.eventId,
    required super.ticketName,
    required super.ticketCode,
    required super.userName,
    required super.userEmail,
    required super.options,
  });

  factory EventBookingTicketModel.fromRecord(RecordModel record) {
    // Handling expansion for ticket_type to get name
    final expandedTicket = record.get<List<RecordModel>>('expand.ticket_type');
    final ticketType = expandedTicket.isNotEmpty ? expandedTicket.first : null;
    final ticketName = ticketType?.getStringValue('name') ?? 'Unknown Ticket';

    // Handling expansion for booking.user to get user name and email
    final expandedBooking = record.get<List<RecordModel>>('expand.booking');
    final booking = expandedBooking.isNotEmpty ? expandedBooking.first : null;

    String userName = '';
    String userEmail = '';

    if (booking != null) {
      final expandedUser = booking.get<List<RecordModel>>('expand.user');
      final user = expandedUser.isNotEmpty ? expandedUser.first : null;
      if (user != null) {
        userName = user.getStringValue('name');
        userEmail = user.getStringValue('email');
      }
    }

    return EventBookingTicketModel(
      id: record.id,
      bookingId: record.getStringValue('booking'),
      eventId: record.getStringValue('event'),
      ticketName: ticketName,
      ticketCode: record.getStringValue('ticket_id'),
      userName: userName,
      userEmail: userEmail,
      options: record.data['selected_options'] ?? {},
    );
  }

  EventBookingTicket toEntity() {
    return EventBookingTicket(
      id: id,
      bookingId: bookingId,
      eventId: eventId,
      ticketName: ticketName,
      ticketCode: ticketCode,
      userName: userName,
      userEmail: userEmail,
      options: options,
    );
  }
}
