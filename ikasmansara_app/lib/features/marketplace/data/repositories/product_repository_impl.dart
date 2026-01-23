import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductEntity>> getProducts({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    return await remoteDataSource.getProducts(
      category: category,
      query: query,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ProductEntity> getProductDetail(String id) async {
    return await remoteDataSource.getProductDetail(id);
  }

  @override
  Future<void> createProduct(ProductEntity product, dynamic imageFile) async {
    final body = {
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'seller_id': product.sellerId,
      'whatsapp': product.whatsapp,
      // 'images' are handled by files argument
    };

    List<dynamic> images = [];
    if (imageFile is List) {
      images = imageFile;
    } else if (imageFile != null) {
      images = [imageFile];
    }

    await remoteDataSource.createProduct(body, images);
  }
}
