import '../entities/donation.dart';
import '../repositories/donation_repository.dart';

class GetDonationDetail {
  final DonationRepository repository;

  GetDonationDetail(this.repository);

  Future<Donation> call(String id) {
    return repository.getDonationDetail(id);
  }
}
