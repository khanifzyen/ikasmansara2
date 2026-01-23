import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<ProductEntity>> call({
    String? category,
    String? query,
    int page = 1,
  }) {
    return repository.getProducts(category: category, query: query, page: page);
  }
}
