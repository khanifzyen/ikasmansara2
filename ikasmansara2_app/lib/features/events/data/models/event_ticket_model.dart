// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/event_ticket.dart';
import '../../domain/entities/event_ticket_option.dart';

part 'event_ticket_model.freezed.dart';
part 'event_ticket_model.g.dart';

@freezed
abstract class EventTicketModel with _$EventTicketModel {
  const EventTicketModel._();

  const factory EventTicketModel({
    required String id,
    @JsonKey(name: 'event') required String eventId,
    required String name,
    required String description,
    required int price,
    required int quota,
    required int sold,
    @JsonKey(name: 'quota_status') String? quotaStatus,
    required DateTime created,
    required DateTime updated,
  }) = _EventTicketModel;

  factory EventTicketModel.fromJson(Map<String, dynamic> json) =>
      _$EventTicketModelFromJson(json);

  factory EventTicketModel.fromRecord(RecordModel record) {
    return EventTicketModel(
      id: record.id,
      eventId: record.getStringValue('event'),
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      price: record.getIntValue('price'),
      quota: record.getIntValue('quota'),
      sold: record.getIntValue('sold'),
      quotaStatus: record.getStringValue('quota_status'),
      created:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updated:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }

  EventTicket toEntity({List<EventTicketOption> options = const []}) {
    return EventTicket(
      id: id,
      eventId: eventId,
      name: name,
      description: description,
      price: price,
      quota: quota,
      sold: sold,
      quotaStatus: quotaStatus,
      options: options,
    );
  }
}
