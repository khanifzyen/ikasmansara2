import 'package:equatable/equatable.dart';
import 'event_ticket_option.dart';

class EventTicket extends Equatable {
  final String id;
  final String eventId;
  final String name;
  final String description;
  final int price;
  final int quota;
  final int sold;
  final String? quotaStatus; // 'available', 'sold_out', 'limited'
  final List<EventTicketOption> options;
  final List<String> includes;

  const EventTicket({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.price,
    required this.quota,
    required this.sold,
    this.quotaStatus,
    this.options = const [],
    this.includes = const [],
  });

  @override
  List<Object?> get props => [
    id,
    eventId,
    name,
    description,
    price,
    quota,
    sold,
    quotaStatus,
    options,
    includes,
  ];
}
