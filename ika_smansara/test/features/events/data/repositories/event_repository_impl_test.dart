import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/data/datasources/event_remote_data_source.dart';
import 'package:ika_smansara/features/events/data/models/event_model.dart';
import 'package:ika_smansara/features/events/data/models/event_booking_model.dart';
import 'package:ika_smansara/features/events/data/models/event_ticket_model.dart';
import 'package:ika_smansara/features/events/data/models/event_sub_event_model.dart';
import 'package:ika_smansara/features/events/data/models/event_sponsor_model.dart';
import 'package:ika_smansara/features/events/data/repositories/event_repository_impl.dart';
import 'package:ika_smansara/features/events/domain/entities/event.dart';
import 'package:ika_smansara/features/events/domain/entities/event_booking.dart';
import 'package:ika_smansara/features/events/domain/entities/event_ticket.dart';
import 'package:ika_smansara/features/events/domain/entities/event_sub_event.dart';
import 'package:ika_smansara/features/events/domain/entities/event_sponsor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRemoteDataSource>()])
import 'event_repository_impl_test.mocks.dart';

void main() {
  late EventRepositoryImpl repository;
  late MockEventRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockEventRemoteDataSource();
    repository = EventRepositoryImpl(mockRemoteDataSource);
  });

  group('EventRepositoryImpl', () {
    final tEventModels = [
      EventModel(
        id: 'event1',
        title: 'Event 1',
        description: 'Description',
        date: DateTime(2025, 3, 18),
        time: '10:00',
        location: 'Jakarta',
        banner: 'banner.jpg',
        status: 'active',
        created: DateTime(2025, 2, 18),
        updated: DateTime(2025, 2, 18),
        code: 'EV001',
        enableSponsorship: true,
        enableDonation: true,
        donationTarget: 1000000,
        donationDescription: 'Donation desc',
        bookingIdFormat: 'BK-{code}',
        ticketIdFormat: 'TK-{code}',
      ),
    ];

    group('getEvents', () {
      test('should return list of events', () async {
        // Arrange
        when(mockRemoteDataSource.getEvents(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenAnswer((_) async => tEventModels);

        // Act
        final result = await repository.getEvents(
          page: 1,
          perPage: 10,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result[0], isA<Event>());
        expect(result[0].title, equals('Event 1'));
        verify(mockRemoteDataSource.getEvents(
          page: 1,
          perPage: 10,
          category: null,
        ));
      });

      test('should return empty list when no events', () async {
        // Arrange
        when(mockRemoteDataSource.getEvents(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getEvents();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle errors', () async {
        // Arrange
        when(mockRemoteDataSource.getEvents(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenThrow(Exception('Failed to load'));

        // Act & Assert
        expect(
          () => repository.getEvents(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getEventDetail', () {
      test('should return event detail', () async {
        // Arrange
        when(mockRemoteDataSource.getEventDetail('event1'))
            .thenAnswer((_) async => tEventModels.first);

        // Act
        final result = await repository.getEventDetail('event1');

        // Assert
        expect(result, isA<Event>());
        expect(result.id, equals('event1'));
        expect(result.title, equals('Event 1'));
        verify(mockRemoteDataSource.getEventDetail('event1'));
      });

      test('should handle not found', () async {
        // Arrange
        when(mockRemoteDataSource.getEventDetail('invalid'))
            .thenThrow(Exception('Not found'));

        // Act & Assert
        expect(
          () => repository.getEventDetail('invalid'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createBooking', () {
      final tBookingModel = EventBookingModel(
        id: 'booking1',
        collectionId: 'col1',
        collectionName: 'bookings',
        eventId: 'event1',
        userId: 'user1',
        bookingId: 'BK001',
        created: DateTime(2025, 2, 18),
        metadata: [
          {'ticketId': 'ticket1', 'quantity': 2},
        ],
        subtotal: 100000,
        serviceFee: 5000,
        totalPrice: 105000,
        paymentStatus: 'pending',
        paymentMethod: 'QRIS',
      );

      test('should create booking successfully', () async {
        // Arrange
        when(mockRemoteDataSource.createBooking(
          eventId: anyNamed('eventId'),
          metadata: anyNamed('metadata'),
          subtotal: anyNamed('subtotal'),
          serviceFee: anyNamed('serviceFee'),
          totalPrice: anyNamed('totalPrice'),
          paymentMethod: anyNamed('paymentMethod'),
          registrationChannel: anyNamed('registrationChannel'),
        )).thenAnswer((_) async => tBookingModel);

        // Act
        final result = await repository.createBooking(
          eventId: 'event1',
          metadata: [
            {'ticketId': 'ticket1', 'quantity': 2},
          ],
          subtotal: 100000,
          serviceFee: 5000,
          totalPrice: 105000,
          paymentMethod: 'QRIS',
        );

        // Assert
        expect(result, isA<EventBooking>());
        expect(result.bookingId, equals('BK001'));
        verify(mockRemoteDataSource.createBooking(
          eventId: 'event1',
          metadata: [
            {'ticketId': 'ticket1', 'quantity': 2},
          ],
          subtotal: 100000,
          serviceFee: 5000,
          totalPrice: 105000,
          paymentMethod: 'QRIS',
          registrationChannel: null,
        ));
      });

      test('should handle creation errors', () async {
        // Arrange
        when(mockRemoteDataSource.createBooking(
          eventId: anyNamed('eventId'),
          metadata: anyNamed('metadata'),
          subtotal: anyNamed('subtotal'),
          serviceFee: anyNamed('serviceFee'),
          totalPrice: anyNamed('totalPrice'),
          paymentMethod: anyNamed('paymentMethod'),
          registrationChannel: anyNamed('registrationChannel'),
        )).thenThrow(Exception('Create failed'));

        // Act & Assert
        expect(
          () => repository.createBooking(
            eventId: 'event1',
            metadata: [],
            subtotal: 100000,
            serviceFee: 5000,
            totalPrice: 105000,
            paymentMethod: 'QRIS',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getUserBookings', () {
      test('should return user bookings', () async {
        // Arrange
        final tBookings = [
          EventBookingModel(
            id: 'booking1',
            collectionId: 'col1',
            collectionName: 'bookings',
            eventId: 'event1',
            userId: 'user1',
            bookingId: 'BK001',
            created: DateTime(2025, 2, 18),
            metadata: [],
            subtotal: 100000,
            serviceFee: 5000,
            totalPrice: 105000,
            paymentStatus: 'paid',
          ),
        ];
        when(mockRemoteDataSource.getUserBookings('user1'))
            .thenAnswer((_) async => tBookings);

        // Act
        final result = await repository.getUserBookings('user1');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].bookingId, equals('BK001'));
        verify(mockRemoteDataSource.getUserBookings('user1'));
      });
    });

    group('getEventSponsors', () {
      test('should return event sponsors', () async {
        // Arrange
        final tSponsors = [
          EventSponsorModel(
            id: 'sponsor1',
            eventId: 'event1',
            name: 'Sponsor 1',
            type: 'platinum',
            price: 5000000,
            benefits: ['Benefit 1', 'Benefit 2'],
            created: DateTime(2025, 2, 18),
            updated: DateTime(2025, 2, 18),
          ),
        ];
        when(mockRemoteDataSource.getEventSponsors('event1'))
            .thenAnswer((_) async => tSponsors);

        // Act
        final result = await repository.getEventSponsors('event1');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].name, equals('Sponsor 1'));
        verify(mockRemoteDataSource.getEventSponsors('event1'));
      });

      test('should return empty sponsors', () async {
        // Arrange
        when(mockRemoteDataSource.getEventSponsors('event1'))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getEventSponsors('event1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('cancelBooking', () {
      test('should cancel booking successfully', () async {
        // Arrange
        when(mockRemoteDataSource.cancelBooking('booking1'))
            .thenAnswer((_) async {});

        // Act
        await repository.cancelBooking('booking1');

        // Assert
        verify(mockRemoteDataSource.cancelBooking('booking1'));
      });

      test('should handle cancel errors', () async {
        // Arrange
        when(mockRemoteDataSource.cancelBooking('booking1'))
            .thenThrow(Exception('Cancel failed'));

        // Act & Assert
        expect(
          () => repository.cancelBooking('booking1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteBooking', () {
      test('should delete booking successfully', () async {
        // Arrange
        when(mockRemoteDataSource.deleteBooking('booking1'))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteBooking('booking1');

        // Assert
        verify(mockRemoteDataSource.deleteBooking('booking1'));
      });

      test('should handle delete errors', () async {
        // Arrange
        when(mockRemoteDataSource.deleteBooking('booking1'))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => repository.deleteBooking('booking1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getEventSubEvents', () {
      test('should return sub-events', () async {
        // Arrange
        final tSubEvents = [
          EventSubEventModel(
            id: 'sub1',
            eventId: 'event1',
            title: 'Sub Event 1',
            description: 'Description',
            quota: 50,
            registered: 25,
            image: 'image.jpg',
            created: DateTime(2025, 2, 18),
            updated: DateTime(2025, 2, 18),
          ),
        ];
        when(mockRemoteDataSource.getEventSubEvents('event1'))
            .thenAnswer((_) async => tSubEvents);

        // Act
        final result = await repository.getEventSubEvents('event1');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].title, equals('Sub Event 1'));
        verify(mockRemoteDataSource.getEventSubEvents('event1'));
      });
    });

    group('getEventTickets', () {
      test('should return event tickets', () async {
        // Arrange
        final tTickets = [
          EventTicketModel(
            id: 'ticket1',
            eventId: 'event1',
            name: 'Regular Ticket',
            description: 'Regular admission',
            price: 50000,
            quota: 100,
            sold: 50,
            created: DateTime(2025, 2, 18),
            updated: DateTime(2025, 2, 18),
          ),
        ];
        when(mockRemoteDataSource.getEventTickets('event1'))
            .thenAnswer((_) async => tTickets);

        // Act
        final result = await repository.getEventTickets('event1');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].name, equals('Regular Ticket'));
        verify(mockRemoteDataSource.getEventTickets('event1'));
      });
    });
  });
}
