import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/get_events.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'get_events_test.mocks.dart';

void main() {
  late GetEvents useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetEvents(mockRepository);
  });

  group('GetEvents UseCase', () {
    final tEvents = [
      Event(
        id: '1',
        title: 'Event 1',
        description: 'Desc 1',
        date: DateTime(2025, 6, 1),
        time: '10:00',
        location: 'Jakarta',
        status: 'active',
        created: DateTime(2025),
        updated: DateTime(2025),
        code: 'EVT001',
        enableSponsorship: false,
        enableDonation: false,
        bookingIdFormat: 'B',
        ticketIdFormat: 'T',
      ),
      Event(
        id: '2',
        title: 'Event 2',
        description: 'Desc 2',
        date: DateTime(2025, 6, 2),
        time: '14:00',
        location: 'Bandung',
        status: 'active',
        created: DateTime(2025),
        updated: DateTime(2025),
        code: 'EVT002',
        enableSponsorship: false,
        enableDonation: false,
        bookingIdFormat: 'B',
        ticketIdFormat: 'T',
      ),
    ];

    test('should get events from repository', () async {
      // Arrange
      when(mockRepository.getEvents()).thenAnswer((_) async => tEvents);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(tEvents));
      expect(result.length, equals(2));
      verify(mockRepository.getEvents());
    });

    test('should get events with pagination', () async {
      // Arrange
      when(mockRepository.getEvents(page: 2, perPage: 10))
          .thenAnswer((_) async => tEvents);

      // Act
      final result = await useCase(page: 2, perPage: 10);

      // Assert
      expect(result.length, equals(2));
      verify(mockRepository.getEvents(page: 2, perPage: 10));
    });

    test('should get events filtered by category', () async {
      // Arrange
      final categoryEvents = [
        Event(
          id: '1',
          title: 'Seminar',
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
        ),
      ];
      when(mockRepository.getEvents(category: 'seminar'))
          .thenAnswer((_) async => categoryEvents);

      // Act
      final result = await useCase(category: 'seminar');

      // Assert
      expect(result[0].title, equals('Seminar'));
      verify(mockRepository.getEvents(category: 'seminar'));
    });

    test('should return empty list when no events', () async {
      // Arrange
      when(mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to fetch events');
      when(mockRepository.getEvents()).thenThrow(exception);

      // Act & Assert
      expect(() => useCase(), throwsA(exception));
    });
  });
}
