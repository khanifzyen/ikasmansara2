import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/donations/domain/entities/donation.dart';

void main() {
  group('Donation Entity', () {
    late final Donation sampleDonation;

    setUpAll(() {
      sampleDonation = Donation(
        id: '1',
        title: 'Bantu Korban Bencana',
        description: 'Donasi untuk korban bencana alam',
        targetAmount: 10000000,
        collectedAmount: 5000000,
        deadline: DateTime(2025, 12, 31),
        banner: 'https://example.com/banner.jpg',
        organizer: 'IKA SMANSARA',
        category: 'Kemanusiaan',
        priority: 'urgent',
        status: 'active',
        donorCount: 50,
        createdBy: 'admin',
      );
    });

    group('Computed Properties', () {
      test('should return true when priority is urgent', () {
        final urgentDonation = Donation(
          id: '1',
          title: 'Urgent',
          description: 'Desc',
          targetAmount: 1000,
          collectedAmount: 0,
          deadline: DateTime(2025),
          banner: '',
          organizer: '',
          category: '',
          priority: 'urgent',
          status: '',
          donorCount: 0,
          createdBy: '',
        );

        expect(urgentDonation.isUrgent, isTrue);
      });

      test('should return false when priority is not urgent', () {
        final normalDonation = Donation(
          id: '1',
          title: 'Normal',
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
        );

        expect(normalDonation.isUrgent, isFalse);
      });

      test('should calculate progress correctly', () {
        final progress = sampleDonation.progress;
        expect(progress, equals(0.5)); // 50% collected
      });

      test('should clamp progress to maximum 1.0', () {
        final overFundedDonation = Donation(
          id: '1',
          title: 'Over Funded',
          description: 'Desc',
          targetAmount: 1000,
          collectedAmount: 2000,
          deadline: DateTime(2025),
          banner: '',
          organizer: '',
          category: '',
          priority: 'normal',
          status: '',
          donorCount: 0,
          createdBy: '',
        );

        final progress = overFundedDonation.progress;
        expect(progress, equals(1.0)); // Clamped to 100%
      });

      test('should calculate percentage correctly', () {
        final percentage = sampleDonation.percentage;
        expect(percentage, equals(50)); // 50%
      });

      test('should return 0 percentage when no collection', () {
        final noCollectionDonation = Donation(
          id: '1',
          title: 'No Collection',
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
        );

        final percentage = noCollectionDonation.percentage;
        expect(percentage, equals(0));
      });
    });

    group('Equatable', () {
      test('should return true when two donations are equal', () {
        final donation1 = sampleDonation;
        final donation2 = sampleDonation;

        expect(donation1, equals(donation2));
      });

      test('should return false when two donations have different values', () {
        final donation2 = Donation(
          id: '2',
          title: 'Different Title',
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
        );

        expect(sampleDonation, isNot(equals(donation2)));
      });
    });

    group('Edge Cases', () {
      test('should handle zero target amount gracefully', () {
        final zeroTargetDonation = Donation(
          id: '1',
          title: 'Zero Target',
          description: 'Desc',
          targetAmount: 0,
          collectedAmount: 0,
          deadline: DateTime(2025),
          banner: '',
          organizer: '',
          category: '',
          priority: 'normal',
          status: '',
          donorCount: 0,
          createdBy: '',
        );

        expect(() => zeroTargetDonation.progress, returnsNormally);
      });

      test('should handle negative collected amount', () {
        final negativeDonation = Donation(
          id: '1',
          title: 'Negative',
          description: 'Desc',
          targetAmount: 1000,
          collectedAmount: -100,
          deadline: DateTime(2025),
          banner: '',
          organizer: '',
          category: '',
          priority: 'normal',
          status: '',
          donorCount: 0,
          createdBy: '',
        );

        final progress = negativeDonation.progress;
        expect(progress, equals(0.0)); // Should clamp to 0
      });
    });
  });
}
