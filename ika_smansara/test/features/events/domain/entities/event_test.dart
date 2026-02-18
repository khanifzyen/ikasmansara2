import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event.dart';

void main() {
  group('Event Entity', () {
    test('should create Event instance correctly', () {
      // Arrange & Act
      final event = Event(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        date: DateTime(2025, 12, 31),
        time: '10:00',
        location: 'Jakarta',
        banner: 'banner.jpg',
        status: 'active',
        created: DateTime(2025),
        updated: DateTime(2025),
        code: 'EVT001',
        enableSponsorship: true,
        enableDonation: true,
        donationTarget: 1000000,
        donationDescription: 'Donation desc',
        bookingIdFormat: 'BKG-{code}',
        ticketIdFormat: 'TKT-{code}',
      );

      // Assert
      expect(event.id, equals('1'));
      expect(event.title, equals('Test Event'));
      expect(event.isRegistrationOpen, isTrue);
      expect(event.enableSponsorship, isTrue);
      expect(event.enableDonation, isTrue);
    });

    test('should handle nullable fields', () {
      // Arrange & Act
      final event = Event(
        id: '2',
        title: 'No Banner Event',
        description: 'Desc',
        date: DateTime(2025),
        time: '09:00',
        location: 'Bandung',
        status: 'inactive',
        created: DateTime(2025),
        updated: DateTime(2025),
        code: 'EVT002',
        enableSponsorship: false,
        enableDonation: false,
        bookingIdFormat: 'BKG',
        ticketIdFormat: 'TKT',
      );

      // Assert
      expect(event.banner, isNull);
      expect(event.donationTarget, isNull);
      expect(event.donationDescription, isNull);
      expect(event.isRegistrationOpen, isFalse);
    });

    test('should implement Equatable', () {
      // Arrange
      final event1 = Event(
        id: '1',
        title: 'Event',
        description: 'Desc',
        date: DateTime(2025),
        time: '10:00',
        location: 'Loc',
        status: 'active',
        created: DateTime(2025),
        updated: DateTime(2025),
        code: 'EVT',
        enableSponsorship: false,
        enableDonation: false,
        bookingIdFormat: 'B',
        ticketIdFormat: 'T',
      );
      final event2 = Event(
        id: '1',
        title: 'Event',
        description: 'Desc',
        date: DateTime(2025),
        time: '10:00',
        location: 'Loc',
        status: 'active',
        created: DateTime(2025),
        updated: DateTime(2025),
        code: 'EVT',
        enableSponsorship: false,
        enableDonation: false,
        bookingIdFormat: 'B',
        ticketIdFormat: 'T',
      );

      // Assert
      expect(event1, equals(event2));
    });

    test('isRegistrationOpen should return true only when active', () {
      // Arrange
      final activeEvent = Event(
        id: '1',
        title: 'Active',
        description: '',
        date: DateTime(2025),
        time: '',
        location: '',
        status: 'active',
        created: DateTime(2025),
        updated: DateTime(2025),
        code: '',
        enableSponsorship: false,
        enableDonation: false,
        bookingIdFormat: '',
        ticketIdFormat: '',
      );
      final inactiveEvent = Event(
        id: '2',
        title: 'Inactive',
        description: '',
        date: DateTime(2025),
        time: '',
        location: '',
        status: 'inactive',
        created: DateTime(2025),
        updated: DateTime(2025),
        code: '',
        enableSponsorship: false,
        enableDonation: false,
        bookingIdFormat: '',
        ticketIdFormat: '',
      );

      // Assert
      expect(activeEvent.isRegistrationOpen, isTrue);
      expect(inactiveEvent.isRegistrationOpen, isFalse);
    });
  });
}
