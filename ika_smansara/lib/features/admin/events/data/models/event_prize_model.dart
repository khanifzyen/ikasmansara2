// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/event_prize_entity.dart';

part 'event_prize_model.freezed.dart';
part 'event_prize_model.g.dart';

@freezed
abstract class EventPrizeModel with _$EventPrizeModel {
  const factory EventPrizeModel({
    required String id,
    required String event,
    required String name,
    required int quantity,
  }) = _EventPrizeModel;

  factory EventPrizeModel.fromJson(Map<String, dynamic> json) =>
      _$EventPrizeModelFromJson(json);

  factory EventPrizeModel.fromRecord(RecordModel record) {
    return EventPrizeModel(
      id: record.id,
      event: record.getStringValue('event'),
      name: record.getStringValue('name'),
      quantity: record.getIntValue('quantity'),
    );
  }

  const EventPrizeModel._();

  EventPrizeEntity toEntity() => EventPrizeEntity(
        id: id,
        eventId: event,
        name: name,
        quantity: quantity,
      );

  factory EventPrizeModel.fromEntity(EventPrizeEntity entity) => EventPrizeModel(
        id: entity.id,
        event: entity.eventId,
        name: entity.name,
        quantity: entity.quantity,
      );
}
