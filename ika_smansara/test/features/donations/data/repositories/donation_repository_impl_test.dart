import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/donations/data/datasources/donation_remote_data_source.dart';
import 'package:ika_smansara/features/donations/data/models/donation_model.dart';
import 'package:ika_smansara/features/donations/data/models/donation_transaction_model.dart';
import 'package:ika_smansara/features/donations/data/repositories/donation_repository_impl.dart';
import 'package:ika_smansara/features/donations/domain/entities/donation.dart';
import 'package:ika_smansara/features/donations/domain/entities/donation_transaction.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<DonationRemoteDataSource>()])
import 'donation_repository_impl_test.mocks.dart';

void main() {
  late DonationRepositoryImpl repository;
  late MockDonationRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockDonationRemoteDataSource();
    repository = DonationRepositoryImpl(mockRemoteDataSource);
  });

  group('DonationRepositoryImpl', () {
    final tDonationModels = [
      DonationModel(
        id: 'd1',
        title: 'Donasi 1',
        description: 'Deskripsi',
        targetAmount: 1000000,
        collectedAmount: 500000,
        deadline: DateTime(2025, 3, 18),
        banner: 'banner.jpg',
        organizer: 'Organisasi 1',
        category: 'Pendidikan',
        priority: 'high',
        status: 'active',
        donorCount: 10,
        createdBy: 'user1',
      ),
    ];

    final tTransactionModels = [
      DonationTransactionModel(
        id: 't1',
        donationId: 'd1',
        userId: 'user1',
        donorName: 'Donatur',
        amount: 100000,
        paymentStatus: 'verified',
        paymentMethod: 'QRIS',
        transactionId: 'txn123',
        isAnonymous: false,
        created: DateTime(2025, 2, 18),
      ),
    ];

    group('getDonations', () {
      test('should return list of donations', () async {
        // Arrange
        when(mockRemoteDataSource.getDonations())
            .thenAnswer((_) async => tDonationModels);

        // Act
        final result = await repository.getDonations();

        // Assert
        expect(result, hasLength(1));
        expect(result[0], isA<Donation>());
        expect(result[0].title, equals('Donasi 1'));
        verify(mockRemoteDataSource.getDonations());
      });

      test('should return empty list when no donations', () async {
        // Arrange
        when(mockRemoteDataSource.getDonations())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getDonations();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getDonationDetail', () {
      test('should return donation detail', () async {
        // Arrange
        when(mockRemoteDataSource.getDonationDetail('d1'))
            .thenAnswer((_) async => tDonationModels.first);

        // Act
        final result = await repository.getDonationDetail('d1');

        // Assert
        expect(result, isA<Donation>());
        expect(result.id, equals('d1'));
        expect(result.title, equals('Donasi 1'));
        verify(mockRemoteDataSource.getDonationDetail('d1'));
      });

      test('should handle not found', () async {
        // Arrange
        when(mockRemoteDataSource.getDonationDetail('invalid'))
            .thenThrow(Exception('Not found'));

        // Act & Assert
        expect(
          () => repository.getDonationDetail('invalid'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getDonationTransactions', () {
      test('should return transactions for donation', () async {
        // Arrange
        when(mockRemoteDataSource.getDonationTransactions('d1'))
            .thenAnswer((_) async => tTransactionModels);

        // Act
        final result = await repository.getDonationTransactions('d1');

        // Assert
        expect(result, hasLength(1));
        expect(result[0], isA<DonationTransaction>());
        expect(result[0].amount, equals(100000));
        expect(result[0].paymentStatus, equals('verified'));
        verify(mockRemoteDataSource.getDonationTransactions('d1'));
      });

      test('should return empty transactions', () async {
        // Arrange
        when(mockRemoteDataSource.getDonationTransactions('d1'))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getDonationTransactions('d1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getMyDonationHistory', () {
      test('should return user donation history', () async {
        // Arrange
        when(mockRemoteDataSource.getMyDonationHistory())
            .thenAnswer((_) async => tTransactionModels);

        // Act
        final result = await repository.getMyDonationHistory();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].userId, equals('user1'));
        verify(mockRemoteDataSource.getMyDonationHistory());
      });

      test('should return empty history', () async {
        // Arrange
        when(mockRemoteDataSource.getMyDonationHistory())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getMyDonationHistory();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('createTransaction', () {
      test('should create transaction successfully', () async {
        // Arrange
        when(mockRemoteDataSource.createTransaction(
          donationId: anyNamed('donationId'),
          amount: anyNamed('amount'),
          donorName: anyNamed('donorName'),
          isAnonymous: anyNamed('isAnonymous'),
          message: anyNamed('message'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => tTransactionModels.first);

        // Act
        final result = await repository.createTransaction(
          donationId: 'd1',
          amount: 50000,
          donorName: 'Donatur',
          isAnonymous: false,
          message: 'Semoga bermanfaat',
          paymentMethod: 'QRIS',
        );

        // Assert
        expect(result, isA<DonationTransaction>());
        expect(result.amount, equals(100000));
        expect(result.paymentStatus, equals('verified'));
        verify(mockRemoteDataSource.createTransaction(
          donationId: 'd1',
          amount: 50000,
          donorName: 'Donatur',
          isAnonymous: false,
          message: 'Semoga bermanfaat',
          paymentMethod: 'QRIS',
        ));
      });

      test('should handle creation errors', () async {
        // Arrange
        when(mockRemoteDataSource.createTransaction(
          donationId: anyNamed('donationId'),
          amount: anyNamed('amount'),
          donorName: anyNamed('donorName'),
          isAnonymous: anyNamed('isAnonymous'),
          message: anyNamed('message'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenThrow(Exception('Create failed'));

        // Act & Assert
        expect(
          () => repository.createTransaction(
            donationId: 'd1',
            amount: 50000,
            donorName: 'Donatur',
            isAnonymous: false,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should create transaction with minimal params', () async {
        // Arrange
        when(mockRemoteDataSource.createTransaction(
          donationId: anyNamed('donationId'),
          amount: anyNamed('amount'),
          donorName: anyNamed('donorName'),
          isAnonymous: anyNamed('isAnonymous'),
          message: anyNamed('message'),
          paymentMethod: anyNamed('paymentMethod'),
        )).thenAnswer((_) async => tTransactionModels.first);

        // Act
        final result = await repository.createTransaction(
          donationId: 'd1',
          amount: 50000,
          donorName: 'Donatur',
          isAnonymous: true,
        );

        // Assert
        expect(result, isA<DonationTransaction>());
        verify(mockRemoteDataSource.createTransaction(
          donationId: 'd1',
          amount: 50000,
          donorName: 'Donatur',
          isAnonymous: true,
          message: null,
          paymentMethod: null,
        ));
      });
    });
  });
}
