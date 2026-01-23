import 'package:equatable/equatable.dart';

class CampaignEntity extends Equatable {
  final String id;
  final String title;
  final String description; // HTML content
  final double targetAmount;
  final double collectedAmount;
  final String? imageUrl;
  final DateTime deadline;
  final bool isUrgent;
  final String organizer;

  const CampaignEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.collectedAmount,
    this.imageUrl,
    required this.deadline,
    required this.isUrgent,
    required this.organizer,
  });

  /// Calculates the progress percentage (0.0 to 1.0)
  double get progress {
    if (targetAmount <= 0) return 0.0;
    final p = collectedAmount / targetAmount;
    return p > 1.0 ? 1.0 : p;
  }

  /// Calculates how many days are left until the deadline
  int get daysLeft {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.isNegative ? 0 : difference.inDays;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    targetAmount,
    collectedAmount,
    imageUrl,
    deadline,
    isUrgent,
    organizer,
  ];
}
