import '../entities/donation_transaction.dart';
import '../repositories/donation_repository.dart';

class CreateDonationTransaction {
  final DonationRepository repository;

  CreateDonationTransaction(this.repository);

  Future<DonationTransaction> call({
    required String donationId,
    required double amount,
    required String donorName,
    required bool isAnonymous,
    String? message,
    String? paymentMethod,
  }) {
    return repository.createTransaction(
      donationId: donationId,
      amount: amount,
      donorName: donorName,
      isAnonymous: isAnonymous,
      message: message,
      paymentMethod: paymentMethod,
    );
  }
}
