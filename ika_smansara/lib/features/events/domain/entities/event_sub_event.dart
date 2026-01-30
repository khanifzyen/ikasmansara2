import 'package:equatable/equatable.dart';

class EventSubEvent extends Equatable {
  final String id;
  final String eventId;
  final String title;
  final String description;
  final int quota;
  final int registered;
  final String? image;

  const EventSubEvent({
    required this.id,
    required this.eventId,
    required this.title,
    required this.description,
    required this.quota,
    required this.registered,
    this.image,
  });

  @override
  List<Object?> get props => [
    id,
    eventId,
    title,
    description,
    quota,
    registered,
    image,
  ];
}
