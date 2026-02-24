import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_booking.dart';

void main() {
  group('EventBooking Entity', () {
    test('should create EventBooking instance correctly', () {
      // Arrange & Act
      final booking = EventBooking(
        id: '1',
        collectionId: 'col1',
        collectionName: 'bookings',
        eventId: 'evt1',
        userId: 'user1',
        bookingId: 'BKG001',
        created: DateTime(2025),
        metadata: [
          {'ticketId': 't1', 'quantity': 2, 'options': {'name': 'VIP'}},
        ],
        subtotal: 100000,
        serviceFee: 5000,
        totalPrice: 105000,
        paymentStatus: 'pending',
      );

      // Assert
      expect(booking.id, equals('1'));
      expect(booking.bookingId, equals('BKG001'));
      expect(booking.subtotal, equals(100000));
      expect(booking.totalPrice, equals(105000));
    });

    test('displayName should return correct value for app registration', () {
      // Arrange
      final appBooking = EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'e1',
        userId: 'user123',
        bookingId: 'B001',
        created: DateTime(2025),
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 0,
        paymentStatus: 'pending',
        registrationChannel: 'app',
        userName: 'John Doe',
      );

      // Act & Assert
      expect(appBooking.displayName, equals('John Doe'));
    });

    test('displayName should return coordinator name for manual registration', () {
      // Arrange
      final manualBooking = EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'e1',
        userId: '',
        bookingId: 'B001',
        created: DateTime(2025),
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 0,
        paymentStatus: 'pending',
        registrationChannel: 'manual',
        coordinatorName: 'Jane Coordinator',
      );

      // Act & Assert
      expect(manualBooking.displayName, equals('(Koordinator) Jane Coordinator'));
    });

    test('displayPrice should return subtotal when > 0', () {
      // Arrange
      final booking = EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'e1',
        userId: 'u1',
        bookingId: 'B001',
        created: DateTime(2025),
        metadata: [],
        subtotal: 100000,
        serviceFee: 5000,
        totalPrice: 105000,
        paymentStatus: 'pending',
      );

      // Act & Assert
      expect(booking.displayPrice, equals(100000));
    });

    test('displayPrice should return totalPrice when subtotal is 0', () {
      // Arrange
      final booking = EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'e1',
        userId: 'u1',
        bookingId: 'B001',
        created: DateTime(2025),
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 50000,
        paymentStatus: 'paid',
      );

      // Act & Assert
      expect(booking.displayPrice, equals(50000));
    });

    test('displayTicketCount should calculate from metadata for app booking', () {
      // Arrange
      final booking = EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'e1',
        userId: 'u1',
        bookingId: 'B001',
        created: DateTime(2025),
        metadata: [
          {'quantity': 2},
          {'quantity': 3},
        ],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 0,
        paymentStatus: 'pending',
        registrationChannel: 'app',
      );

      // Act & Assert
      expect(booking.displayTicketCount, equals(5));
    });

    test('displayTicketCount should return manualTicketCount for manual booking', () {
      // Arrange
      final booking = EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'e1',
        userId: '',
        bookingId: 'B001',
        created: DateTime(2025),
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 0,
        paymentStatus: 'pending',
        registrationChannel: 'manual',
        manualTicketCount: 10,
      );

      // Act & Assert
      expect(booking.displayTicketCount, equals(10));
    });

    test('should implement Equatable', () {
      // Arrange
      final booking1 = EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'e1',
        userId: 'u1',
        bookingId: 'B001',
        created: DateTime(2025),
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 0,
        paymentStatus: 'pending',
      );
      final booking2 = EventBooking(
        id: '1',
        collectionId: 'c1',
        collectionName: 'b',
        eventId: 'e1',
        userId: 'u1',
        bookingId: 'B001',
        created: DateTime(2025),
        metadata: [],
        subtotal: 0,
        serviceFee: 0,
        totalPrice: 0,
        paymentStatus: 'pending',
      );

      // Assert
      expect(booking1, equals(booking2));
    });
  });
}
