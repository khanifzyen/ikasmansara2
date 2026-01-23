import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  });

  Future<ProductEntity> getProductDetail(String id);

  Future<void> createProduct(
    ProductEntity product,
    dynamic imageFile,
  ); // Simplified signature
}
