import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

class JobEntity extends Equatable {
  final String id;
  final String collectionId;
  final String collectionName;
  final String company;
  final String title;
  final String description; // JSON/HTML content
  final String location;
  final String type; // Fulltime, Contract, Internship, Remote
  final String? salaryRange;
  final String? link;
  final bool isActive;
  final UserEntity? postedBy;
  final DateTime? created;
  final DateTime? updated;

  const JobEntity({
    required this.id,
    required this.collectionId,
    required this.collectionName,
    required this.company,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    this.salaryRange,
    this.link,
    this.isActive = true,
    this.postedBy,
    this.created,
    this.updated,
  });

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    company,
    title,
    description,
    location,
    type,
    salaryRange,
    link,
    isActive,
    postedBy,
    created,
    updated,
  ];
}
