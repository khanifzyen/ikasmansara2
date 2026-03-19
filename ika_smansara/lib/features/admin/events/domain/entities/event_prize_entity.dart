import 'package:equatable/equatable.dart';

class EventPrizeEntity extends Equatable {
  final String id;
  final String eventId;
  final String name;
  final int quantity;

  const EventPrizeEntity({
    required this.id,
    required this.eventId,
    required this.name,
    required this.quantity,
  });

  @override
  List<Object?> get props => [id, eventId, name, quantity];
}
