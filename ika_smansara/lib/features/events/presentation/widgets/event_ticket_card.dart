import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../../domain/entities/event_booking.dart';
import '../../domain/entities/event_booking_ticket.dart';

class EventTicketCard extends StatelessWidget {
  final EventBooking booking;
  final EventBookingTicket ticket;
  final ScreenshotController screenshotController;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  const EventTicketCard({
    super.key,
    required this.booking,
    required this.ticket,
    required this.screenshotController,
    this.onShare,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Screenshot(
          controller: screenshotController,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                const Text(
                  'IKA SMANSARA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1, color: Colors.black),
                const SizedBox(height: 8),
                Text(
                  booking.event?.title ?? 'Event',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${DateFormat('EEEE, d MMM yyyy', 'id').format(booking.event?.date.toLocal() ?? DateTime.now())} - ${booking.event?.time ?? '-'}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  booking.event?.location ?? '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
                const Divider(height: 24),
                _buildTicketRow('TIKET', ticket.ticketName),
                _buildTicketRow(
                  'NAMA',
                  (booking.registrationChannel == 'app' ||
                          booking.userId.isNotEmpty)
                      ? (ticket.userName.isNotEmpty
                            ? ticket.userName
                            : 'Peserta')
                      : "(Koord) ${booking.coordinatorName ?? '-'}",
                ),
                () {
                  final displayOptions =
                      (booking.registrationChannel == 'app' ||
                          booking.userId.isNotEmpty)
                      ? ticket.options.values.join(', ')
                      : (booking.notes ?? '-');
                  if (displayOptions.isNotEmpty && displayOptions != '-') {
                    return _buildTicketRow('OPSI', displayOptions);
                  }
                  return const SizedBox.shrink();
                }(),
                const Divider(height: 24),
                QrImageView(
                  data: '${ticket.id}:${ticket.ticketCode}',
                  version: QrVersions.auto,
                  size: 150.0,
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.ticketCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Simpan sebagai bukti masuk.',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
        if (onShare != null || onPrint != null) const SizedBox(height: 12),
        if (onShare != null || onPrint != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onShare != null)
                TextButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                ),
              if (onShare != null && onPrint != null) const SizedBox(width: 16),
              if (onPrint != null)
                TextButton.icon(
                  onPressed: onPrint,
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Print'),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
