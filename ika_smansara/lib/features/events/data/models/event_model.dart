// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/event.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
abstract class EventModel with _$EventModel {
  const EventModel._();

  const factory EventModel({
    required String id,
    required String title,
    required String description,
    required DateTime date,
    required String time,
    required String location,
    String? banner,
    required String status,
    required DateTime created,
    required DateTime updated,
    required String code,
    @Default(false) bool enableSponsorship,
    @Default(false) bool enableDonation,
    double? donationTarget,
    String? donationDescription,
    required String bookingIdFormat,
    required String ticketIdFormat,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  factory EventModel.fromRecord(RecordModel record) {
    try {
      return EventModel(
        id: record.id,
        title: record.getStringValue('title'),
        description: record.getStringValue('description'),
        date:
            DateTime.tryParse(record.getStringValue('date')) ?? DateTime.now(),
        time: record.getStringValue('time'),
        location: record.getStringValue('location'),
        banner: record.getStringValue('banner'),
        status: record.getStringValue('status'),
        created:
            DateTime.tryParse(record.getStringValue('created')) ??
            DateTime.now(),
        updated:
            DateTime.tryParse(record.getStringValue('updated')) ??
            DateTime.now(),
        code: record.getStringValue('code'),
        enableSponsorship: record.getBoolValue('enable_sponsorship'),
        enableDonation: record.getBoolValue('enable_donation'),
        donationTarget: record.data['donation_target']?.toDouble(),
        donationDescription: record.getStringValue('donation_description'),
        bookingIdFormat: record.getStringValue('booking_id_format'),
        ticketIdFormat: record.getStringValue('ticket_id_format'),
      );
    } catch (e) {
      debugPrint('DEBUG: Error parsing dates for event ${record.id}: $e');
      rethrow;
    }
  }

  Event toEntity() {
    String? bannerUrl;
    if (banner != null && banner!.isNotEmpty) {
      bannerUrl = '${AppConstants.pocketBaseUrl}/api/files/events/$id/$banner';
    }

    return Event(
      id: id,
      title: title,
      description: description,
      date: date,
      time: time,
      location: location,
      banner: bannerUrl,
      status: status,
      created: created,
      updated: updated,
      code: code,
      enableSponsorship: enableSponsorship,
      enableDonation: enableDonation,
      donationTarget: donationTarget,
      donationDescription: donationDescription,
      bookingIdFormat: bookingIdFormat,
      ticketIdFormat: ticketIdFormat,
    );
  }
}
