import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/network/pb_client.dart';
import '../../../../core/services/printer_service.dart';
import '../../../settings/domain/usecases/get_printer_settings.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/event_booking.dart';
import '../../domain/entities/event_booking_ticket.dart';
import '../../domain/entities/event.dart';
import '../widgets/event_ticket_card.dart';
import '../../presentation/bloc/my_tickets_bloc.dart';

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
      child: BlocBuilder<MyTicketsBloc, MyTicketsState>(
        builder: (context, state) {
          final tickets = state is MyBookingTicketsLoaded
              ? state.tickets
              : <EventBookingTicket>[];
          final canShareAll = tickets.isNotEmpty;

          return Scaffold(
            appBar: AppBar(
              title: Text('Detail Tiket'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              actions: [
                if (canShareAll)
                  IconButton(
                    icon: Icon(Icons.share),
                    tooltip: 'Bagikan Semua Tiket',
                    onPressed: () => _shareAllTickets(context, tickets),
                  ),
              ],
            ),
            body: Builder(
              builder: (context) {
                if (state is MyTicketsLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is MyTicketsFailure) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is MyBookingTicketsLoaded) {
                  if (state.tickets.isEmpty) {
                    return Center(child: Text('Tidak ada tiket ditemukan'));
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Event Info Card
                        if (widget.booking?.event != null) ...[
                          _buildEventInfoCard(widget.booking!.event!),
                          SizedBox(height: 24),
                          Text(
                            'Tiket Anda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
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
          );
        },
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
      child: widget.booking != null
          ? EventTicketCard(
              booking: widget.booking!,
              ticket: ticket,
              screenshotController: screenshotController,
              onShare: () =>
                  _shareTicket(context, ticket, screenshotController),
              onPrint: () => _printTicket(context, ticket),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildEventInfoCard(Event event) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                dateFormat.format(event.date.toLocal()),
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.location,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _shareAllTickets(
    BuildContext context,
    List<EventBookingTicket> tickets,
  ) async {
    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Menyiapkan tiket...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final directory = await getTemporaryDirectory();
      List<XFile> filesToShare = [];

      for (var ticket in tickets) {
        final controller = _screenshotControllers[ticket.id];
        if (controller != null) {
          final image = await controller.capture();
          if (image != null) {
            final imagePath = await File(
              '${directory.path}/ticket_${ticket.ticketCode}.png',
            ).create();
            await imagePath.writeAsBytes(image);
            filesToShare.add(XFile(imagePath.path));
          }
        }
      }

      // Close loading dialog
      if (!context.mounted) return;
      Navigator.pop(context);

      if (filesToShare.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(
            files: filesToShare,
            text: 'Ini tiket-tiket saya untuk booking ini.',
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil gambar tiket.')),
        );
      }
    } catch (e) {
      debugPrint('Error sharing all tickets: $e');
      if (!context.mounted) return;
      // Ensure dialog is closed if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membagikan tiket: $e')));
    }
  }

  Future<void> _shareTicket(
    BuildContext context,
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

      if (!context.mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath.path)],
          text:
              'Ini tiket saya untuk event ini: ${ticket.ticketName} (${ticket.ticketCode})',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing ticket: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membagikan tiket: $e')));
    }
  }

  Future<void> _printTicket(
    BuildContext context,
    EventBookingTicket ticket,
  ) async {
    // Check if event data is available
    final event = widget.booking?.event;
    if (event == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data event tidak tersedia')),
      );
      return;
    }

    // Show loading
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mencetak tiket...'),
                ],
              ),
            ),
          ),
        ),
      );

    try {
      // Get printer settings for paper size
      final getPrinterSettings = GetIt.I<GetPrinterSettings>();
      final printerSettings = await getPrinterSettings();

      // Get printer service
      final printerService = GetIt.I<PrinterService>();

      // Print the ticket
      await printerService.printEventTicket(
        ticketId: ticket.id,
        ticketCode: ticket.ticketCode,
        ticketName: ticket.ticketName,
        userName: ticket.userName,
        options: ticket.options,
        eventTitle: event.title,
        eventDate: event.date,
        eventTime: event.time,
        eventLocation: event.location,
        paperSize: printerSettings.paperSize,
      );

      // Close loading dialog
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiket berhasil dicetak!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error printing ticket: $e');
      // Close loading dialog
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mencetak: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
