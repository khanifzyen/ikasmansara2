import 'package:ikasmansara_app/core/network/pocketbase_service.dart';
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

    final records = await _pbService.pb
        .collection('campaigns')
        .getList(filter: filter, sort: '-created');

    return records.items
        .map((record) => CampaignModel.fromRecord(record))
        .toList();
  }

  @override
  Future<CampaignModel> getCampaignDetail(String id) async {
    final record = await _pbService.pb.collection('campaigns').getOne(id);
    return CampaignModel.fromRecord(record);
  }
}
