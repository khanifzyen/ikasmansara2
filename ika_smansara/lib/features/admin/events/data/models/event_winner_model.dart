// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/event_winner_entity.dart';

import 'package:pocketbase/pocketbase.dart';

part 'event_winner_model.freezed.dart';
part 'event_winner_model.g.dart';

@freezed
abstract class EventWinnerModel with _$EventWinnerModel {
  const factory EventWinnerModel({
    required String id,
    required String event,
    required String prize,
    required String booking_ticket,
    String? ticketCode,
    String? userName,
    String? created,
    String? updated,
  }) = _EventWinnerModel;

  factory EventWinnerModel.fromJson(Map<String, dynamic> json) =>
      _$EventWinnerModelFromJson(json);

  factory EventWinnerModel.fromRecord(RecordModel record) {
    String? ticketCode;
    String? userName;

    try {
      final expandedTicketList = record.get<List<RecordModel>>(
        'expand.booking_ticket',
      );
      if (expandedTicketList.isNotEmpty) {
        final expandedTicket = expandedTicketList.first;
        ticketCode = expandedTicket.getStringValue('ticket_id');

        final expandedBookingList = expandedTicket.get<List<RecordModel>>(
          'expand.booking',
        );
        if (expandedBookingList.isNotEmpty) {
          final expandedBooking = expandedBookingList.first;

          final expandedUserList = expandedBooking.get<List<RecordModel>>(
            'expand.user',
          );
          if (expandedUserList.isNotEmpty) {
            final name = expandedUserList.first.getStringValue('name');
            if (name.isNotEmpty) userName = name;
          }

          if (userName == null || userName.isEmpty) {
            final coordinatorName = expandedBooking.getStringValue(
              'coordinator_name',
            );
            if (coordinatorName.isNotEmpty) {
              userName = coordinatorName;
            }
          }
        }
      }
    } catch (_) {}

    return EventWinnerModel(
      id: record.id,
      event: record.getStringValue('event'),
      prize: record.getStringValue('prize'),
      booking_ticket: record.getStringValue('booking_ticket'),
      ticketCode: ticketCode,
      userName: userName ?? 'Tanpa Nama',
      created: record.created,
      updated: record.updated,
    );
  }

  const EventWinnerModel._();

  EventWinnerEntity toEntity() {
    return EventWinnerEntity(
      id: id,
      eventId: event,
      prizeId: prize,
      bookingTicketId: booking_ticket,
      ticketCode: ticketCode,
      userName: userName,
    );
  }

  factory EventWinnerModel.fromEntity(EventWinnerEntity entity) {
    return EventWinnerModel(
      id: entity.id,
      event: entity.eventId,
      prize: entity.prizeId,
      booking_ticket: entity.bookingTicketId,
      ticketCode: entity.ticketCode,
      userName: entity.userName,
    );
  }
}
