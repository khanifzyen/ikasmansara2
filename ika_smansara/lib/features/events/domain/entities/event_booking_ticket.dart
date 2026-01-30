import 'package:equatable/equatable.dart';

class EventBookingTicket extends Equatable {
  final String id;
  final String bookingId;
  final String eventId;
  final String ticketName; // From expanded 'ticket_type'
  final String ticketCode; // The unique code per ticket (e.g. TIX-001)
  final String userName; // For display
  final String userEmail;
  final Map<String, dynamic> options; // Selected options

  const EventBookingTicket({
    required this.id,
    required this.bookingId,
    required this.eventId,
    required this.ticketName,
    required this.ticketCode,
    required this.userName,
    required this.userEmail,
    required this.options,
  });

  @override
  List<Object?> get props => [
    id,
    bookingId,
    eventId,
    ticketName,
    ticketCode,
    userName,
    userEmail,
    options,
  ];
}
