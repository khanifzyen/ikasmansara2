import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/donations/domain/entities/donation_transaction.dart';
import 'package:ika_smansara/features/donations/domain/repositories/donation_repository.dart';
import 'package:ika_smansara/features/donations/domain/usecases/get_my_donations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<DonationRepository>()])
import 'get_my_donations_test.mocks.dart';

void main() {
  late GetMyDonations useCase;
  late MockDonationRepository mockRepository;

  setUp(() {
    mockRepository = MockDonationRepository();
    useCase = GetMyDonations(mockRepository);
  });

  group('GetMyDonations UseCase', () {
    final tMyDonations = [
      DonationTransaction(
        id: 'tx1',
        donationId: '1',
        donorName: 'Saya Sendiri',
        amount: 100000,
        message: 'Donasi 1',
        isAnonymous: false,
        paymentStatus: 'success',
        paymentMethod: 'GoPay',
        transactionId: 'TX001',
        created: DateTime(2025, 1, 1),
      ),
      DonationTransaction(
        id: 'tx2',
        donationId: '2',
        donorName: 'Saya Sendiri',
        amount: 200000,
        message: 'Donasi 2',
        isAnonymous: false,
        paymentStatus: 'pending',
        paymentMethod: 'OVO',
        transactionId: 'TX002',
        created: DateTime(2025, 1, 2),
      ),
    ];

    test('should get my donation history', () async {
      // Arrange
      when(mockRepository.getMyDonationHistory())
          .thenAnswer((_) async => tMyDonations);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(tMyDonations));
      expect(result.length, equals(2));
      expect(result[0].donorName, equals('Saya Sendiri'));
      expect(result[1].donorName, equals('Saya Sendiri'));
      verify(mockRepository.getMyDonationHistory());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no donations', () async {
      // Arrange
      when(mockRepository.getMyDonationHistory())
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getMyDonationHistory());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Unauthorized');
      when(mockRepository.getMyDonationHistory()).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(exception),
      );
      verify(mockRepository.getMyDonationHistory());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should include different payment statuses', () async {
      // Arrange
      final mixedStatusDonations = [
        DonationTransaction(
          id: '1',
          donorName: 'A',
          amount: 100,
          isAnonymous: false,
          paymentStatus: 'success',
          transactionId: 'T1',
          created: DateTime(2025),
        ),
        DonationTransaction(
          id: '2',
          donorName: 'A',
          amount: 200,
          isAnonymous: false,
          paymentStatus: 'pending',
          transactionId: 'T2',
          created: DateTime(2025),
        ),
        DonationTransaction(
          id: '3',
          donorName: 'A',
          amount: 300,
          isAnonymous: false,
          paymentStatus: 'failed',
          transactionId: 'T3',
          created: DateTime(2025),
        ),
      ];
      when(mockRepository.getMyDonationHistory())
          .thenAnswer((_) async => mixedStatusDonations);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, equals(3));
      expect(result[0].isSuccess, isTrue);
      expect(result[1].isPending, isTrue);
      expect(result[2].isFailed, isTrue);
    });
  });

  group('GetMyDonations UseCase - Edge Cases', () {
    test('should handle single donation', () async {
      // Arrange
      final singleDonation = [
        DonationTransaction(
          id: 'tx1',
          donorName: 'Single',
          amount: 50000,
          isAnonymous: false,
          paymentStatus: 'success',
          transactionId: 'TX001',
          created: DateTime(2025),
        ),
      ];
      when(mockRepository.getMyDonationHistory())
          .thenAnswer((_) async => singleDonation);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, equals(1));
      expect(result[0].amount, equals(50000));
    });

    test('should handle anonymous donations', () async {
      // Arrange
      final anonymousDonations = [
        DonationTransaction(
          id: 'tx1',
          donorName: 'Hamba Allah',
          amount: 100000,
          isAnonymous: true,
          paymentStatus: 'success',
          transactionId: 'TX001',
          created: DateTime(2025),
        ),
      ];
      when(mockRepository.getMyDonationHistory())
          .thenAnswer((_) async => anonymousDonations);

      // Act
      final result = await useCase();

      // Assert
      expect(result[0].isAnonymous, isTrue);
      expect(result[0].donorName, equals('Hamba Allah'));
    });
  });
}
