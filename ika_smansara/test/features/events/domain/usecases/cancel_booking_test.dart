import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/cancel_booking.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'cancel_booking_test.mocks.dart';

void main() {
  late CancelBooking useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = CancelBooking(mockRepository);
  });

  group('CancelBooking UseCase', () {
    test('should cancel booking', () async {
      // Arrange
      when(mockRepository.cancelBooking('booking1'))
          .thenAnswer((_) async {});

      // Act
      await useCase('booking1');

      // Assert
      verify(mockRepository.cancelBooking('booking1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Booking not found');
      when(mockRepository.cancelBooking('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(() => useCase('invalid'), throwsA(exception));
    });

    test('should handle already cancelled booking', () async {
      // Arrange
      when(mockRepository.cancelBooking('cancelled1'))
          .thenAnswer((_) async {});

      // Act
      await useCase('cancelled1');

      // Assert
      verify(mockRepository.cancelBooking('cancelled1'));
    });

    test('should call repository with correct booking ID', () async {
      // Arrange
      when(mockRepository.cancelBooking('bkg12345'))
          .thenAnswer((_) async {});

      // Act
      await useCase('bkg12345');

      // Assert
      verify(mockRepository.cancelBooking('bkg12345')).called(1);
    });
  });
}
