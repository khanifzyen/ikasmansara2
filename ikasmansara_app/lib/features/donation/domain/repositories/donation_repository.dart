import 'package:ikasmansara_app/features/donation/domain/entities/campaign_entity.dart';

abstract class DonationRepository {
  /// Fetches a list of donation campaigns.
  /// [category] can be used to filter campaigns (optional).
  Future<List<CampaignEntity>> getCampaigns({String? category});

  /// Fetches the details of a specific campaign by [id].
  Future<CampaignEntity> getCampaignDetail(String id);
}
