import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/donations/domain/entities/donation_transaction.dart';
import 'package:ika_smansara/features/donations/domain/repositories/donation_repository.dart';
import 'package:ika_smansara/features/donations/domain/usecases/get_donation_transactions.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<DonationRepository>()])
import 'get_donation_transactions_test.mocks.dart';

void main() {
  late GetDonationTransactions useCase;
  late MockDonationRepository mockRepository;

  setUp(() {
    mockRepository = MockDonationRepository();
    useCase = GetDonationTransactions(mockRepository);
  });

  group('GetDonationTransactions UseCase', () {
    final tTransactions = [
      DonationTransaction(
        id: 'tx1',
        donationId: '1',
        donorName: 'Donor 1',
        amount: 100000,
        message: 'Message 1',
        isAnonymous: false,
        paymentStatus: 'success',
        paymentMethod: 'QRIS',
        transactionId: 'TX001',
        created: DateTime(2025, 1, 1),
      ),
      DonationTransaction(
        id: 'tx2',
        donationId: '1',
        donorName: 'Donor 2',
        amount: 200000,
        isAnonymous: true,
        paymentStatus: 'pending',
        transactionId: 'TX002',
        created: DateTime(2025, 1, 2),
      ),
    ];

    test('should get transactions for specific donation', () async {
      // Arrange
      when(mockRepository.getDonationTransactions('1'))
          .thenAnswer((_) async => tTransactions);

      // Act
      final result = await useCase('1');

      // Assert
      expect(result, equals(tTransactions));
      expect(result.length, equals(2));
      expect(result[0].donationId, equals('1'));
      expect(result[1].donationId, equals('1'));
      verify(mockRepository.getDonationTransactions('1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no transactions', () async {
      // Arrange
      when(mockRepository.getDonationTransactions('999'))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('999');

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getDonationTransactions('999'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to fetch');
      when(mockRepository.getDonationTransactions('1'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('1'),
        throwsA(exception),
      );
      verify(mockRepository.getDonationTransactions('1'));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetDonationTransactions UseCase - Edge Cases', () {
    test('should handle single transaction', () async {
      // Arrange
      final singleTransaction = [
        DonationTransaction(
          id: 'tx1',
          donationId: '1',
          donorName: 'Single',
          amount: 50000,
          isAnonymous: false,
          paymentStatus: 'success',
          transactionId: 'TX001',
          created: DateTime(2025),
        ),
      ];
      when(mockRepository.getDonationTransactions('1'))
          .thenAnswer((_) async => singleTransaction);

      // Act
      final result = await useCase('1');

      // Assert
      expect(result.length, equals(1));
      expect(result[0].donorName, equals('Single'));
    });

    test('should preserve transaction order', () async {
      // Arrange
      final orderedTransactions = [
        DonationTransaction(
          id: '1',
          donationId: 'd1',
          donorName: 'A',
          amount: 100,
          isAnonymous: false,
          paymentStatus: 'success',
          transactionId: 'T1',
          created: DateTime(2025, 1, 1),
        ),
        DonationTransaction(
          id: '2',
          donationId: 'd1',
          donorName: 'B',
          amount: 200,
          isAnonymous: false,
          paymentStatus: 'success',
          transactionId: 'T2',
          created: DateTime(2025, 1, 2),
        ),
        DonationTransaction(
          id: '3',
          donationId: 'd1',
          donorName: 'C',
          amount: 300,
          isAnonymous: false,
          paymentStatus: 'success',
          transactionId: 'T3',
          created: DateTime(2025, 1, 3),
        ),
      ];
      when(mockRepository.getDonationTransactions('d1'))
          .thenAnswer((_) async => orderedTransactions);

      // Act
      final result = await useCase('d1');

      // Assert
      expect(result.length, equals(3));
      expect(result[0].id, equals('1'));
      expect(result[1].id, equals('2'));
      expect(result[2].id, equals('3'));
    });
  });
}
