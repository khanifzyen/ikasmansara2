import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/network/pb_client.dart';
import '../../domain/entities/event_booking.dart';
import '../../domain/entities/event_booking_ticket.dart';
import '../../domain/entities/event.dart';
import '../../presentation/bloc/my_tickets_bloc.dart';
import 'package:intl/intl.dart';

class MyTicketDetailPage extends StatefulWidget {
  final String bookingId;
  final EventBooking? booking;

  const MyTicketDetailPage({super.key, required this.bookingId, this.booking});

  @override
  State<MyTicketDetailPage> createState() => _MyTicketDetailPageState();
}

class _MyTicketDetailPageState extends State<MyTicketDetailPage> {
  // Map to store ScreenshotControllers for each ticket
  final Map<String, ScreenshotController> _screenshotControllers = {};

  @override
  void initState() {
    super.initState();
    GetIt.I<MyTicketsBloc>().add(GetMyBookingTickets(widget.bookingId));
  }

  @override
  void dispose() {
    // Refresh bookings list when leaving detail page (back to list)
    try {
      final userId = GetIt.I<PBClient>().pb.authStore.record?.id;
      if (userId != null) {
        GetIt.I<MyTicketsBloc>().add(GetMyBookings(userId));
      }
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GetIt.I<MyTicketsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Tiket'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: BlocBuilder<MyTicketsBloc, MyTicketsState>(
          builder: (context, state) {
            if (state is MyTicketsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MyTicketsFailure) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is MyBookingTicketsLoaded) {
              if (state.tickets.isEmpty) {
                return const Center(child: Text('Tidak ada tiket ditemukan'));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Event Info Card
                    if (widget.booking?.event != null) ...[
                      _buildEventInfoCard(widget.booking!.event!),
                      const SizedBox(height: 24),
                      const Text(
                        'Tiket Anda',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tickets List
                    ...state.tickets.map((ticket) {
                      // Initialize controller if not exists
                      _screenshotControllers.putIfAbsent(
                        ticket.id,
                        () => ScreenshotController(),
                      );

                      return _buildTicketItem(
                        context,
                        ticket,
                        _screenshotControllers[ticket.id]!,
                      );
                    }),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTicketItem(
    BuildContext context,
    EventBookingTicket ticket,
    ScreenshotController screenshotController,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Screenshot(
            controller: screenshotController,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Ticket Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF006D4E),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.ticketName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ticket.ticketCode,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ticket Body / QR
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        QrImageView(
                          data: ticket.ticketCode, // Use Readable Ticket ID
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.ticketCode,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ticket.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _shareTicket(ticket, screenshotController),
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Bagikan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur Print via Bluetooth segera hadir'),
                    ),
                  );
                },
                icon: const Icon(Icons.print, size: 18),
                label: const Text('Cetak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoCard(Event event) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(event.date.toLocal()),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.location,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _shareTicket(
    EventBookingTicket ticket,
    ScreenshotController controller,
  ) async {
    try {
      final image = await controller.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/ticket_${ticket.ticketCode}.png',
      ).create();
      await imagePath.writeAsBytes(image);

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(imagePath.path)],
            text:
                'Ini tiket saya untuk event ini: ${ticket.ticketName} (${ticket.ticketCode})',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sharing ticket: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membagikan tiket: $e')));
      }
    }
  }
}
