import 'package:pocketbase/pocketbase.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getNews({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  });

  Future<NewsModel> getNewsDetail(String id);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final PocketBase pb;

  NewsRemoteDataSourceImpl(this.pb);

  @override
  Future<List<NewsModel>> getNews({
    String? category,
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    final filters = <String>[];

    if (category != null && category.isNotEmpty && category != 'Semua') {
      filters.add('category = "$category"');
    }

    if (query != null && query.isNotEmpty) {
      filters.add('title ~ "$query"');
    }

    final filterString = filters.join(' && ');

    try {
      final result = await pb
          .collection(ApiEndpoints.news)
          .getList(
            page: page,
            perPage: limit,
            filter: filterString,
            sort: '-created',
            expand: 'author_id',
          );

      return result.items.map((r) => NewsModel.fromRecord(r)).toList();
    } catch (e) {
      if (e is ClientException) {
        if (e.statusCode == 404) return [];
        throw mapPocketBaseError(e);
      }
      throw AppException.unknown(message: e.toString());
    }
  }

  @override
  Future<NewsModel> getNewsDetail(String id) async {
    try {
      final record = await pb
          .collection(ApiEndpoints.news)
          .getOne(id, expand: 'author_id');
      return NewsModel.fromRecord(record);
    } catch (e) {
      if (e is ClientException) {
        throw mapPocketBaseError(e);
      }
      throw AppException.unknown(message: e.toString());
    }
  }
}
