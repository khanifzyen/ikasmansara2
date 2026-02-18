import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_sub_event.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/get_event_sub_events.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'get_event_sub_events_test.mocks.dart';

void main() {
  late GetEventSubEvents useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetEventSubEvents(mockRepository);
  });

  group('GetEventSubEvents UseCase', () {
    final tSubEventsList = [
      EventSubEvent(
        id: 'sub1',
        eventId: 'event1',
        title: 'Workshop Flutter',
        description: 'Learn Flutter basics',
        quota: 50,
        registered: 30,
        image: 'workshop.jpg',
      ),
      EventSubEvent(
        id: 'sub2',
        eventId: 'event1',
        title: 'Networking Session',
        description: 'Meet industry experts',
        quota: 100,
        registered: 75,
        image: 'networking.jpg',
      ),
    ];

    test('should get sub-events list from repository', () async {
      // Arrange
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => tSubEventsList);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, equals(tSubEventsList));
      expect(result, hasLength(2));
      expect(result.first.title, equals('Workshop Flutter'));
      verify(mockRepository.getEventSubEvents('event1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no sub-events', () async {
      // Arrange
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getEventSubEvents('event1'));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to load sub-events');
      when(mockRepository.getEventSubEvents('event1'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('event1'),
        throwsA(exception),
      );
      verify(mockRepository.getEventSubEvents('event1'));
    });

    test('should handle single sub-event', () async {
      // Arrange
      final singleSubEvent = [tSubEventsList.first];
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => singleSubEvent);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.quota, equals(50));
      expect(result.first.registered, equals(30));
    });

    test('should handle sub-events without images', () async {
      // Arrange
      final subEventsWithoutImages = [
        EventSubEvent(
          id: 'sub1',
          eventId: 'event1',
          title: 'Session 1',
          description: 'No image',
          quota: 40,
          registered: 20,
        ),
      ];
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => subEventsWithoutImages);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.image, isNull);
    });

    test('should handle different event IDs', () async {
      // Arrange
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => tSubEventsList);
      when(mockRepository.getEventSubEvents('event2'))
          .thenAnswer((_) async => []);

      // Act
      final result1 = await useCase('event1');
      final result2 = await useCase('event2');

      // Assert
      expect(result1, hasLength(2));
      expect(result2, isEmpty);
      verify(mockRepository.getEventSubEvents('event1'));
      verify(mockRepository.getEventSubEvents('event2'));
    });

    test('should call repository only once', () async {
      // Arrange
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => tSubEventsList);

      // Act
      await useCase('event1');

      // Assert
      verify(mockRepository.getEventSubEvents('event1')).called(1);
    });

    test('should preserve sub-event order from repository', () async {
      // Arrange
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => tSubEventsList);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result.first.id, equals('sub1'));
      expect(result.last.id, equals('sub2'));
    });

    test('should handle full registration sub-events', () async {
      // Arrange
      final fullSubEvents = [
        EventSubEvent(
          id: 'sub1',
          eventId: 'event1',
          title: 'Exclusive Workshop',
          description: 'Full',
          quota: 20,
          registered: 20,
        ),
      ];
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => fullSubEvents);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result.first.quota, equals(result.first.registered));
    });

    test('should handle mixed registration status', () async {
      // Arrange
      final mixedSubEvents = [
        EventSubEvent(
          id: 'sub1',
          eventId: 'event1',
          title: 'Full Event',
          description: 'Full',
          quota: 30,
          registered: 30,
        ),
        EventSubEvent(
          id: 'sub2',
          eventId: 'event1',
          title: 'Available Event',
          description: 'Available',
          quota: 50,
          registered: 10,
        ),
        EventSubEvent(
          id: 'sub3',
          eventId: 'event1',
          title: 'Almost Full',
          description: 'Almost',
          quota: 40,
          registered: 35,
        ),
      ];
      when(mockRepository.getEventSubEvents('event1'))
          .thenAnswer((_) async => mixedSubEvents);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, hasLength(3));
      expect(result[0].registered, equals(result[0].quota)); // Full
      expect(result[1].registered, lessThan(result[1].quota)); // Available
      expect(result[2].registered, closeTo(result[2].quota, 10)); // Almost full
    });
  });
}
