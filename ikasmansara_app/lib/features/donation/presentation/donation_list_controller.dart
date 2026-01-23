import 'package:ikasmansara_app/features/donation/domain/entities/campaign_entity.dart';
import 'package:ikasmansara_app/features/donation/presentation/providers/donation_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'donation_list_controller.g.dart';

@riverpod
class DonationListController extends _$DonationListController {
  @override
  FutureOr<List<CampaignEntity>> build() {
    return _fetchCampaigns();
  }

  Future<List<CampaignEntity>> _fetchCampaigns() async {
    final getCampaigns = ref.read(getCampaignsProvider);
    return await getCampaigns();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCampaigns());
  }
}
