import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String? banner;
  final String status;
  final DateTime created;
  final DateTime updated;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.banner,
    required this.status,
    required this.created,
    required this.updated,
  });

  bool get isRegistrationOpen => status == 'active';

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    date,
    time,
    location,
    banner,
    status,
    created,
    updated,
  ];
}
