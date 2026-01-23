import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/core/network/providers.dart';
import 'package:ikasmansara_app/features/donation/data/datasources/donation_remote_data_source.dart';
import 'package:ikasmansara_app/features/donation/data/repositories/donation_repository_impl.dart';
import 'package:ikasmansara_app/features/donation/domain/entities/campaign_entity.dart';
import 'package:ikasmansara_app/features/donation/domain/repositories/donation_repository.dart';
import 'package:ikasmansara_app/features/donation/domain/usecases/get_campaigns.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'donation_providers.g.dart';

// Data Source
@riverpod
DonationRemoteDataSource donationRemoteDataSource(Ref ref) {
  final pbService = ref.watch(pocketBaseServiceProvider);
  return DonationRemoteDataSourceImpl(pbService);
}

// Repository
@riverpod
DonationRepository donationRepository(Ref ref) {
  final dataSource = ref.watch(donationRemoteDataSourceProvider);
  return DonationRepositoryImpl(dataSource);
}

// UseCases
@riverpod
GetCampaigns getCampaigns(Ref ref) {
  final repository = ref.watch(donationRepositoryProvider);
  return GetCampaigns(repository);
}

@riverpod
Future<CampaignEntity> getCampaignDetail(Ref ref, String id) {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getCampaignDetail(id);
}
