/// Unit tests for AdminEventsRepositoryImpl
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ika_smansara/features/admin/events/data/repositories/admin_events_repository_impl.dart';
import 'package:ika_smansara/features/admin/events/data/datasources/admin_events_remote_data_source.dart';
import 'package:ika_smansara/features/events/domain/entities/event.dart';
import 'package:ika_smansara/features/events/domain/entities/event_booking.dart';
import 'package:ika_smansara/features/events/domain/entities/event_booking_ticket.dart';
import 'package:ika_smansara/features/events/domain/entities/event_ticket.dart';

@GenerateNiceMocks([
  MockSpec<AdminEventsRemoteDataSource>(),
])
import 'admin_events_repository_impl_test.mocks.dart';

void main() {
  late AdminEventsRepositoryImpl repository;
  late MockAdminEventsRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAdminEventsRemoteDataSource();
    repository = AdminEventsRepositoryImpl(mockDataSource);
  });

  group('AdminEventsRepositoryImpl - getEvents', () {
    final tEvents = [
      Event(
        id: '1',
        title: 'Event 1',
        description: 'Description 1',
        date: DateTime(2024),
        time: '10:00',
        location: 'Location 1',
        banner: 'banner1.jpg',
        status: 'active',
        created: DateTime(2024),
        updated: DateTime(2024),
        code: 'EVT001',
        enableSponsorship: false,
        enableDonation: false,
        bookingIdFormat: 'BOOK-{id}',
        ticketIdFormat: 'TIX-{id}',
      ),
    ];

    test('should get events from data source', () async {
      // Arrange
      when(mockDataSource.getEvents(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tEvents as List<Event>);

      // Act
      final result = await repository.getEvents(
        filter: 'status="published"',
        page: 1,
        perPage: 20,
      );

      // Assert
      expect(result, tEvents);
      verify(mockDataSource.getEvents(
        filter: 'status="published"',
        page: 1,
        perPage: 20,
      )).called(1);
    });

    test('should get events with default parameters', () async {
      // Arrange
      when(mockDataSource.getEvents(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => tEvents as List<Event>);

      // Act
      await repository.getEvents();

      // Assert
      verify(mockDataSource.getEvents(
        filter: null,
        page: 1,
        perPage: 20,
      )).called(1);
    });

    test('should propagate getEvents exception', () async {
      // Arrange
      when(mockDataSource.getEvents(
        filter: anyNamed('filter'),
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
      )).thenThrow(Exception('Failed to get events'));

      // Act & Assert
      expect(
        () => repository.getEvents(),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - getEventById', () {
    final tEvent = Event(
      id: '1',
      title: 'Test Event',
      description: 'Test Description',
      date: DateTime(2024),
      time: '10:00',
      location: 'Test Location',
      banner: 'banner.jpg',
      status: 'active',
      created: DateTime(2024),
      updated: DateTime(2024),
      code: 'EVT001',
      enableSponsorship: false,
      enableDonation: false,
      bookingIdFormat: 'BOOK-{id}',
      ticketIdFormat: 'TIX-{id}',
    );

    test('should get event by id from data source', () async {
      // Arrange
      when(mockDataSource.getEventById('1'))
          .thenAnswer((_) async => tEvent);

      // Act
      final result = await repository.getEventById('1');

      // Assert
      expect(result, tEvent);
      verify(mockDataSource.getEventById('1')).called(1);
    });

    test('should propagate getEventById exception', () async {
      // Arrange
      when(mockDataSource.getEventById('invalid'))
          .thenThrow(Exception('Event not found'));

      // Act & Assert
      expect(
        () => repository.getEventById('invalid'),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - createEvent', () {
    final tEvent = Event(
      id: '1',
      title: 'New Event',
      description: 'Test Description',
      date: DateTime(2024),
      time: '10:00',
      location: 'Test Location',
      banner: 'banner.jpg',
      status: 'active',
      created: DateTime(2024),
      updated: DateTime(2024),
      code: 'EVT001',
      enableSponsorship: false,
      enableDonation: false,
      bookingIdFormat: 'BOOK-{id}',
      ticketIdFormat: 'TIX-{id}',
    );

    final tEventData = {
      'title': 'New Event',
      'date': DateTime(2024).toIso8601String(),
    };

    test('should create event through data source', () async {
      // Arrange
      when(mockDataSource.createEvent(tEventData))
          .thenAnswer((_) async => tEvent);

      // Act
      final result = await repository.createEvent(tEventData);

      // Assert
      expect(result, tEvent);
      verify(mockDataSource.createEvent(tEventData)).called(1);
    });

    test('should propagate createEvent exception', () async {
      // Arrange
      when(mockDataSource.createEvent(any))
          .thenThrow(Exception('Failed to create event'));

      // Act & Assert
      expect(
        () => repository.createEvent({}),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - createEventTicket', () {
    final tTicketData = {
      'event': 'event123',
      'name': 'Regular Ticket',
      'price': 50000,
    };

    test('should create event ticket through data source', () async {
      // Arrange
      when(mockDataSource.createEventTicket(tTicketData))
          .thenAnswer((_) async => {});

      // Act
      await repository.createEventTicket(tTicketData);

      // Assert
      verify(mockDataSource.createEventTicket(tTicketData)).called(1);
    });

    test('should propagate createEventTicket exception', () async {
      // Arrange
      when(mockDataSource.createEventTicket(any))
          .thenThrow(Exception('Failed to create ticket'));

      // Act & Assert
      expect(
        () => repository.createEventTicket({}),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - updateEvent', () {
    final tUpdateData = {
      'title': 'Updated Title',
      'description': 'Updated Description',
    };

    test('should update event through data source', () async {
      // Arrange
      when(mockDataSource.updateEvent('event123', tUpdateData))
          .thenAnswer((_) async => {});

      // Act
      await repository.updateEvent('event123', tUpdateData);

      // Assert
      verify(mockDataSource.updateEvent('event123', tUpdateData)).called(1);
    });

    test('should propagate updateEvent exception', () async {
      // Arrange
      when(mockDataSource.updateEvent(any, any))
          .thenThrow(Exception('Failed to update event'));

      // Act & Assert
      expect(
        () => repository.updateEvent('event123', {}),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - deleteEvent', () {
    test('should delete event through data source', () async {
      // Arrange
      when(mockDataSource.deleteEvent('event123'))
          .thenAnswer((_) async => {});

      // Act
      await repository.deleteEvent('event123');

      // Assert
      verify(mockDataSource.deleteEvent('event123')).called(1);
    });

    test('should propagate deleteEvent exception', () async {
      // Arrange
      when(mockDataSource.deleteEvent(any))
          .thenThrow(Exception('Failed to delete event'));

      // Act & Assert
      expect(
        () => repository.deleteEvent('event123'),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - updateEventStatus', () {
    test('should update event status through data source', () async {
      // Arrange
      when(mockDataSource.updateEventStatus('event123', 'published'))
          .thenAnswer((_) async => {});

      // Act
      await repository.updateEventStatus('event123', 'published');

      // Assert
      verify(mockDataSource.updateEventStatus('event123', 'published'))
          .called(1);
    });

    test('should propagate updateEventStatus exception', () async {
      // Arrange
      when(mockDataSource.updateEventStatus(any, any))
          .thenThrow(Exception('Failed to update status'));

      // Act & Assert
      expect(
        () => repository.updateEventStatus('event123', 'published'),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - getEventBookings', () {
    final tBookings = [
      EventBooking(
        id: '1',
        collectionId: 'col1',
        collectionName: 'event_bookings',
        eventId: 'event123',
        userId: 'user123',
        bookingId: 'booking123',
        created: DateTime(2024),
        metadata: const [],
        subtotal: 50000,
        serviceFee: 0,
        totalPrice: 50000,
        paymentStatus: 'paid',
      ),
    ];

    test('should get event bookings from data source', () async {
      // Arrange
      when(mockDataSource.getEventBookings('event123'))
          .thenAnswer((_) async => tBookings as List<EventBooking>);

      // Act
      final result = await repository.getEventBookings('event123');

      // Assert
      expect(result, tBookings);
      verify(mockDataSource.getEventBookings('event123')).called(1);
    });

    test('should propagate getEventBookings exception', () async {
      // Arrange
      when(mockDataSource.getEventBookings(any))
          .thenThrow(Exception('Failed to get bookings'));

      // Act & Assert
      expect(
        () => repository.getEventBookings('event123'),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - getEventBookingTickets', () {
    final tTickets = [
      EventBookingTicket(
        id: '1',
        bookingId: 'booking123',
        eventId: 'event123',
        ticketName: 'Regular Ticket',
        ticketCode: 'TIX-001',
        userName: 'Test User',
        userEmail: 'test@example.com',
        options: const {},
      ),
    ];

    test('should get booking tickets from data source', () async {
      // Arrange
      when(mockDataSource.getEventBookingTickets('booking123'))
          .thenAnswer((_) async => tTickets as List<EventBookingTicket>);

      // Act
      final result = await repository.getEventBookingTickets('booking123');

      // Assert
      expect(result, tTickets);
      verify(mockDataSource.getEventBookingTickets('booking123')).called(1);
    });

    test('should propagate getEventBookingTickets exception', () async {
      // Arrange
      when(mockDataSource.getEventBookingTickets(any))
          .thenThrow(Exception('Failed to get tickets'));

      // Act & Assert
      expect(
        () => repository.getEventBookingTickets('booking123'),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - updateBookingStatus', () {
    test('should update booking status through data source', () async {
      // Arrange
      when(mockDataSource.updateBookingStatus('booking123', 'paid'))
          .thenAnswer((_) async => {});

      // Act
      await repository.updateBookingStatus('booking123', 'paid');

      // Assert
      verify(mockDataSource.updateBookingStatus('booking123', 'paid'))
          .called(1);
    });

    test('should propagate updateBookingStatus exception', () async {
      // Arrange
      when(mockDataSource.updateBookingStatus(any, any))
          .thenThrow(Exception('Failed to update booking'));

      // Act & Assert
      expect(
        () => repository.updateBookingStatus('booking123', 'paid'),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - createManualBooking', () {
    final tBookingData = {
      'event': 'event123',
      'user': 'user123',
      'payment_status': 'paid',
    };

    test('should create manual booking through data source', () async {
      // Arrange
      when(mockDataSource.createManualBooking(tBookingData))
          .thenAnswer((_) async => {});

      // Act
      await repository.createManualBooking(tBookingData);

      // Assert
      verify(mockDataSource.createManualBooking(tBookingData)).called(1);
    });

    test('should propagate createManualBooking exception', () async {
      // Arrange
      when(mockDataSource.createManualBooking(any))
          .thenThrow(Exception('Failed to create booking'));

      // Act & Assert
      expect(
        () => repository.createManualBooking({}),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - getEventTickets', () {
    final tTickets = [
      EventTicket(
        id: '1',
        eventId: 'event123',
        name: 'Regular',
        description: 'Regular ticket description',
        price: 50000,
        quota: 100,
        sold: 0,
      ),
    ];

    test('should get event tickets from data source', () async {
      // Arrange
      when(mockDataSource.getEventTickets('event123'))
          .thenAnswer((_) async => tTickets as List<EventTicket>);

      // Act
      final result = await repository.getEventTickets('event123');

      // Assert
      expect(result, tTickets);
      verify(mockDataSource.getEventTickets('event123')).called(1);
    });

    test('should propagate getEventTickets exception', () async {
      // Arrange
      when(mockDataSource.getEventTickets(any))
          .thenThrow(Exception('Failed to get tickets'));

      // Act & Assert
      expect(
        () => repository.getEventTickets('event123'),
        throwsException,
      );
    });
  });

  group('AdminEventsRepositoryImpl - getEventStats', () {
    final tStats = {
      'totalParticipants': 10,
      'totalIncome': 500000,
    };

    test('should get event stats from data source', () async {
      // Arrange
      when(mockDataSource.getEventStats('event123'))
          .thenAnswer((_) async => tStats);

      // Act
      final result = await repository.getEventStats('event123');

      // Assert
      expect(result, tStats);
      verify(mockDataSource.getEventStats('event123')).called(1);
    });

    test('should propagate getEventStats exception', () async {
      // Arrange
      when(mockDataSource.getEventStats(any))
          .thenThrow(Exception('Failed to get stats'));

      // Act & Assert
      expect(
        () => repository.getEventStats('event123'),
        throwsException,
      );
    });
  });
}
