import 'package:ikasmansara_app/core/network/pocketbase_service.dart';
import 'package:ikasmansara_app/core/network/api_endpoints.dart';
import 'package:ikasmansara_app/features/donation/data/models/campaign_model.dart';

abstract class DonationRemoteDataSource {
  Future<List<CampaignModel>> getCampaigns({String? category});
  Future<CampaignModel> getCampaignDetail(String id);
}

class DonationRemoteDataSourceImpl implements DonationRemoteDataSource {
  final PocketBaseService _pbService;

  DonationRemoteDataSourceImpl(this._pbService);

  @override
  Future<List<CampaignModel>> getCampaigns({String? category}) async {
    final filter = category != null && category.isNotEmpty
        ? 'category = "$category"'
        : null;

    try {
      final records = await _pbService.pb
          .collection(ApiEndpoints.donations)
          .getList(filter: filter, sort: '-created');

      return records.items
          .map((record) => CampaignModel.fromRecord(record))
          .toList();
    } catch (e) {
      // Return empty list if collection not found (404)
      // This prevents "Data not found" error when feature is not yet set up on backend
      return [];
    }
  }

  @override
  Future<CampaignModel> getCampaignDetail(String id) async {
    final record = await _pbService.pb
        .collection(ApiEndpoints.donations)
        .getOne(id);
    return CampaignModel.fromRecord(record);
  }
}
