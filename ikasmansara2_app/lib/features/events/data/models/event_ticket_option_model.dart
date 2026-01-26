// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/event_ticket_option.dart';

part 'event_ticket_option_model.freezed.dart';
part 'event_ticket_option_model.g.dart';

@freezed
abstract class EventTicketOptionModel with _$EventTicketOptionModel {
  const EventTicketOptionModel._();

  const factory EventTicketOptionModel({
    required String id,
    @JsonKey(name: 'ticket') required String ticketId,
    required String name,
    required List<TicketOptionChoice> choices,
  }) = _EventTicketOptionModel;

  factory EventTicketOptionModel.fromJson(Map<String, dynamic> json) =>
      _$EventTicketOptionModelFromJson(json);

  factory EventTicketOptionModel.fromRecord(RecordModel record) {
    final choicesJson = record.data['choices'] as List<dynamic>? ?? [];
    final choices = choicesJson
        .map((e) => TicketOptionChoice.fromJson(e as Map<String, dynamic>))
        .toList();

    return EventTicketOptionModel(
      id: record.id,
      ticketId: record.getStringValue('ticket'),
      name: record.getStringValue('name'),
      choices: choices,
    );
  }

  EventTicketOption toEntity() {
    return EventTicketOption(
      id: id,
      ticketId: ticketId,
      name: name,
      choices: choices,
    );
  }
}
