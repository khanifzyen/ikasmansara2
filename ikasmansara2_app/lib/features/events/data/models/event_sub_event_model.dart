// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/event_sub_event.dart';

part 'event_sub_event_model.freezed.dart';
part 'event_sub_event_model.g.dart';

@freezed
abstract class EventSubEventModel with _$EventSubEventModel {
  const EventSubEventModel._();

  const factory EventSubEventModel({
    required String id,
    @JsonKey(name: 'event') required String eventId,
    required String title,
    required String description,
    required int quota,
    required int registered,
    String? image,
    required DateTime created,
    required DateTime updated,
  }) = _EventSubEventModel;

  factory EventSubEventModel.fromJson(Map<String, dynamic> json) =>
      _$EventSubEventModelFromJson(json);

  factory EventSubEventModel.fromRecord(RecordModel record) {
    return EventSubEventModel(
      id: record.id,
      eventId: record.getStringValue('event'),
      title: record.getStringValue('title'),
      description: record.getStringValue('description'),
      quota: record.getIntValue('quota'),
      registered: record.getIntValue('registered'),
      image: record.getStringValue('image'),
      created:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updated:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }

  EventSubEvent toEntity() {
    return EventSubEvent(
      id: id,
      eventId: eventId,
      title: title,
      description: description,
      quota: quota,
      registered: registered,
      image: image,
    );
  }
}
