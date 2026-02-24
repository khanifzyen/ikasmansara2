import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/get_event_detail.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'get_event_detail_test.mocks.dart';

void main() {
  late GetEventDetail useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetEventDetail(mockRepository);
  });

  group('GetEventDetail UseCase', () {
    final tEvent = Event(
      id: '1',
      title: 'Detailed Event',
      description: 'Full description here',
      date: DateTime(2025, 12, 25),
      time: '19:00',
      location: 'Grand Hall',
      banner: 'banner.jpg',
      status: 'active',
      created: DateTime(2025),
      updated: DateTime(2025),
      code: 'EVT001',
      enableSponsorship: true,
      enableDonation: true,
      donationTarget: 5000000,
      donationDescription: 'Charity event',
      bookingIdFormat: 'BKG-{code}',
      ticketIdFormat: 'TKT-{code}',
    );

    test('should get event detail from repository', () async {
      // Arrange
      when(mockRepository.getEventDetail('1'))
          .thenAnswer((_) async => tEvent);

      // Act
      final result = await useCase('1');

      // Assert
      expect(result, equals(tEvent));
      expect(result.id, equals('1'));
      expect(result.title, equals('Detailed Event'));
      expect(result.enableSponsorship, isTrue);
      verify(mockRepository.getEventDetail('1'));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Event not found');
      when(mockRepository.getEventDetail('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(() => useCase('invalid'), throwsA(exception));
    });

    test('should call repository with correct ID', () async {
      // Arrange
      when(mockRepository.getEventDetail('evt123'))
          .thenAnswer((_) async => tEvent);

      // Act
      await useCase('evt123');

      // Assert
      verify(mockRepository.getEventDetail('evt123')).called(1);
    });
  });
}
