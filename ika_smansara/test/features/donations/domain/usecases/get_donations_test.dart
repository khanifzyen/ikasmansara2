import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/donations/domain/entities/donation.dart';
import 'package:ika_smansara/features/donations/domain/repositories/donation_repository.dart';
import 'package:ika_smansara/features/donations/domain/usecases/get_donations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<DonationRepository>()])
import 'get_donations_test.mocks.dart';

void main() {
  late GetDonations useCase;
  late MockDonationRepository mockRepository;

  setUp(() {
    mockRepository = MockDonationRepository();
    useCase = GetDonations(mockRepository);
  });

  group('GetDonations UseCase', () {
    final tDonations = [
      Donation(
        id: '1',
        title: 'Donasi A',
        description: 'Deskripsi A',
        targetAmount: 1000000,
        collectedAmount: 500000,
        deadline: DateTime(2025, 12, 31),
        banner: 'banner1.jpg',
        organizer: 'Organizer A',
        category: 'Kategori A',
        priority: 'urgent',
        status: 'active',
        donorCount: 10,
        createdBy: 'admin',
      ),
      Donation(
        id: '2',
        title: 'Donasi B',
        description: 'Deskripsi B',
        targetAmount: 2000000,
        collectedAmount: 1000000,
        deadline: DateTime(2025, 12, 31),
        banner: 'banner2.jpg',
        organizer: 'Organizer B',
        category: 'Kategori B',
        priority: 'normal',
        status: 'active',
        donorCount: 20,
        createdBy: 'admin',
      ),
    ];

    test('should get donations from repository', () async {
      // Arrange
      when(mockRepository.getDonations())
          .thenAnswer((_) async => tDonations);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(tDonations));
      expect(result.length, equals(2));
      expect(result[0].title, equals('Donasi A'));
      expect(result[1].title, equals('Donasi B'));
      verify(mockRepository.getDonations());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no donations', () async {
      // Arrange
      when(mockRepository.getDonations()).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getDonations());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to fetch donations');
      when(mockRepository.getDonations()).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(exception),
      );
      verify(mockRepository.getDonations());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository only once', () async {
      // Arrange
      when(mockRepository.getDonations())
          .thenAnswer((_) async => tDonations);

      // Act
      await useCase();

      // Assert
      verify(mockRepository.getDonations()).called(1);
    });
  });

  group('GetDonations UseCase - Edge Cases', () {
    test('should handle single donation', () async {
      // Arrange
      final singleDonation = [
        Donation(
          id: '1',
          title: 'Single Donation',
          description: 'Desc',
          targetAmount: 1000,
          collectedAmount: 500,
          deadline: DateTime(2025),
          banner: '',
          organizer: '',
          category: '',
          priority: 'normal',
          status: '',
          donorCount: 0,
          createdBy: '',
        ),
      ];
      when(mockRepository.getDonations())
          .thenAnswer((_) async => singleDonation);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, equals(1));
      expect(result[0].title, equals('Single Donation'));
    });

    test('should preserve donation order from repository', () async {
      // Arrange
      final orderedDonations = [
        Donation(
          id: '1',
          title: 'First',
          description: 'Desc',
          targetAmount: 1000,
          collectedAmount: 0,
          deadline: DateTime(2025),
          banner: '',
          organizer: '',
          category: '',
          priority: 'normal',
          status: '',
          donorCount: 0,
          createdBy: '',
        ),
        Donation(
          id: '2',
          title: 'Second',
          description: 'Desc',
          targetAmount: 1000,
          collectedAmount: 0,
          deadline: DateTime(2025),
          banner: '',
          organizer: '',
          category: '',
          priority: 'normal',
          status: '',
          donorCount: 0,
          createdBy: '',
        ),
        Donation(
          id: '3',
          title: 'Third',
          description: 'Desc',
          targetAmount: 1000,
          collectedAmount: 0,
          deadline: DateTime(2025),
          banner: '',
          organizer: '',
          category: '',
          priority: 'normal',
          status: '',
          donorCount: 0,
          createdBy: '',
        ),
      ];
      when(mockRepository.getDonations())
          .thenAnswer((_) async => orderedDonations);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, equals(3));
      expect(result[0].id, equals('1'));
      expect(result[1].id, equals('2'));
      expect(result[2].id, equals('3'));
    });
  });
}
