import '../../../../core/network/pb_client.dart';
import '../models/donation_model.dart';
import '../models/donation_transaction_model.dart';

abstract class DonationRemoteDataSource {
  Future<List<DonationModel>> getDonations();
  Future<DonationModel> getDonationDetail(String id);
  Future<List<DonationTransactionModel>> getMyDonationHistory();
  Future<List<DonationTransactionModel>> getDonationTransactions(
    String donationId,
  );
  Future<DonationTransactionModel> createTransaction({
    required String donationId,
    required double amount,
    required String donorName,
    required bool isAnonymous,
    String? message,
    String? paymentMethod,
  });
}

class DonationRemoteDataSourceImpl implements DonationRemoteDataSource {
  final PBClient _pbClient;

  DonationRemoteDataSourceImpl(this._pbClient);

  @override
  Future<List<DonationModel>> getDonations() async {
    final records = await _pbClient.pb
        .collection('donations')
        .getFullList(sort: '-created');
    return records.map((r) => DonationModel.fromRecord(r)).toList();
  }

  @override
  Future<DonationModel> getDonationDetail(String id) async {
    final record = await _pbClient.pb.collection('donations').getOne(id);
    return DonationModel.fromRecord(record);
  }

  @override
  Future<List<DonationTransactionModel>> getMyDonationHistory() async {
    final user = _pbClient.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final records = await _pbClient.pb
        .collection('donation_transactions')
        .getFullList(
          filter: 'user = "${user.id}"',
          sort: '-created',
          expand: 'donation',
        );
    return records.map((r) => DonationTransactionModel.fromRecord(r)).toList();
  }

  @override
  Future<List<DonationTransactionModel>> getDonationTransactions(
    String donationId,
  ) async {
    final records = await _pbClient.pb
        .collection('donation_transactions')
        .getList(
          page: 1,
          perPage: 20, // Limit to recent 20
          filter: 'donation = "$donationId" && payment_status = "success"',
          sort: '-created',
        );
    return records.items
        .map((r) => DonationTransactionModel.fromRecord(r))
        .toList();
  }

  @override
  Future<DonationTransactionModel> createTransaction({
    required String donationId,
    required double amount,
    required String donorName,
    required bool isAnonymous,
    String? message,
    String? paymentMethod,
  }) async {
    final user = _pbClient.currentUser;
    final body = {
      'donation': donationId,
      'user': user?.id,
      'donor_name': donorName,
      'amount': amount,
      'transaction_id':
          'TRX-${DateTime.now().millisecondsSinceEpoch}', // Mock ID
      'payment_status': 'success', // Mock success for now as per plan
      'is_anonymous': isAnonymous,
      if (message != null) 'message': message,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    };

    final record = await _pbClient.pb
        .collection('donation_transactions')
        .create(body: body);
    return DonationTransactionModel.fromRecord(record);
  }
}
