import 'package:equatable/equatable.dart';

class EventTicketOption extends Equatable {
  final String id;
  final String ticketId;
  final String name;
  final List<TicketOptionChoice> choices;

  const EventTicketOption({
    required this.id,
    required this.ticketId,
    required this.name,
    required this.choices,
  });

  @override
  List<Object?> get props => [id, ticketId, name, choices];
}

class TicketOptionChoice extends Equatable {
  final String label;
  final int extraPrice;

  const TicketOptionChoice({required this.label, required this.extraPrice});

  factory TicketOptionChoice.fromJson(Map<String, dynamic> json) {
    return TicketOptionChoice(
      label: json['label'] as String,
      extraPrice: (json['extra_price'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'extra_price': extraPrice};
  }

  @override
  List<Object?> get props => [label, extraPrice];
}
