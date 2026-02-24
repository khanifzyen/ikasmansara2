import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_booking_ticket.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/get_event_booking_tickets.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'get_event_booking_tickets_test.mocks.dart';

void main() {
  late GetEventBookingTickets useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetEventBookingTickets(mockRepository);
  });

  group('GetEventBookingTickets UseCase', () {
    final tTickets = [
      EventBookingTicket(
        id: 't1',
        bookingId: 'bkg1',
        eventId: 'evt1',
        ticketName: 'VIP Ticket',
        ticketCode: 'TKT001',
        userName: 'John Doe',
        userEmail: 'john@example.com',
        options: {'seat': 'A1'},
      ),
      EventBookingTicket(
        id: 't2',
        bookingId: 'bkg1',
        eventId: 'evt1',
        ticketName: 'Regular Ticket',
        ticketCode: 'TKT002',
        userName: 'Jane Doe',
        userEmail: 'jane@example.com',
        options: {'seat': 'B2'},
      ),
    ];

    test('should get booking tickets from repository', () async {
      // Arrange
      when(mockRepository.getBookingTickets('bkg1'))
          .thenAnswer((_) async => tTickets);

      // Act
      final result = await useCase('bkg1');

      // Assert
      expect(result, equals(tTickets));
      expect(result.length, equals(2));
      verify(mockRepository.getBookingTickets('bkg1'));
    });

    test('should return empty list when no tickets', () async {
      // Arrange
      when(mockRepository.getBookingTickets('bkg2'))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('bkg2');

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Booking not found');
      when(mockRepository.getBookingTickets('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(() => useCase('invalid'), throwsA(exception));
    });
  });
}
