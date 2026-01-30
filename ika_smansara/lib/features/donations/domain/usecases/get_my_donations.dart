import '../entities/donation_transaction.dart';
import '../repositories/donation_repository.dart';

class GetMyDonations {
  final DonationRepository repository;

  GetMyDonations(this.repository);

  Future<List<DonationTransaction>> call() {
    return repository.getMyDonationHistory();
  }
}
