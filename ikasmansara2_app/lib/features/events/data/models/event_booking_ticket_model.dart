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
    final expanded = record.get<List<RecordModel>>('expand.ticket_type');
    final ticketType = expanded.isNotEmpty ? expanded.first : null;
    final ticketName = ticketType?.getStringValue('name') ?? 'Unknown Ticket';

    return EventBookingTicketModel(
      id: record.id,
      bookingId: record.getStringValue('booking'),
      eventId: record.getStringValue('event'),
      ticketName: ticketName,
      ticketCode: record.getStringValue('ticket_code'),
      userName: record.getStringValue('user_name'),
      userEmail: record.getStringValue('user_email'),
      options: record.data['options'] ?? {},
    );
  }
}
