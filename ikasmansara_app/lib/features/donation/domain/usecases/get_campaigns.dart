import 'package:ikasmansara_app/features/donation/domain/entities/campaign_entity.dart';
import 'package:ikasmansara_app/features/donation/domain/repositories/donation_repository.dart';

class GetCampaigns {
  final DonationRepository repository;

  GetCampaigns(this.repository);

  Future<List<CampaignEntity>> call({String? category}) {
    return repository.getCampaigns(category: category);
  }
}
