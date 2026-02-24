import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/events/domain/entities/event_ticket.dart';
import 'package:ika_smansara/features/events/domain/entities/event_ticket_option.dart';

void main() {
  group('TicketOptionChoice', () {
    test('should create TicketOptionChoice instance correctly', () {
      // Arrange & Act
      final choice = TicketOptionChoice(
        label: 'Regular',
        extraPrice: 0,
      );

      // Assert
      expect(choice.label, equals('Regular'));
      expect(choice.extraPrice, equals(0));
    });

    test('should handle choices with extra price', () {
      // Arrange & Act
      final vipChoice = TicketOptionChoice(
        label: 'VIP Access',
        extraPrice: 500000,
      );

      // Assert
      expect(vipChoice.label, equals('VIP Access'));
      expect(vipChoice.extraPrice, equals(500000));
    });

    test('should create from JSON correctly', () {
      // Arrange
      final json = {
        'label': 'Premium',
        'extra_price': 250000,
      };

      // Act
      final choice = TicketOptionChoice.fromJson(json);

      // Assert
      expect(choice.label, equals('Premium'));
      expect(choice.extraPrice, equals(250000));
    });

    test('should handle JSON with null extra_price', () {
      // Arrange
      final json = {
        'label': 'Standard',
        'extra_price': null,
      };

      // Act
      final choice = TicketOptionChoice.fromJson(json);

      // Assert
      expect(choice.label, equals('Standard'));
      expect(choice.extraPrice, equals(0));
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final choice = TicketOptionChoice(
        label: 'Deluxe',
        extraPrice: 100000,
      );

      // Act
      final json = choice.toJson();

      // Assert
      expect(json['label'], equals('Deluxe'));
      expect(json['extra_price'], equals(100000));
    });

    test('should handle double values in JSON', () {
      // Arrange
      final json = {
        'label': 'Test',
        'extra_price': 150000.5,
      };

      // Act
      final choice = TicketOptionChoice.fromJson(json);

      // Assert
      expect(choice.extraPrice, equals(150000)); // Should truncate to int
    });

    test('should implement Equatable', () {
      // Arrange
      final choice1 = TicketOptionChoice(
        label: 'Regular',
        extraPrice: 0,
      );
      final choice2 = TicketOptionChoice(
        label: 'Regular',
        extraPrice: 0,
      );
      final choice3 = TicketOptionChoice(
        label: 'VIP',
        extraPrice: 500000,
      );

      // Assert
      expect(choice1, equals(choice2));
      expect(choice1, isNot(equals(choice3)));
    });

    test('should have correct props', () {
      // Arrange
      final choice = TicketOptionChoice(
        label: 'Test',
        extraPrice: 100000,
      );

      // Assert
      expect(choice.props, equals(['Test', 100000]));
    });
  });

  group('EventTicketOption', () {
    test('should create EventTicketOption instance correctly', () {
      // Arrange
      final choices = [
        TicketOptionChoice(label: 'Regular', extraPrice: 0),
        TicketOptionChoice(label: 'VIP', extraPrice: 500000),
      ];

      // Act
      final option = EventTicketOption(
        id: 'opt1',
        ticketId: 'ticket1',
        name: 'Seat Type',
        choices: choices,
      );

      // Assert
      expect(option.id, equals('opt1'));
      expect(option.ticketId, equals('ticket1'));
      expect(option.name, equals('Seat Type'));
      expect(option.choices, hasLength(2));
    });

    test('should handle empty choices list', () {
      // Arrange & Act
      final option = EventTicketOption(
        id: 'opt1',
        ticketId: 'ticket1',
        name: 'T-Shirt Size',
        choices: [],
      );

      // Assert
      expect(option.choices, isEmpty);
    });

    test('should handle single choice', () {
      // Arrange
      final singleChoice = [
        TicketOptionChoice(label: 'Standard', extraPrice: 0),
      ];

      // Act
      final option = EventTicketOption(
        id: 'opt1',
        ticketId: 'ticket1',
        name: 'Meal Option',
        choices: singleChoice,
      );

      // Assert
      expect(option.choices, hasLength(1));
      expect(option.choices.first.label, equals('Standard'));
    });

    test('should implement Equatable', () {
      // Arrange
      final choices1 = [
        TicketOptionChoice(label: 'Regular', extraPrice: 0),
      ];
      final choices2 = [
        TicketOptionChoice(label: 'Regular', extraPrice: 0),
      ];
      final option1 = EventTicketOption(
        id: 'opt1',
        ticketId: 'ticket1',
        name: 'Option 1',
        choices: choices1,
      );
      final option2 = EventTicketOption(
        id: 'opt1',
        ticketId: 'ticket1',
        name: 'Option 1',
        choices: choices2,
      );
      final option3 = EventTicketOption(
        id: 'opt2',
        ticketId: 'ticket1',
        name: 'Option 2',
        choices: [],
      );

      // Assert
      expect(option1, equals(option2));
      expect(option1, isNot(equals(option3)));
    });

    test('should have correct props', () {
      // Arrange
      final choices = [TicketOptionChoice(label: 'Test', extraPrice: 0)];
      final option = EventTicketOption(
        id: 'opt1',
        ticketId: 'ticket1',
        name: 'Test Option',
        choices: choices,
      );

      // Assert
      expect(option.props, equals(['opt1', 'ticket1', 'Test Option', choices]));
    });
  });

  group('EventTicket', () {
    test('should create EventTicket instance correctly', () {
      // Arrange
      final options = [
        EventTicketOption(
          id: 'opt1',
          ticketId: 'ticket1',
          name: 'T-Shirt Size',
          choices: [
            TicketOptionChoice(label: 'S', extraPrice: 0),
            TicketOptionChoice(label: 'M', extraPrice: 0),
            TicketOptionChoice(label: 'L', extraPrice: 0),
          ],
        ),
      ];

      // Act
      final ticket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Regular Ticket',
        description: 'Standard access to all sessions',
        price: 250000,
        quota: 100,
        sold: 45,
        quotaStatus: 'available',
        options: options,
        includes: ['Conference access', 'Lunch', 'Certificate'],
      );

      // Assert
      expect(ticket.id, equals('ticket1'));
      expect(ticket.eventId, equals('event1'));
      expect(ticket.name, equals('Regular Ticket'));
      expect(ticket.description, equals('Standard access to all sessions'));
      expect(ticket.price, equals(250000));
      expect(ticket.quota, equals(100));
      expect(ticket.sold, equals(45));
      expect(ticket.quotaStatus, equals('available'));
      expect(ticket.options, hasLength(1));
      expect(ticket.includes, hasLength(3));
    });

    test('should create EventTicket with minimal parameters', () {
      // Arrange & Act
      final minimalTicket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Free Ticket',
        description: 'No description',
        price: 0,
        quota: 50,
        sold: 0,
      );

      // Assert
      expect(minimalTicket.quotaStatus, isNull);
      expect(minimalTicket.options, isEmpty);
      expect(minimalTicket.includes, isEmpty);
    });

    test('should handle sold out status', () {
      // Arrange & Act
      final soldOutTicket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'VIP Ticket',
        description: 'Sold out',
        price: 1000000,
        quota: 50,
        sold: 50,
        quotaStatus: 'sold_out',
      );

      // Assert
      expect(soldOutTicket.quotaStatus, equals('sold_out'));
      expect(soldOutTicket.sold, equals(soldOutTicket.quota));
    });

    test('should handle limited status', () {
      // Arrange & Act
      final limitedTicket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Early Bird',
        description: 'Limited seats left',
        price: 200000,
        quota: 100,
        sold: 85,
        quotaStatus: 'limited',
      );

      // Assert
      expect(limitedTicket.quotaStatus, equals('limited'));
      expect(limitedTicket.sold, greaterThan(limitedTicket.quota * 0.8));
    });

    test('should handle free ticket', () {
      // Arrange & Act
      final freeTicket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Community Pass',
        description: 'Free entry',
        price: 0,
        quota: 500,
        sold: 200,
        quotaStatus: 'available',
      );

      // Assert
      expect(freeTicket.price, equals(0));
      expect(freeTicket.quota, equals(500));
    });

    test('should handle multiple options', () {
      // Arrange
      final options = [
        EventTicketOption(
          id: 'opt1',
          ticketId: 'ticket1',
          name: 'T-Shirt Size',
          choices: [
            TicketOptionChoice(label: 'S', extraPrice: 0),
            TicketOptionChoice(label: 'M', extraPrice: 0),
            TicketOptionChoice(label: 'L', extraPrice: 0),
          ],
        ),
        EventTicketOption(
          id: 'opt2',
          ticketId: 'ticket1',
          name: 'Meal Preference',
          choices: [
            TicketOptionChoice(label: 'Regular', extraPrice: 0),
            TicketOptionChoice(label: 'Vegetarian', extraPrice: 0),
            TicketOptionChoice(label: 'Vegan', extraPrice: 50000),
          ],
        ),
      ];

      // Act
      final ticket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Premium Ticket',
        description: 'With options',
        price: 500000,
        quota: 50,
        sold: 25,
        options: options,
      );

      // Assert
      expect(ticket.options, hasLength(2));
      expect(ticket.options[0].name, equals('T-Shirt Size'));
      expect(ticket.options[1].name, equals('Meal Preference'));
    });

    test('should handle empty includes list', () {
      // Arrange & Act
      final ticket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Basic Ticket',
        description: 'No extras',
        price: 100000,
        quota: 100,
        sold: 50,
        includes: [],
      );

      // Assert
      expect(ticket.includes, isEmpty);
    });

    test('should implement Equatable', () {
      // Arrange
      final ticket1 = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Ticket',
        description: 'Desc',
        price: 100000,
        quota: 50,
        sold: 25,
        quotaStatus: 'available',
        options: [],
        includes: ['Access'],
      );
      final ticket2 = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Ticket',
        description: 'Desc',
        price: 100000,
        quota: 50,
        sold: 25,
        quotaStatus: 'available',
        options: [],
        includes: ['Access'],
      );
      final ticket3 = EventTicket(
        id: 'ticket2',
        eventId: 'event1',
        name: 'Different',
        description: 'Desc',
        price: 200000,
        quota: 30,
        sold: 15,
      );

      // Assert
      expect(ticket1, equals(ticket2));
      expect(ticket1, isNot(equals(ticket3)));
    });

    test('should have correct props', () {
      // Arrange
      final options = [
        EventTicketOption(
          id: 'opt1',
          ticketId: 'ticket1',
          name: 'Option',
          choices: [TicketOptionChoice(label: 'Test', extraPrice: 0)],
        ),
      ];
      final ticket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Test Ticket',
        description: 'Test',
        price: 100000,
        quota: 50,
        sold: 25,
        quotaStatus: 'available',
        options: options,
        includes: ['Include1', 'Include2'],
      );

      // Assert
      expect(ticket.props, equals([
        'ticket1',
        'event1',
        'Test Ticket',
        'Test',
        100000,
        50,
        25,
        'available',
        options,
        ['Include1', 'Include2'],
      ]));
    });

    test('should handle large quota and sold values', () {
      // Arrange & Act
      final largeTicket = EventTicket(
        id: 'ticket1',
        eventId: 'event1',
        name: 'Massive Event',
        description: 'Big scale',
        price: 50000,
        quota: 10000,
        sold: 8500,
        quotaStatus: 'limited',
      );

      // Assert
      expect(largeTicket.quota, equals(10000));
      expect(largeTicket.sold, equals(8500));
    });
  });
}
