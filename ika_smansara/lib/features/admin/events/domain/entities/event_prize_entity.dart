import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_prize_entity.freezed.dart';

@freezed
sealed class EventPrizeEntity with _$EventPrizeEntity {
  const factory EventPrizeEntity({
    required String id,
    required String eventId,
    required String name,
    required int quantity,
    String? imageUrl,
  }) = _EventPrizeEntity;
}
