/// Unit tests for AdminEventsRemoteDataSource
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:ika_smansara/core/network/pb_client.dart';
import 'package:ika_smansara/features/admin/events/data/datasources/admin_events_remote_data_source.dart';
import 'package:ika_smansara/features/events/data/models/event_model.dart';
import 'package:ika_smansara/features/events/data/models/event_booking_model.dart';
import 'package:ika_smansara/features/events/data/models/event_ticket_model.dart';
import 'package:ika_smansara/features/events/data/models/event_booking_ticket_model.dart';

@GenerateNiceMocks([
  MockSpec<PocketBase>(),
  MockSpec<RecordService>(),
  MockSpec<RecordModel>(),
  MockSpec<AuthStore>(),
])
import 'admin_events_remote_data_source_test.mocks.dart';

void main() {
  late AdminEventsRemoteDataSource dataSource;
  late MockPocketBase mockPb;
  late MockRecordService mockCollection;
  late MockAuthStore mockAuthStore;

  setUp(() {
    mockPb = MockPocketBase();
    mockCollection = MockRecordService();
    mockAuthStore = MockAuthStore();

    // Setup PBClient mock
    PBClient.instance = MockPBClient(mockPb, mockAuthStore);

    dataSource = AdminEventsRemoteDataSource();
  });

  group('AdminEventsRemoteDataSource - getEvents', () {
    test('should return list of events when successful', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.getList(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
        filter: anyNamed('filter'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) async => mockResultList([mockRecord]));

      when(mockRecord.data).thenReturn({'id': 'test123', 'title': 'Test Event'});
      when(mockRecord.id).thenReturn('test123');

      // Act
      final result = await dataSource.getEvents();

      // Assert
      expect(result, isA<List<Event>>());
      expect(result.length, greaterThan(0));
      verify(mockPb.collection('events')).called(1);
    });

    test('should apply filter parameter correctly', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.getList(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
        filter: anyNamed('filter'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) async => mockResultList([]));

      const testFilter = 'status = "published"';

      // Act
      await dataSource.getEvents(filter: testFilter);

      // Assert
      final captured = verify(mockCollection.getList(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
        filter: captureAnyNamed('filter'),
        sort: anyNamed('sort'),
      )).captured.single as String?;
      expect(captured, testFilter);
    });

    test('should return empty list when no events found', () async {
      // Arrange
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.getList(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
        filter: anyNamed('filter'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) async => mockResultList([]));

      // Act
      final result = await dataSource.getEvents();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('AdminEventsRemoteDataSource - getEventById', () {
    test('should return event when successful', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.getOne('event123'))
          .thenAnswer((_) async => mockRecord);

      when(mockRecord.data).thenReturn({
        'id': 'event123',
        'title': 'Test Event',
        'date': DateTime.now().toIso8601String(),
      });
      when(mockRecord.id).thenReturn('event123');

      // Act
      final result = await dataSource.getEventById('event123');

      // Assert
      expect(result, isA<Event>());
      verify(mockCollection.getOne('event123')).called(1);
    });

    test('should throw exception when event not found', () async {
      // Arrange
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.getOne('invalid'))
          .thenThrow(Exception('Event not found'));

      // Act & Assert
      expect(
        () => dataSource.getEventById('invalid'),
        throwsException,
      );
    });
  });

  group('AdminEventsRemoteDataSource - createEvent', () {
    test('should create event successfully with banner file', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockAuthStore.isValid).thenReturn(true);
      when(mockAuthStore.record).thenReturn(mockAuthRecord);

      when(mockCollection.create(
        body: anyNamed('body'),
        files: anyNamed('files'),
      )).thenAnswer((_) async => mockRecord);

      when(mockRecord.data).thenReturn({
        'id': 'new123',
        'title': 'New Event',
      });
      when(mockRecord.id).thenReturn('new123');

      final testData = {
        'title': 'New Event',
        'banner': http.MultipartFile.fromBytes('banner', [1, 2, 3]),
      };

      // Act
      final result = await dataSource.createEvent(testData);

      // Assert
      expect(result, isA<Event>());
      verify(mockCollection.create(
        body: argThat(containsPair('title', 'New Event'), named: 'body'),
        files: anyNamed('files'),
      )).called(1);
    });

    test('should add created_by when auth store is valid', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockAuthStore.isValid).thenReturn(true);
      when(mockAuthStore.record).thenReturn(mockAuthRecord);
      when(mockAuthRecord.id).thenReturn('user123');

      when(mockCollection.create(
        body: anyNamed('body'),
        files: anyNamed('files'),
      )).thenAnswer((_) async => mockRecord);

      when(mockRecord.data).thenReturn({'id': 'new'});
      when(mockRecord.id).thenReturn('new');

      final testData = {'title': 'Test'};

      // Act
      await dataSource.createEvent(testData);

      // Assert
      final captured = verify(mockCollection.create(
        body: captureAnyNamed('body'),
        files: anyNamed('files'),
      )).captured.single as Map<String, dynamic>;
      expect(captured['created_by'], 'user123');
    });

    test('should create event without banner file', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.create(
        body: anyNamed('body'),
        files: anyNamed('files'),
      )).thenAnswer((_) async => mockRecord);

      when(mockRecord.data).thenReturn({'id': 'new'});
      when(mockRecord.id).thenReturn('new');

      final testData = {'title': 'Test Event'};

      // Act
      final result = await dataSource.createEvent(testData);

      // Assert
      expect(result, isA<Event>());
    });
  });

  group('AdminEventsRemoteDataSource - updateEvent', () {
    test('should update event successfully', () async {
      // Arrange
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.update('event123', body: anyNamed('body')))
          .thenAnswer((_) async => mockRecord);

      final updateData = {'title': 'Updated Title'};

      // Act
      await dataSource.updateEvent('event123', updateData);

      // Assert
      verify(mockCollection.update(
        'event123',
        body: updateData,
      )).called(1);
    });

    test('should throw exception on update failure', () async {
      // Arrange
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.update('event123', body: anyNamed('body')))
          .thenThrow(Exception('Update failed'));

      // Act & Assert
      expect(
        () => dataSource.updateEvent('event123', {}),
        throwsException,
      );
    });
  });

  group('AdminEventsRemoteDataSource - deleteEvent', () {
    test('should delete event successfully', () async {
      // Arrange
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.delete('event123'))
          .thenAnswer((_) async => mockRecord);

      // Act
      await dataSource.deleteEvent('event123');

      // Assert
      verify(mockCollection.delete('event123')).called(1);
    });

    test('should throw exception on delete failure', () async {
      // Arrange
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.delete('event123'))
          .thenThrow(Exception('Delete failed'));

      // Act & Assert
      expect(
        () => dataSource.deleteEvent('event123'),
        throwsException,
      );
    });
  });

  group('AdminEventsRemoteDataSource - updateEventStatus', () {
    test('should update event status successfully', () async {
      // Arrange
      when(mockPb.collection('events')).thenReturn(mockCollection);
      when(mockCollection.update('event123', body: anyNamed('body')))
          .thenAnswer((_) async => mockRecord);

      // Act
      await dataSource.updateEventStatus('event123', 'published');

      // Assert
      verify(mockCollection.update(
        'event123',
        body: {'status': 'published'},
      )).called(1);
    });
  });

  group('AdminEventsRemoteDataSource - getEventStats', () {
    test('should return event stats with participants and income', () async {
      // Arrange
      final mockRecord1 = MockRecordModel();
      final mockRecord2 = MockRecordModel();
      when(mockPb.collection('event_bookings')).thenReturn(mockCollection);
      when(mockCollection.getFullList(filter: anyNamed('filter')))
          .thenAnswer((_) async => [mockRecord1, mockRecord2]);

      when(mockRecord1.data).thenReturn({
        'total_price': 100000,
        'display_price': 100000,
      });
      when(mockRecord2.data).thenReturn({
        'total_price': 150000,
        'display_price': 150000,
      });

      // Act
      final result = await dataSource.getEventStats('event123');

      // Assert
      expect(result['totalParticipants'], 2);
      expect(result['totalIncome'], 250000);
    });

    test('should return zero stats when no bookings', () async {
      // Arrange
      when(mockPb.collection('event_bookings')).thenReturn(mockCollection);
      when(mockCollection.getFullList(filter: anyNamed('filter')))
          .thenAnswer((_) async => []);

      // Act
      final result = await dataSource.getEventStats('event123');

      // Assert
      expect(result['totalParticipants'], 0);
      expect(result['totalIncome'], 0);
    });
  });

  group('AdminEventsRemoteDataSource - getEventBookings', () {
    test('should return list of bookings for event', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('event_bookings')).thenReturn(mockCollection);
      when(mockCollection.getList(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
        filter: anyNamed('filter'),
        sort: anyNamed('sort'),
        expand: anyNamed('expand'),
      )).thenAnswer((_) async => mockResultList([mockRecord]));

      when(mockRecord.data).thenReturn({
        'id': 'booking123',
        'event': 'event123',
        'user': 'user123',
      });
      when(mockRecord.id).thenReturn('booking123');

      // Act
      final result = await dataSource.getEventBookings('event123');

      // Assert
      expect(result, isA<List<EventBooking>>());
      verify(mockCollection.getList(
        page: 1,
        perPage: 500,
        filter: argThat(contains('event = "event123"'), named: 'filter'),
        sort: '-created',
        expand: 'user,event',
      )).called(1);
    });
  });

  group('AdminEventsRemoteDataSource - updateBookingStatus', () {
    test('should update booking status to paid', () async {
      // Arrange
      when(mockPb.collection('event_bookings')).thenReturn(mockCollection);
      when(mockCollection.update('booking123', body: anyNamed('body')))
          .thenAnswer((_) async => mockRecord);

      // Act
      await dataSource.updateBookingStatus('booking123', 'paid');

      // Assert
      final captured = verify(mockCollection.update(
        'booking123',
        body: captureAnyNamed('body'),
      )).captured.single as Map<String, dynamic>;

      expect(captured['payment_status'], 'paid');
      expect(captured.containsKey('payment_date'), isTrue);
    });

    test('should update booking status without payment_date for non-paid', () async {
      // Arrange
      when(mockPb.collection('event_bookings')).thenReturn(mockCollection);
      when(mockCollection.update('booking123', body: anyNamed('body')))
          .thenAnswer((_) async => mockRecord);

      // Act
      await dataSource.updateBookingStatus('booking123', 'pending');

      // Assert
      final captured = verify(mockCollection.update(
        'booking123',
        body: captureAnyNamed('body'),
      )).captured.single as Map<String, dynamic>;

      expect(captured['payment_status'], 'pending');
      expect(captured.containsKey('payment_date'), isFalse);
    });
  });

  group('AdminEventsRemoteDataSource - createEventTicket', () {
    test('should create event ticket successfully', () async {
      // Arrange
      when(mockPb.collection('event_tickets')).thenReturn(mockCollection);
      when(mockCollection.create(body: anyNamed('body')))
          .thenAnswer((_) async => mockRecord);

      final ticketData = {
        'event': 'event123',
        'name': 'Regular Ticket',
        'price': 50000,
      };

      // Act
      await dataSource.createEventTicket(ticketData);

      // Assert
      verify(mockCollection.create(body: ticketData)).called(1);
    });
  });

  group('AdminEventsRemoteDataSource - getEventTickets', () {
    test('should return list of tickets for event', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('event_tickets')).thenReturn(mockCollection);
      when(mockCollection.getList(filter: anyNamed('filter')))
          .thenAnswer((_) async => mockResultList([mockRecord]));

      when(mockRecord.data).thenReturn({
        'id': 'ticket123',
        'name': 'Regular',
        'price': 50000,
      });
      when(mockRecord.id).thenReturn('ticket123');

      // Act
      final result = await dataSource.getEventTickets('event123');

      // Assert
      expect(result, isA<List<EventTicket>>());
      verify(mockCollection.getList(
        filter: argThat(contains('event = "event123"'), named: 'filter'),
      )).called(1);
    });
  });

  group('AdminEventsRemoteDataSource - createManualBooking', () {
    test('should create manual booking successfully', () async {
      // Arrange
      when(mockPb.collection('event_bookings')).thenReturn(mockCollection);
      when(mockCollection.create(body: anyNamed('body')))
          .thenAnswer((_) async => mockRecord);

      final bookingData = {
        'event': 'event123',
        'user': 'user123',
        'payment_status': 'paid',
      };

      // Act
      await dataSource.createManualBooking(bookingData);

      // Assert
      verify(mockCollection.create(body: bookingData)).called(1);
    });
  });

  group('AdminEventsRemoteDataSource - getEventBookingTickets', () {
    test('should return tickets for booking', () async {
      // Arrange
      final mockRecord = MockRecordModel();
      when(mockPb.collection('event_booking_tickets')).thenReturn(mockCollection);
      when(mockCollection.getList(
        page: anyNamed('page'),
        perPage: anyNamed('perPage'),
        filter: anyNamed('filter'),
        expand: anyNamed('expand'),
      )).thenAnswer((_) async => mockResultList([mockRecord]));

      when(mockRecord.data).thenReturn({
        'id': 'ticket123',
        'booking': 'booking123',
      });
      when(mockRecord.id).thenReturn('ticket123');

      // Act
      final result = await dataSource.getEventBookingTickets('booking123');

      // Assert
      expect(result, isA<List<EventBookingTicket>>());
      verify(mockCollection.getList(
        page: 1,
        perPage: 100,
        filter: argThat(contains('booking = "booking123"'), named: 'filter'),
        expand: 'ticket_type,booking,booking.user,booking.event',
      )).called(1);
    });
  });
}

// Helper classes and functions
class MockPBClient {
  final PocketBase pb;
  final AuthStore authStore;

  MockPBClient(this.pb, this.authStore);
}

class MockAuthRecord {
  String id = 'test-user-id';
}

final mockAuthRecord = MockAuthRecord();

// Mock result list helper
ResultList<RecordModel> mockResultList(List<RecordModel> items) {
  return ResultList(
    items: items,
    totalItems: items.length,
    page: 1,
    perPage: items.length,
  );
}
