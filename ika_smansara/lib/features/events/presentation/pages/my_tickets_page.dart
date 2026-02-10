import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/event_booking.dart';
import '../../presentation/bloc/my_tickets_bloc.dart';
import '../../presentation/pages/my_ticket_detail_page.dart';

import 'package:go_router/go_router.dart';

class MyTicketsPage extends StatefulWidget {
  final String userId;
  const MyTicketsPage({super.key, required this.userId});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  late final MyTicketsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<MyTicketsBloc>();
    _bloc.add(GetMyBookings(widget.userId));
  }

  void _refresh() {
    _bloc.add(GetMyBookings(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tiketku'),

          foregroundColor: Theme.of(context).colorScheme.onSurface,
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
              return RefreshIndicator(
                onRefresh: () async {
                  _refresh();
                  // Wait for state to change
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.bookings.length,
                  itemBuilder: (context, index) {
                    return _buildBookingCard(context, state.bookings[index]);
                  },
                ),
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
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id');

    // Parse metadata
    int totalTicketCount = 0;
    List<String> shirtSizes = [];

    for (var item in booking.metadata) {
      final qty = item['quantity'] as int? ?? 0;
      totalTicketCount += qty;

      final options = item['options'];
      if (options is Map) {
        options.forEach((key, value) {
          if (value != null) {
            shirtSizes.add(value.toString());
          }
        });
      }
    }

    final sizeDetailString = shirtSizes.isNotEmpty
        ? ', Rincian Ukuran Kaos: ${shirtSizes.join(', ')}'
        : '';

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
      case 'cancelled':
        statusColor = Colors.grey;
        statusText = 'Dibatalkan';
        break;
      case 'expired':
        statusColor = Colors.grey;
        statusText = 'Kedaluwarsa';
        break;
      default:
        statusColor = Colors.grey;
        statusText = booking.paymentStatus;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: booking.paymentStatus == 'paid'
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyTicketDetailPage(
                      bookingId: booking.id,
                      booking: booking,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Booking ID: ${booking.bookingId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 8),
              Text(
                'Pembelian: ${dateFormat.format(booking.created.toLocal())}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Text(
                booking.event?.title ?? 'Event Tidak Dikenal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalTicketCount Tiket$sizeDetailString',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(booking.totalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // Action Buttons
              if (booking.paymentStatus == 'pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(context, booking),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (booking.snapRedirectUrl != null) {
                            final result = await context.push<bool>(
                              '/payment',
                              extra: {
                                'paymentUrl': booking.snapRedirectUrl!,
                                'bookingId': booking.bookingId,
                                'fromEventDetail': false,
                              },
                            );

                            if (result == true && context.mounted) {
                              context.read<MyTicketsBloc>().add(
                                GetMyBookings(widget.userId),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Bayar'),
                      ),
                    ),
                  ],
                ),
              ] else if (booking.paymentStatus == 'failed' ||
                  booking.paymentStatus == 'cancelled' ||
                  booking.paymentStatus == 'expired') ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _showDeleteDialog(context, booking),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ] else if (booking.paymentStatus == 'paid') ...[
                const Text(
                  'Tap untuk lihat tiket & QR Code',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, EventBooking booking) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pesanan ini? Pesanan yang dibatalkan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MyTicketsBloc>().add(
                CancelEventBooking(booking.id, widget.userId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, EventBooking booking) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Riwayat?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus riwayat pesanan ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MyTicketsBloc>().add(
                DeleteEventBooking(booking.id, widget.userId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }
}
