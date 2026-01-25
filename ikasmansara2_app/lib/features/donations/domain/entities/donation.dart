import 'package:equatable/equatable.dart';

class Donation extends Equatable {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double collectedAmount;
  final DateTime deadline;
  final String banner;
  final String organizer;
  final String category;
  final String priority;
  final String status;
  final int donorCount;
  final String createdBy;

  const Donation({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.collectedAmount,
    required this.deadline,
    required this.banner,
    required this.organizer,
    required this.category,
    required this.priority,
    required this.status,
    required this.donorCount,
    required this.createdBy,
  });

  bool get isUrgent => priority == 'urgent';
  double get progress => (collectedAmount / targetAmount).clamp(0.0, 1.0);
  int get percentage => (progress * 100).toInt();

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    targetAmount,
    collectedAmount,
    deadline,
    banner,
    organizer,
    category,
    priority,
    status,
    donorCount,
    createdBy,
  ];
}
