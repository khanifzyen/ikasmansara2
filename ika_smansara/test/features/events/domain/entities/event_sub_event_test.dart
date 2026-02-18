import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_sub_event.dart';

void main() {
  group('EventSubEvent Entity', () {
    test('should create EventSubEvent instance correctly', () {
      // Arrange & Act
      final subEvent = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Workshop Flutter',
        description: 'Learn Flutter from scratch',
        quota: 50,
        registered: 30,
        image: 'workshop.jpg',
      );

      // Assert
      expect(subEvent.id, equals('sub1'));
      expect(subEvent.eventId, equals('event1'));
      expect(subEvent.title, equals('Workshop Flutter'));
      expect(subEvent.description, equals('Learn Flutter from scratch'));
      expect(subEvent.quota, equals(50));
      expect(subEvent.registered, equals(30));
      expect(subEvent.image, equals('workshop.jpg'));
    });

    test('should create EventSubEvent without image', () {
      // Arrange & Act
      final subEvent = EventSubEvent(
        id: 'sub2',
        eventId: 'event1',
        title: 'Networking Session',
        description: 'Meet and greet',
        quota: 100,
        registered: 75,
      );

      // Assert
      expect(subEvent.image, isNull);
    });

    test('should handle zero quota', () {
      // Arrange & Act
      final unlimitedSubEvent = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Open Session',
        description: 'No limit',
        quota: 0,
        registered: 0,
      );

      // Assert
      expect(unlimitedSubEvent.quota, equals(0));
      expect(unlimitedSubEvent.registered, equals(0));
    });

    test('should handle full registration', () {
      // Arrange & Act
      final fullSubEvent = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Exclusive Workshop',
        description: 'Limited seats',
        quota: 20,
        registered: 20,
      );

      // Assert
      expect(fullSubEvent.quota, equals(20));
      expect(fullSubEvent.registered, equals(20));
      expect(fullSubEvent.registered, greaterThanOrEqualTo(fullSubEvent.quota));
    });

    test('should handle partial registration', () {
      // Arrange & Act
      final partialSubEvent = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Workshop',
        description: 'Test',
        quota: 100,
        registered: 45,
      );

      // Assert
      expect(partialSubEvent.registered, lessThan(partialSubEvent.quota));
    });

    test('should handle large quota values', () {
      // Arrange & Act
      final largeSubEvent = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Main Event',
        description: 'Big event',
        quota: 10000,
        registered: 7500,
      );

      // Assert
      expect(largeSubEvent.quota, equals(10000));
      expect(largeSubEvent.registered, equals(7500));
    });

    test('should implement Equatable', () {
      // Arrange
      final subEvent1 = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Workshop',
        description: 'Learn',
        quota: 50,
        registered: 30,
        image: 'workshop.jpg',
      );
      final subEvent2 = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Workshop',
        description: 'Learn',
        quota: 50,
        registered: 30,
        image: 'workshop.jpg',
      );
      final subEvent3 = EventSubEvent(
        id: 'sub2',
        eventId: 'event1',
        title: 'Different Workshop',
        description: 'Different',
        quota: 40,
        registered: 20,
      );

      // Assert
      expect(subEvent1, equals(subEvent2));
      expect(subEvent1, isNot(equals(subEvent3)));
    });

    test('should consider different images as different', () {
      // Arrange
      final subEvent1 = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Workshop',
        description: 'Learn',
        quota: 50,
        registered: 30,
        image: 'image1.jpg',
      );
      final subEvent2 = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Workshop',
        description: 'Learn',
        quota: 50,
        registered: 30,
        image: 'image2.jpg',
      );

      // Assert
      expect(subEvent1, isNot(equals(subEvent2)));
    });

    test('should have all props in Equatable', () {
      // Arrange
      final subEvent = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Test',
        description: 'Test desc',
        quota: 50,
        registered: 30,
        image: 'test.jpg',
      );

      // Assert
      expect(subEvent.props, equals([
        'sub1',
        'event1',
        'Test',
        'Test desc',
        50,
        30,
        'test.jpg',
      ]));
    });

    test('should handle empty description', () {
      // Arrange & Act
      final subEvent = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Quick Session',
        description: '',
        quota: 10,
        registered: 5,
      );

      // Assert
      expect(subEvent.description, equals(''));
      expect(subEvent.description, isEmpty);
    });

    test('should handle long title and description', () {
      // Arrange
      final longTitle = 'Advanced Flutter Workshop with State Management and Architecture Patterns';
      final longDesc = 'This comprehensive workshop covers BLoC, Provider, Riverpod, and clean architecture principles for building scalable Flutter applications.';

      // Act
      final subEvent = EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: longTitle,
        description: longDesc,
        quota: 30,
        registered: 15,
      );

      // Assert
      expect(subEvent.title, equals(longTitle));
      expect(subEvent.description, equals(longDesc));
    });
  });
}
