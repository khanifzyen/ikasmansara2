import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_booking.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/create_event_booking.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'create_event_booking_test.mocks.dart';

void main() {
  late CreateEventBooking useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = CreateEventBooking(mockRepository);
  });

  group('CreateEventBooking UseCase', () {
    final tBooking = EventBooking(
      id: '1',
      collectionId: 'c1',
      collectionName: 'bookings',
      eventId: 'evt1',
      userId: 'user1',
      bookingId: 'BKG001',
      created: DateTime(2025),
      metadata: [
        {'ticketId': 't1', 'quantity': 2},
      ],
      subtotal: 100000,
      serviceFee: 5000,
      totalPrice: 105000,
      paymentStatus: 'pending',
      paymentMethod: 'QRIS',
    );

    test('should create booking with all parameters', () async {
      // Arrange
      when(mockRepository.createBooking(
        eventId: 'evt1',
        metadata: [{'ticketId': 't1', 'quantity': 2}],
        subtotal: 100000,
        serviceFee: 5000,
        totalPrice: 105000,
        paymentMethod: 'QRIS',
      )).thenAnswer((_) async => tBooking);

      // Act
      final result = await useCase(
        eventId: 'evt1',
        metadata: [{'ticketId': 't1', 'quantity': 2}],
        subtotal: 100000,
        serviceFee: 5000,
        totalPrice: 105000,
        paymentMethod: 'QRIS',
      );

      // Assert
      expect(result, equals(tBooking));
      expect(result.bookingId, equals('BKG001'));
      verify(mockRepository.createBooking(
        eventId: 'evt1',
        metadata: [{'ticketId': 't1', 'quantity': 2}],
        subtotal: 100000,
        serviceFee: 5000,
        totalPrice: 105000,
        paymentMethod: 'QRIS',
      ));
    });

    test('should create booking with registration channel', () async {
      // Arrange
      final manualBooking = EventBooking(
        id: '2',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'evt1',
        userId: '',
        bookingId: 'BKG002',
        created: DateTime(2025),
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 50000,
        paymentStatus: 'pending',
        registrationChannel: 'manual',
      );
      when(mockRepository.createBooking(
        eventId: 'evt1',
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 50000,
        paymentMethod: 'CASH',
        registrationChannel: 'manual',
      )).thenAnswer((_) async => manualBooking);

      // Act
      final result = await useCase(
        eventId: 'evt1',
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 50000,
        paymentMethod: 'CASH',
        registrationChannel: 'manual',
      );

      // Assert
      expect(result.registrationChannel, equals('manual'));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Event not found');
      when(mockRepository.createBooking(
        eventId: anyNamed('eventId'),
        metadata: anyNamed('metadata'),
        subtotal: anyNamed('subtotal'),
        serviceFee: anyNamed('serviceFee'),
        totalPrice: anyNamed('totalPrice'),
        paymentMethod: anyNamed('paymentMethod'),
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(
          eventId: 'invalid',
          metadata: [],
          subtotal: 0,
          serviceFee: 0,
          totalPrice: 0,
          paymentMethod: 'QRIS',
        ),
        throwsA(exception),
      );
    });

    test('should handle zero service fee', () async {
      // Arrange
      final noFeeBooking = EventBooking(
        id: '3',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'evt1',
        userId: 'u1',
        bookingId: 'BKG003',
        created: DateTime(2025),
        metadata: [],
        subtotal: 50000,
        serviceFee: 0,
        totalPrice: 50000,
        paymentStatus: 'pending',
      );
      when(mockRepository.createBooking(
        eventId: 'evt1',
        metadata: [],
        subtotal: 50000,
        serviceFee: 0,
        totalPrice: 50000,
        paymentMethod: 'QRIS',
      )).thenAnswer((_) async => noFeeBooking);

      // Act
      final result = await useCase(
        eventId: 'evt1',
        metadata: [],
        subtotal: 50000,
        serviceFee: 0,
        totalPrice: 50000,
        paymentMethod: 'QRIS',
      );

      // Assert
      expect(result.serviceFee, equals(0));
      expect(result.totalPrice, equals(50000));
    });
  });
}
