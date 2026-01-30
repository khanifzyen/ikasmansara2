import '../entities/donation.dart';
import '../repositories/donation_repository.dart';

class GetDonations {
  final DonationRepository repository;

  GetDonations(this.repository);

  Future<List<Donation>> call() {
    return repository.getDonations();
  }
}
