import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_winner_entity.freezed.dart';

@freezed
sealed class EventWinnerEntity with _$EventWinnerEntity {
  const factory EventWinnerEntity({
    required String id,
    required String eventId,
    required String prizeName,
    required String bookingTicketId,
    required String status,
    String? ticketCode,
    String? userName,
  }) = _EventWinnerEntity;
}
