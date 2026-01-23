import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final String whatsapp;
  final String sellerId;
  final UserEntity? seller; // Optional, resolved if needed
  final DateTime created;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.whatsapp,
    required this.sellerId,
    this.seller,
    required this.created,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    category,
    images,
    whatsapp,
    sellerId,
    seller,
    created,
  ];

  String get firstImage => images.isNotEmpty ? images.first : '';
}
