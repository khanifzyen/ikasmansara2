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

  // Configuration fields
  final String code;
  final bool enableSponsorship;
  final bool enableDonation;
  final double? donationTarget;
  final String? donationDescription;
  final String bookingIdFormat;
  final String ticketIdFormat;

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
    required this.code,
    required this.enableSponsorship,
    required this.enableDonation,
    this.donationTarget,
    this.donationDescription,
    required this.bookingIdFormat,
    required this.ticketIdFormat,
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
    code,
    enableSponsorship,
    enableDonation,
    donationTarget,
    donationDescription,
    bookingIdFormat,
    ticketIdFormat,
  ];
}
