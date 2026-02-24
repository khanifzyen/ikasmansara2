import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/delete_booking.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'delete_booking_test.mocks.dart';

void main() {
  late DeleteBooking useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = DeleteBooking(mockRepository);
  });

  group('DeleteBooking UseCase', () {
    test('should delete booking', () async {
      // Arrange
      when(mockRepository.deleteBooking('booking1'))
          .thenAnswer((_) async {});

      // Act
      await useCase('booking1');

      // Assert
      verify(mockRepository.deleteBooking('booking1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Booking not found');
      when(mockRepository.deleteBooking('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(() => useCase('invalid'), throwsA(exception));
    });
  });
}
