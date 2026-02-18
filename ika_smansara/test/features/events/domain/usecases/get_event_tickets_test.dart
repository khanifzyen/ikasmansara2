import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_ticket.dart';
import 'package:ika_smansara/features/events/domain/entities/event_ticket_option.dart';
import 'package:ika_smansara/features/events/domain/repositories/event_repository.dart';
import 'package:ika_smansara/features/events/domain/usecases/get_event_tickets.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<EventRepository>()])
import 'get_event_tickets_test.mocks.dart';

void main() {
  late GetEventTickets useCase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    useCase = GetEventTickets(mockRepository);
  });

  group('GetEventTickets UseCase', () {
    final tTicketsList = [
      EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Regular Ticket',
        description: 'Standard access',
        price: 250000,
        quota: 100,
        sold: 45,
        quotaStatus: 'available',
        options: [],
        includes: ['Conference access', 'Lunch'],
      ),
      EventTicket(
        id: 'ticket2',
        eventId: 'event1',
        name: 'VIP Ticket',
        description: 'Premium access',
        price: 1000000,
        quota: 50,
        sold: 30,
        quotaStatus: 'available',
        options: [
          EventTicketOption(
            id: 'opt1',
            ticketId: 'ticket2',
            name: 'T-Shirt Size',
            choices: [
              TicketOptionChoice(label: 'S', extraPrice: 0),
              TicketOptionChoice(label: 'M', extraPrice: 0),
              TicketOptionChoice(label: 'L', extraPrice: 0),
            ],
          ),
        ],
        includes: ['Conference access', 'Lunch', 'VIP dinner', 'Goodie bag'],
      ),
    ];

    test('should get tickets list from repository', () async {
      // Arrange
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => tTicketsList);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, equals(tTicketsList));
      expect(result, hasLength(2));
      expect(result.first.name, equals('Regular Ticket'));
      verify(mockRepository.getEventTickets('event1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no tickets', () async {
      // Arrange
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getEventTickets('event1'));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to load tickets');
      when(mockRepository.getEventTickets('event1'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('event1'),
        throwsA(exception),
      );
      verify(mockRepository.getEventTickets('event1'));
    });

    test('should handle single ticket', () async {
      // Arrange
      final singleTicket = [tTicketsList.first];
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => singleTicket);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, hasLength(1));
      expect(result.first.price, equals(250000));
    });

    test('should handle tickets with different quota statuses', () async {
      // Arrange
      final mixedStatusTickets = [
        EventTicket(
          id: 'ticket1',
          eventId: 'event1',
          name: 'Available Ticket',
          description: 'Available',
          price: 100000,
          quota: 100,
          sold: 20,
          quotaStatus: 'available',
        ),
        EventTicket(
          id: 'ticket2',
          eventId: 'event1',
          name: 'Limited Ticket',
          description: 'Limited',
          price: 150000,
          quota: 50,
          sold: 40,
          quotaStatus: 'limited',
        ),
        EventTicket(
          id: 'ticket3',
          eventId: 'event1',
          name: 'Sold Out Ticket',
          description: 'Sold out',
          price: 200000,
          quota: 30,
          sold: 30,
          quotaStatus: 'sold_out',
        ),
      ];
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => mixedStatusTickets);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result, hasLength(3));
      expect(result[0].quotaStatus, equals('available'));
      expect(result[1].quotaStatus, equals('limited'));
      expect(result[2].quotaStatus, equals('sold_out'));
    });

    test('should handle free tickets', () async {
      // Arrange
      final freeTickets = [
        EventTicket(
          id: 'ticket1',
          eventId: 'event1',
          name: 'Community Pass',
          description: 'Free entry',
          price: 0,
          quota: 500,
          sold: 200,
          quotaStatus: 'available',
          includes: ['Access only'],
        ),
      ];
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => freeTickets);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result.first.price, equals(0));
    });

    test('should handle tickets with options', () async {
      // Arrange
      final ticketsWithOptions = [
        EventTicket(
          id: 'ticket1',
          eventId: 'event1',
          name: 'Customizable Ticket',
          description: 'With options',
          price: 500000,
          quota: 50,
          sold: 25,
          options: [
            EventTicketOption(
              id: 'opt1',
              ticketId: 'ticket1',
              name: 'T-Shirt Size',
              choices: [
                TicketOptionChoice(label: 'S', extraPrice: 0),
                TicketOptionChoice(label: 'M', extraPrice: 0),
                TicketOptionChoice(label: 'L', extraPrice: 10000),
              ],
            ),
            EventTicketOption(
              id: 'opt2',
              ticketId: 'ticket1',
              name: 'Meal',
              choices: [
                TicketOptionChoice(label: 'Regular', extraPrice: 0),
                TicketOptionChoice(label: 'Premium', extraPrice: 50000),
              ],
            ),
          ],
        ),
      ];
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => ticketsWithOptions);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result.first.options, hasLength(2));
      expect(result.first.options[0].name, equals('T-Shirt Size'));
      expect(result.first.options[1].name, equals('Meal'));
    });

    test('should handle different event IDs', () async {
      // Arrange
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => tTicketsList);
      when(mockRepository.getEventTickets('event2'))
          .thenAnswer((_) async => []);

      // Act
      final result1 = await useCase('event1');
      final result2 = await useCase('event2');

      // Assert
      expect(result1, hasLength(2));
      expect(result2, isEmpty);
      verify(mockRepository.getEventTickets('event1'));
      verify(mockRepository.getEventTickets('event2'));
    });

    test('should call repository only once', () async {
      // Arrange
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => tTicketsList);

      // Act
      await useCase('event1');

      // Assert
      verify(mockRepository.getEventTickets('event1')).called(1);
    });

    test('should preserve ticket order from repository', () async {
      // Arrange
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => tTicketsList);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result.first.id, equals('ticket1'));
      expect(result.last.id, equals('ticket2'));
    });

    test('should handle tickets with and without includes', () async {
      // Arrange
      final mixedIncludesTickets = [
        EventTicket(
          id: 'ticket1',
          eventId: 'event1',
          name: 'Full Package',
          description: 'All inclusive',
          price: 500000,
          quota: 50,
          sold: 25,
          includes: ['Access', 'Lunch', 'Dinner', 'Merchandise'],
        ),
        EventTicket(
          id: 'ticket2',
          eventId: 'event1',
          name: 'Basic Ticket',
          description: 'Access only',
          price: 100000,
          quota: 100,
          sold: 50,
          includes: [],
        ),
      ];
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => mixedIncludesTickets);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result.first.includes, hasLength(4));
      expect(result.last.includes, isEmpty);
    });

    test('should handle tickets without quota status', () async {
      // Arrange
      final noStatusTickets = [
        EventTicket(
          id: 'ticket1',
          eventId: 'event1',
          name: 'Early Bird',
          description: 'No status',
          price: 200000,
          quota: 100,
          sold: 30,
        ),
      ];
      when(mockRepository.getEventTickets('event1'))
          .thenAnswer((_) async => noStatusTickets);

      // Act
      final result = await useCase('event1');

      // Assert
      expect(result.first.quotaStatus, isNull);
    });
  });
}
