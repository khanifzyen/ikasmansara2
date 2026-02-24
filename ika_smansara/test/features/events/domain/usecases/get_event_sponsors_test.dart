import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_sponsor.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/get_event_sponsors.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'get_event_sponsors_test.mocks.dart';

void main() {
  late GetEventSponsors useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetEventSponsors(mockRepository);
  });

  group('GetEventSponsors UseCase', () {
    final tSponsorsList = [
      EventSponsor(
        id: 'sponsor1',
        eventId: 'event1',
        name: 'Tech Corp',
        type: 'platinum',
        price: 10000000,
        benefits: ['Logo placement', 'Booth space'],
      ),
      EventSponsor(
        id: 'sponsor2',
        eventId: 'event1',
        name: 'Startup Inc',
        type: 'gold',
        price: 5000000,
        benefits: ['Logo placement'],
      ),
    ];

    test('should get sponsors list from repository', () async {
      // Arrange
      when(mockRepository.getEventSponsors('event1'))
          .thenAnswer((_) async => tSponsorsList);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, equals(tSponsorsList));
      expect(result, hasLength(2));
      expect(result.first.name, equals('Tech Corp'));
      verify(mockRepository.getEventSponsors('event1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no sponsors', () async {
      // Arrange
      when(mockRepository.getEventSponsors('event1'))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getEventSponsors('event1'));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to load sponsors');
      when(mockRepository.getEventSponsors('event1'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('event1'),
        throwsA(exception),
      );
      verify(mockRepository.getEventSponsors('event1'));
    });

    test('should handle single sponsor', () async {
      // Arrange
      final singleSponsor = [tSponsorsList.first];
      when(mockRepository.getEventSponsors('event1'))
          .thenAnswer((_) async => singleSponsor);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.type, equals('platinum'));
    });

    test('should handle different event IDs', () async {
      // Arrange
      when(mockRepository.getEventSponsors('event1'))
          .thenAnswer((_) async => tSponsorsList);
      when(mockRepository.getEventSponsors('event2'))
          .thenAnswer((_) async => []);

      // Act
      final result1 = await useCase('event1');
      final result2 = await useCase('event2');

      // Assert
      expect(result1, hasLength(2));
      expect(result2, isEmpty);
      verify(mockRepository.getEventSponsors('event1'));
      verify(mockRepository.getEventSponsors('event2'));
    });

    test('should call repository only once', () async {
      // Arrange
      when(mockRepository.getEventSponsors('event1'))
          .thenAnswer((_) async => tSponsorsList);

      // Act
      await useCase('event1');

      // Assert
      verify(mockRepository.getEventSponsors('event1')).called(1);
    });

    test('should preserve sponsor order from repository', () async {
      // Arrange
      when(mockRepository.getEventSponsors('event1'))
          .thenAnswer((_) async => tSponsorsList);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result.first.id, equals('sponsor1'));
      expect(result.last.id, equals('sponsor2'));
    });
  });
}
