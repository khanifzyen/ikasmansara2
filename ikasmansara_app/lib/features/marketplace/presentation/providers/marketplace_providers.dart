import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/core/network/pocketbase_service.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/contact_seller.dart';

// Data Source
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final pb = ref.watch(pocketBaseServiceProvider);
  return ProductRemoteDataSourceImpl(pb);
});

// Repository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource);
});

// Use Cases
final getProductsProvider = Provider<GetProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProducts(repository);
});

final contactSellerProvider = Provider<ContactSeller>((ref) {
  return ContactSeller();
});
