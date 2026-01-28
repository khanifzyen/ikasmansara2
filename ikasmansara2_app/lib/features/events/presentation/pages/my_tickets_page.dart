import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/event_booking.dart';
import '../../presentation/bloc/my_tickets_bloc.dart';
import '../../presentation/pages/my_ticket_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MyTicketsPage extends StatefulWidget {
  final String userId;
  const MyTicketsPage({super.key, required this.userId});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.I<MyTicketsBloc>()..add(GetMyBookings(widget.userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tiketku'),
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
            } else if (state is MyBookingsLoaded) {
              if (state.bookings.isEmpty) {
                return const Center(
                  child: Text('Belum ada riwayat pembelian tiket'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(context, state.bookings[index]);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, EventBooking booking) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    Color statusColor;
    String statusText;

    switch (booking.paymentStatus) {
      case 'paid':
        statusColor = Colors.green;
        statusText = 'Berhasil';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Menunggu Pembayaran';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusText = 'Gagal';
        break;
      default:
        statusColor = Colors.grey;
        statusText = booking.paymentStatus;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (booking.paymentStatus == 'pending' &&
              booking.snapRedirectUrl != null) {
            _launchPaymentUrl(booking.snapRedirectUrl!);
          } else if (booking.paymentStatus == 'paid') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyTicketDetailPage(bookingId: booking.id),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ID: ${booking.id}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                currencyFormat.format(booking.totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (booking.paymentStatus == 'pending')
                const Text(
                  'Tap untuk melanjutkan pembayaran',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              if (booking.paymentStatus == 'paid')
                const Text(
                  'Tap untuk lihat tiket & QR Code',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
