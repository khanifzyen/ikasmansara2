import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/donations/domain/entities/donation_transaction.dart';
import 'package:ika_smansara/features/donations/domain/repositories/donation_repository.dart';
import 'package:ika_smansara/features/donations/domain/usecases/create_donation_transaction.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<DonationRepository>()])
import 'create_donation_transaction_test.mocks.dart';

void main() {
  late CreateDonationTransaction useCase;
  late MockDonationRepository mockRepository;

  setUp(() {
    mockRepository = MockDonationRepository();
    useCase = CreateDonationTransaction(mockRepository);
  });

  group('CreateDonationTransaction UseCase', () {
    final tTransaction = DonationTransaction(
      id: 'tx1',
      donationId: '1',
      donorName: 'Donor Name',
      amount: 100000,
      message: 'Pesan donasi',
      isAnonymous: false,
      paymentStatus: 'pending',
      paymentMethod: 'QRIS',
      transactionId: 'TX123',
      created: DateTime(2025, 2, 18),
    );

    test('should create transaction with all parameters', () async {
      // Arrange
      when(mockRepository.createTransaction(
        donationId: '1',
        amount: 100000,
        donorName: 'Donor Name',
        isAnonymous: false,
        message: 'Pesan donasi',
        paymentMethod: 'QRIS',
      )).thenAnswer((_) async => tTransaction);

      // Act
      final result = await useCase(
        donationId: '1',
        amount: 100000,
        donorName: 'Donor Name',
        isAnonymous: false,
        message: 'Pesan donasi',
        paymentMethod: 'QRIS',
      );

      // Assert
      expect(result, equals(tTransaction));
      expect(result.donorName, equals('Donor Name'));
      expect(result.amount, equals(100000));
      expect(result.message, equals('Pesan donasi'));
      expect(result.isAnonymous, isFalse);
      verify(mockRepository.createTransaction(
        donationId: '1',
        amount: 100000,
        donorName: 'Donor Name',
        isAnonymous: false,
        message: 'Pesan donasi',
        paymentMethod: 'QRIS',
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should create anonymous transaction', () async {
      // Arrange
      final anonymousTransaction = DonationTransaction(
        id: 'tx2',
        donorName: 'Hamba Allah',
        amount: 50000,
        isAnonymous: true,
        paymentStatus: 'pending',
        transactionId: 'TX456',
        created: DateTime(2025),
      );
      when(mockRepository.createTransaction(
        donationId: '1',
        amount: 50000,
        donorName: 'Hamba Allah',
        isAnonymous: true,
      )).thenAnswer((_) async => anonymousTransaction);

      // Act
      final result = await useCase(
        donationId: '1',
        amount: 50000,
        donorName: 'Hamba Allah',
        isAnonymous: true,
      );

      // Assert
      expect(result.isAnonymous, isTrue);
      expect(result.donorName, equals('Hamba Allah'));
    });

    test('should create transaction without optional parameters', () async {
      // Arrange
      final minTransaction = DonationTransaction(
        id: 'tx3',
        donationId: '2',
        donorName: 'Donor',
        amount: 75000,
        isAnonymous: false,
        paymentStatus: 'pending',
        transactionId: 'TX789',
        created: DateTime(2025),
      );
      when(mockRepository.createTransaction(
        donationId: '2',
        amount: 75000,
        donorName: 'Donor',
        isAnonymous: false,
      )).thenAnswer((_) async => minTransaction);

      // Act
      final result = await useCase(
        donationId: '2',
        amount: 75000,
        donorName: 'Donor',
        isAnonymous: false,
      );

      // Assert
      expect(result, equals(minTransaction));
      expect(result.message, isNull);
      expect(result.paymentMethod, isNull);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Invalid amount');
      when(mockRepository.createTransaction(
        donationId: '1',
        amount: -100,
        donorName: 'Test',
        isAnonymous: false,
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(
          donationId: '1',
          amount: -100,
          donorName: 'Test',
          isAnonymous: false,
        ),
        throwsA(exception),
      );
    });

    test('should handle large amounts', () async {
      // Arrange
      final largeTransaction = DonationTransaction(
        id: 'tx4',
        donationId: '1',
        donorName: 'Philanthropist',
        amount: 100000000, // 100 million
        isAnonymous: false,
        paymentStatus: 'pending',
        transactionId: 'TX999',
        created: DateTime(2025),
      );
      when(mockRepository.createTransaction(
        donationId: '1',
        amount: 100000000,
        donorName: 'Philanthropist',
        isAnonymous: false,
      )).thenAnswer((_) async => largeTransaction);

      // Act
      final result = await useCase(
        donationId: '1',
        amount: 100000000,
        donorName: 'Philanthropist',
        isAnonymous: false,
      );

      // Assert
      expect(result.amount, equals(100000000));
    });
  });

  group('CreateDonationTransaction UseCase - Validations', () {
    test('should handle zero amount', () async {
      // Arrange
      final zeroTransaction = DonationTransaction(
        id: 'tx5',
        donationId: '1',
        donorName: 'Test',
        amount: 0,
        isAnonymous: false,
        paymentStatus: 'pending',
        transactionId: 'TX000',
        created: DateTime(2025),
      );
      when(mockRepository.createTransaction(
        donationId: '1',
        amount: 0,
        donorName: 'Test',
        isAnonymous: false,
      )).thenAnswer((_) async => zeroTransaction);

      // Act
      final result = await useCase(
        donationId: '1',
        amount: 0,
        donorName: 'Test',
        isAnonymous: false,
      );

      // Assert
      expect(result.amount, equals(0));
    });

    test('should handle very long donor name', () async {
      // Arrange
      final longNameTransaction = DonationTransaction(
        id: 'tx6',
        donationId: '1',
        donorName: 'A' * 200, // Very long name
        amount: 1000,
        isAnonymous: false,
        paymentStatus: 'pending',
        transactionId: 'TXLONG',
        created: DateTime(2025),
      );
      when(mockRepository.createTransaction(
        donationId: '1',
        amount: 1000,
        donorName: 'A' * 200,
        isAnonymous: false,
      )).thenAnswer((_) async => longNameTransaction);

      // Act
      final result = await useCase(
        donationId: '1',
        amount: 1000,
        donorName: 'A' * 200,
        isAnonymous: false,
      );

      // Assert
      expect(result.donorName.length, equals(200));
    });
  });
}
