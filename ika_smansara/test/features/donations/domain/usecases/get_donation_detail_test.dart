import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/donations/domain/entities/donation.dart';
import 'package:ika_smansara/features/donations/domain/repositories/donation_repository.dart';
import 'package:ika_smansara/features/donations/domain/usecases/get_donation_detail.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<DonationRepository>()])
import 'get_donation_detail_test.mocks.dart';

void main() {
  late GetDonationDetail useCase;
  late MockDonationRepository mockRepository;

  setUp(() {
    mockRepository = MockDonationRepository();
    useCase = GetDonationDetail(mockRepository);
  });

  group('GetDonationDetail UseCase', () {
    final tDonation = Donation(
      id: '1',
      title: 'Test Donation',
      description: 'Test Description',
      targetAmount: 1000000,
      collectedAmount: 500000,
      deadline: DateTime(2025, 12, 31),
      banner: 'banner.jpg',
      organizer: 'Organizer',
      category: 'Category',
      priority: 'urgent',
      status: 'active',
      donorCount: 10,
      createdBy: 'admin',
    );

    test('should get donation detail from repository', () async {
      // Arrange
      when(mockRepository.getDonationDetail('1'))
          .thenAnswer((_) async => tDonation);

      // Act
      final result = await useCase('1');

      // Assert
      expect(result, equals(tDonation));
      expect(result.id, equals('1'));
      expect(result.title, equals('Test Donation'));
      verify(mockRepository.getDonationDetail('1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Not found');
      when(mockRepository.getDonationDetail('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('invalid'),
        throwsA(exception),
      );
      verify(mockRepository.getDonationDetail('invalid'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository with correct ID', () async {
      // Arrange
      when(mockRepository.getDonationDetail('123'))
          .thenAnswer((_) async => tDonation);

      // Act
      await useCase('123');

      // Assert
      verify(mockRepository.getDonationDetail('123')).called(1);
    });
  });
}
