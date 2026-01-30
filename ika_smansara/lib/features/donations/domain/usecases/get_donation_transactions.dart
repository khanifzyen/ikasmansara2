import '../entities/donation_transaction.dart';
import '../repositories/donation_repository.dart';

class GetDonationTransactions {
  final DonationRepository repository;

  GetDonationTransactions(this.repository);

  Future<List<DonationTransaction>> call(String donationId) {
    return repository.getDonationTransactions(donationId);
  }
}
