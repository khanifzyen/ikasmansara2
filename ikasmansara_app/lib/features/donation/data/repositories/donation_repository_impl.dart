import 'package:ikasmansara_app/core/network/network_exceptions.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:ikasmansara_app/features/donation/data/datasources/donation_remote_data_source.dart';
import 'package:ikasmansara_app/features/donation/domain/entities/campaign_entity.dart';
import 'package:ikasmansara_app/features/donation/domain/repositories/donation_repository.dart';

class DonationRepositoryImpl implements DonationRepository {
  final DonationRemoteDataSource remoteDataSource;

  DonationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CampaignEntity>> getCampaigns({String? category}) async {
    try {
      return await remoteDataSource.getCampaigns(category: category);
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }

  @override
  Future<CampaignEntity> getCampaignDetail(String id) async {
    try {
      return await remoteDataSource.getCampaignDetail(id);
    } on ClientException catch (e) {
      throw mapPocketBaseError(e);
    } catch (e) {
      throw NetworkException(e.toString(), 500);
    }
  }
}
