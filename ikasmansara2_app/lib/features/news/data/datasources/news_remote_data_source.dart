import 'package:injectable/injectable.dart';

import '../../../../core/network/pb_client.dart';
import '../models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getNewsList({
    int page = 1,
    int perPage = 10,
    String? category,
  });

  Future<NewsModel> getNewsDetail(String id);
}

@LazySingleton(as: NewsRemoteDataSource)
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final PBClient _pbClient;

  NewsRemoteDataSourceImpl(this._pbClient);

  @override
  Future<List<NewsModel>> getNewsList({
    int page = 1,
    int perPage = 10,
    String? category,
  }) async {
    String filter = 'status = "published"';
    if (category != null && category != 'Semua' && category.isNotEmpty) {
      filter += ' && category = "$category"';
    }

    final result = await _pbClient.pb
        .collection('news')
        .getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: '-publish_date',
          expand: 'author',
        );

    return result.items.map((record) => NewsModel.fromRecord(record)).toList();
  }

  @override
  Future<NewsModel> getNewsDetail(String id) async {
    final record = await _pbClient.pb
        .collection('news')
        .getOne(id, expand: 'author');
    return NewsModel.fromRecord(record);
  }
}
