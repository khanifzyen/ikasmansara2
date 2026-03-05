// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
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
    String? image,
    String? created,
    String? updated,
  }) = _EventPrizeModel;

  factory EventPrizeModel.fromJson(Map<String, dynamic> json) =>
      _$EventPrizeModelFromJson(json);

  const EventPrizeModel._();

  EventPrizeEntity toEntity() {
    return EventPrizeEntity(
      id: id,
      eventId: event,
      name: name,
      quantity: quantity,
      imageUrl: image, // Nanti dikonversi ke URL lengkap di level repository
    );
  }

  factory EventPrizeModel.fromEntity(EventPrizeEntity entity) {
    return EventPrizeModel(
      id: entity.id,
      event: entity.eventId,
      name: entity.name,
      quantity: entity.quantity,
    );
  }
}
