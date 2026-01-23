import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/product_entity.dart';
import '../../../auth/data/models/user_model.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    required super.images,
    required super.whatsapp,
    required super.sellerId,
    super.seller,
    required super.created,
  });

  factory ProductModel.fromRecord(RecordModel record) {
    // Check if seller is expanded
    UserModel? sellerModel;

    // Attempt to access expanded seller safely
    try {
      final expandedSeller = record.expand['seller_id'];
      if (expandedSeller != null && expandedSeller.isNotEmpty) {
        sellerModel = UserModel.fromRecord(expandedSeller.first);
      }
    } catch (_) {
      // Fallback or ignore if expand structure is different
    }

    return ProductModel(
      id: record.id,
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      price: record.getDoubleValue('price'),
      category: record.getStringValue('category'),
      images: record.getListValue<String>('images'),
      whatsapp: record.getStringValue('whatsapp'),
      sellerId: record.getStringValue('seller_id'),
      seller: sellerModel,
      created: DateTime.tryParse(record.created) ?? DateTime.now(),
    );
  }

  /// Helper to get full image URL
  String getImageUrl(String baseUrl, String filename) {
    return '$baseUrl/api/files/products/$id/$filename';
  }
}
