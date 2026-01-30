// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/event_sponsor.dart';

part 'event_sponsor_model.freezed.dart';
part 'event_sponsor_model.g.dart';

@freezed
abstract class EventSponsorModel with _$EventSponsorModel {
  const EventSponsorModel._();

  const factory EventSponsorModel({
    required String id,
    @JsonKey(name: 'event') required String eventId,
    required String name,
    required String type,
    required int price,
    required List<String> benefits,
    required DateTime created,
    required DateTime updated,
  }) = _EventSponsorModel;

  factory EventSponsorModel.fromJson(Map<String, dynamic> json) =>
      _$EventSponsorModelFromJson(json);

  factory EventSponsorModel.fromRecord(RecordModel record) {
    return EventSponsorModel(
      id: record.id,
      eventId: record.getStringValue('event'),
      name: record.getStringValue('name'),
      type: record.getStringValue('type'),
      price: record.getIntValue('price'),
      benefits:
          (record.data['benefits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      created:
          DateTime.tryParse(record.getStringValue('created')) ?? DateTime.now(),
      updated:
          DateTime.tryParse(record.getStringValue('updated')) ?? DateTime.now(),
    );
  }

  EventSponsor toEntity() {
    return EventSponsor(
      id: id,
      eventId: eventId,
      name: name,
      type: type,
      price: price,
      benefits: benefits,
    );
  }
}
