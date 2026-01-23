import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:ikasmansara_app/core/network/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  });

  Future<ProductModel> getProductDetail(String id);
  Future<ProductModel> createProduct(
    Map<String, dynamic> body,
    List<dynamic> images,
  );
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final PocketBase pb;

  ProductRemoteDataSourceImpl(this.pb);

  @override
  Future<ProductModel> createProduct(
    Map<String, dynamic> body,
    List<dynamic> images,
  ) async {
    try {
      List<http.MultipartFile> files = [];
      for (var i = 0; i < images.length; i++) {
        var image = images[i];
        if (image is File) {
          files.add(await http.MultipartFile.fromPath('images', image.path));
        }
      }

      final record = await pb
          .collection(ApiEndpoints.products)
          .create(body: body, files: files);

      return ProductModel.fromRecord(record);
    } catch (e) {
      print("CREATE PRODUCT ERROR: $e");
      if (e is ClientException) {
        throw mapPocketBaseError(e);
      }
      throw AppException.unknown(message: e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    final filters = <String>[];

    // Filter by Category
    if (category != null && category.isNotEmpty && category != 'Semua') {
      filters.add('category = "$category"');
    }

    // Filter by Query (Name or Description)
    if (query != null && query.isNotEmpty) {
      filters.add('(name ~ "$query" || description ~ "$query")');
    }

    final filterString = filters.join(' && ');

    try {
      final result = await pb
          .collection(ApiEndpoints.products)
          .getList(
            page: page,
            perPage: limit,
            filter: filterString,
            sort: '-created',
            // expand: 'seller_id', // Expand seller relation
          );

      return result.items.map((r) => ProductModel.fromRecord(r)).toList();
    } catch (e) {
      // Graceful degradation if Collection doesn't exist yet
      if (e is ClientException && e.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  @override
  Future<ProductModel> getProductDetail(String id) async {
    final record = await pb
        .collection(ApiEndpoints.products)
        .getOne(id /*, expand: 'seller_id'*/);
    return ProductModel.fromRecord(record);
  }
}
