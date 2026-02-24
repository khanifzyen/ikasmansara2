import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_sponsor.dart';

void main() {
  group('EventSponsor Entity', () {
    test('should create EventSponsor instance correctly', () {
      // Arrange & Act
      final sponsor = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Tech Corp',
        type: 'platinum',
        price: 10000000,
        benefits: ['Logo placement', 'Booth space'],
      );

      // Assert
      expect(sponsor.id, equals('sponsor1'));
      expect(sponsor.eventId, equals('event1'));
      expect(sponsor.name, equals('Tech Corp'));
      expect(sponsor.type, equals('platinum'));
      expect(sponsor.price, equals(10000000));
      expect(sponsor.benefits, equals(['Logo placement', 'Booth space']));
    });

    test('should create EventSponsor with empty benefits list', () {
      // Arrange & Act
      final sponsor = EventSponsor(
        id: 'sponsor2',
        eventId: 'event1',
        name: 'Small Biz',
        type: 'silver',
        price: 1000000,
        benefits: [],
      );

      // Assert
      expect(sponsor.benefits, isEmpty);
      expect(sponsor.benefits, hasLength(0));
    });

    test('should handle different sponsor types', () {
      // Arrange
      final types = ['platinum', 'gold', 'silver', 'bronze'];

      // Act & Assert
      for (final type in types) {
        final sponsor = EventSponsor(
          id: '1',
          eventId: 'event1',
          name: 'Sponsor $type',
          type: type,
          price: 1000000,
          benefits: ['Benefit 1'],
        );
        expect(sponsor.type, equals(type));
      }
    });

    test('should handle zero price sponsor', () {
      // Arrange & Act
      final freeSponsor = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Community Partner',
        type: 'community',
        price: 0,
        benefits: ['Mention in social media'],
      );

      // Assert
      expect(freeSponsor.price, equals(0));
    });

    test('should handle large price values', () {
      // Arrange & Act
      final platinumSponsor = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Mega Corp',
        type: 'platinum',
        price: 100000000, // 100 million
        benefits: ['All benefits'],
      );

      // Assert
      expect(platinumSponsor.price, equals(100000000));
    });

    test('should handle multiple benefits', () {
      // Arrange
      final benefitsList = [
        'Logo on banner',
        'Speaking slot',
        'VIP booth',
        'Social media shoutout',
        'Website listing',
      ];

      // Act
      final sponsor = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Premium Sponsor',
        type: 'platinum',
        price: 50000000,
        benefits: benefitsList,
      );

      // Assert
      expect(sponsor.benefits, hasLength(5));
      expect(sponsor.benefits, contains('Speaking slot'));
      expect(sponsor.benefits, contains('VIP booth'));
    });

    test('should implement Equatable', () {
      // Arrange
      final sponsor1 = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Tech Corp',
        type: 'platinum',
        price: 10000000,
        benefits: ['Logo placement'],
      );
      final sponsor2 = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Tech Corp',
        type: 'platinum',
        price: 10000000,
        benefits: ['Logo placement'],
      );
      final sponsor3 = EventSponsor(
        id: 'sponsor2',
        eventId: 'event1',
        name: 'Different Corp',
        type: 'gold',
        price: 5000000,
        benefits: ['Logo'],
      );

      // Assert
      expect(sponsor1, equals(sponsor2));
      expect(sponsor1, isNot(equals(sponsor3)));
    });

    test('should consider different benefits as different', () {
      // Arrange
      final sponsor1 = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Tech Corp',
        type: 'platinum',
        price: 10000000,
        benefits: ['Benefit A', 'Benefit B'],
      );
      final sponsor2 = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Tech Corp',
        type: 'platinum',
        price: 10000000,
        benefits: ['Benefit A', 'Benefit C'], // Different
      );

      // Assert
      expect(sponsor1, isNot(equals(sponsor2)));
    });

    test('should have all props in Equatable', () {
      // Arrange
      final sponsor = EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Test',
        type: 'gold',
        price: 5000000,
        benefits: ['Test'],
      );

      // Assert
      expect(sponsor.props, equals([
        'sponsor1',
        'event1',
        'Test',
        'gold',
        5000000,
        ['Test'],
      ]));
    });
  });
}
