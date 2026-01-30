import '../entities/donation.dart';
import '../entities/donation_transaction.dart';

abstract class DonationRepository {
  Future<List<Donation>> getDonations();
  Future<Donation> getDonationDetail(String id);
  Future<List<DonationTransaction>> getMyDonationHistory();
  Future<List<DonationTransaction>> getDonationTransactions(String donationId);
  Future<DonationTransaction> createTransaction({
    required String donationId,
    required double amount,
    required String donorName,
    required bool isAnonymous,
    String? message,
    String? paymentMethod,
  });
}
