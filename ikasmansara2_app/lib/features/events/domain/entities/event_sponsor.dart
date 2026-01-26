import 'package:equatable/equatable.dart';

class EventSponsor extends Equatable {
  final String id;
  final String eventId;
  final String name;
  final String type; // 'platinum', 'gold', 'silver', etc.
  final int price;
  final List<String> benefits;

  const EventSponsor({
    required this.id,
    required this.eventId,
    required this.name,
    required this.type,
    required this.price,
    required this.benefits,
  });

  @override
  List<Object?> get props => [id, eventId, name, type, price, benefits];
}
