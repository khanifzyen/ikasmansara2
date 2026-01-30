import '../../domain/entities/donation.dart';
import '../../domain/entities/donation_transaction.dart';
import '../../domain/repositories/donation_repository.dart';
import '../datasources/donation_remote_data_source.dart';

class DonationRepositoryImpl implements DonationRepository {
  final DonationRemoteDataSource _remoteDataSource;

  DonationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Donation>> getDonations() async {
    final models = await _remoteDataSource.getDonations();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Donation> getDonationDetail(String id) async {
    final model = await _remoteDataSource.getDonationDetail(id);
    return model.toEntity();
  }

  @override
  Future<List<DonationTransaction>> getMyDonationHistory() async {
    final models = await _remoteDataSource.getMyDonationHistory();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<DonationTransaction>> getDonationTransactions(
    String donationId,
  ) async {
    final models = await _remoteDataSource.getDonationTransactions(donationId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<DonationTransaction> createTransaction({
    required String donationId,
    required double amount,
    required String donorName,
    required bool isAnonymous,
    String? message,
    String? paymentMethod,
  }) async {
    final model = await _remoteDataSource.createTransaction(
      donationId: donationId,
      amount: amount,
      donorName: donorName,
      isAnonymous: isAnonymous,
      message: message,
      paymentMethod: paymentMethod,
    );
    return model.toEntity();
  }
}
