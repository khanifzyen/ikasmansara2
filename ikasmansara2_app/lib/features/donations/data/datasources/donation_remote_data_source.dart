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
    // ignore: avoid_print
    print('DEBUG: Fetching donations list...');
    try {
      final records = await _pbClient.pb
          .collection('donations')
          .getFullList(sort: '-created');
      // ignore: avoid_print
      print('DEBUG: Fetched ${records.length} donations');
      return records.map((r) => DonationModel.fromRecord(r)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Error fetching donations: $e');
      rethrow;
    }
  }

  @override
  Future<DonationModel> getDonationDetail(String id) async {
    // ignore: avoid_print
    print('DEBUG: Fetching donation detail for $id...');
    try {
      final record = await _pbClient.pb.collection('donations').getOne(id);
      // ignore: avoid_print
      print('DEBUG: Fetched donation detail: ${record.id}');
      return DonationModel.fromRecord(record);
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Error fetching donation detail: $e');
      rethrow;
    }
  }

  @override
  Future<List<DonationTransactionModel>> getMyDonationHistory() async {
    // ignore: avoid_print
    print('DEBUG: Fetching my donation history...');
    final user = _pbClient.currentUser;
    if (user == null) {
      // ignore: avoid_print
      print('DEBUG: No user logged in');
      throw Exception('User not logged in');
    }
    try {
      final records = await _pbClient.pb
          .collection('donation_transactions')
          .getFullList(
            filter: 'user = "${user.id}"',
            sort: '-created',
            expand: 'donation',
          );
      // ignore: avoid_print
      print('DEBUG: Fetched ${records.length} my transactions');
      return records
          .map((r) => DonationTransactionModel.fromRecord(r))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Error fetching my history: $e');
      rethrow;
    }
  }

  @override
  Future<List<DonationTransactionModel>> getDonationTransactions(
    String donationId,
  ) async {
    // ignore: avoid_print
    print('DEBUG: Fetching transactions for donation $donationId...');
    try {
      final records = await _pbClient.pb
          .collection('donation_transactions')
          .getList(
            page: 1,
            perPage: 20, // Limit to recent 20
            filter: 'donation = "$donationId" && payment_status = "success"',
            sort: '-created',
          );
      // ignore: avoid_print
      print(
        'DEBUG: Fetched ${records.items.length} transactions for donation $donationId',
      );
      return records.items
          .map((r) => DonationTransactionModel.fromRecord(r))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Error fetching transactions: $e');
      rethrow;
    }
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
    // ignore: avoid_print
    print('DEBUG: Creating transaction for donation $donationId...');
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

    try {
      final record = await _pbClient.pb
          .collection('donation_transactions')
          .create(body: body);
      // ignore: avoid_print
      print('DEBUG: Transaction created: ${record.id}');
      return DonationTransactionModel.fromRecord(record);
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Error creating transaction: $e');
      rethrow;
    }
  }
}
