import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_booking.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/get_user_event_bookings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'get_user_event_bookings_test.mocks.dart';

void main() {
  late GetUserEventBookings useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetUserEventBookings(mockRepository);
  });

  group('GetUserEventBookings UseCase', () {
    final tBookings = [
      EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'evt1',
        userId: 'user1',
        bookingId: 'BKG001',
        created: DateTime(2025),
        metadata: [],
        subtotal: 100000,
        serviceFee: 5000,
        totalPrice: 105000,
        paymentStatus: 'paid',
      ),
      EventBooking(
        id: '2',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'evt2',
        userId: 'user1',
        bookingId: 'BKG002',
        created: DateTime(2025),
        metadata: [],
        subtotal: 50000,
        serviceFee: 2500,
        totalPrice: 52500,
        paymentStatus: 'pending',
      ),
    ];

    test('should get user bookings from repository', () async {
      // Arrange
      when(mockRepository.getUserBookings('user1'))
          .thenAnswer((_) async => tBookings);

      // Act
      final result = await useCase('user1');

      // Assert
      expect(result, equals(tBookings));
      expect(result.length, equals(2));
      verify(mockRepository.getUserBookings('user1'));
    });

    test('should return empty list when no bookings', () async {
      // Arrange
      when(mockRepository.getUserBookings('newuser'))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('newuser');

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('User not found');
      when(mockRepository.getUserBookings('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(() => useCase('invalid'), throwsA(exception));
    });

    test('should call repository with correct user ID', () async {
      // Arrange
      when(mockRepository.getUserBookings('user123'))
          .thenAnswer((_) async => tBookings);

      // Act
      await useCase('user123');

      // Assert
      verify(mockRepository.getUserBookings('user123')).called(1);
    });

    test('should include bookings with different payment statuses', () async {
      // Arrange
      final mixedBookings = [
        EventBooking(
          id: '1',
          collectionId: 'c1',
          collectionName: 'b',
          eventId: 'e1',
          userId: 'u1',
          bookingId: 'B1',
          created: DateTime(2025),
          metadata: [],
          subtotal: 0,
          serviceFee: 0,
          totalPrice: 0,
          paymentStatus: 'paid',
        ),
        EventBooking(
          id: '2',
          collectionId: 'c1',
          collectionName: 'b',
          eventId: 'e2',
          userId: 'u1',
          bookingId: 'B2',
          created: DateTime(2025),
          metadata: [],
          subtotal: 0,
          serviceFee: 0,
          totalPrice: 0,
          paymentStatus: 'pending',
        ),
        EventBooking(
          id: '3',
          collectionId: 'c1',
          collectionName: 'b',
          eventId: 'e3',
          userId: 'u1',
          bookingId: 'B3',
          created: DateTime(2025),
          metadata: [],
          subtotal: 0,
          serviceFee: 0,
          totalPrice: 0,
          paymentStatus: 'cancelled',
        ),
      ];
      when(mockRepository.getUserBookings('u1'))
          .thenAnswer((_) async => mixedBookings);

      // Act
      final result = await useCase('u1');

      // Assert
      expect(result.length, equals(3));
      expect(result[0].paymentStatus, equals('paid'));
      expect(result[1].paymentStatus, equals('pending'));
      expect(result[2].paymentStatus, equals('cancelled'));
    });
  });
}
