import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/buttons.dart';
import '../../../../../core/services/printer_service.dart';
import '../../../../events/domain/entities/event_booking.dart';
import '../../../../events/domain/entities/event_booking_ticket.dart';
import '../../../../settings/domain/usecases/get_printer_settings.dart';
import '../bloc/admin_participants_bloc.dart';

class ParticipantsTab extends StatefulWidget {
  final String eventId;

  const ParticipantsTab({super.key, required this.eventId});

  @override
  State<ParticipantsTab> createState() => _ParticipantsTabState();
}

class _ParticipantsTabState extends State<ParticipantsTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminParticipantsBloc()..add(LoadParticipants(widget.eventId)),
      child: BlocListener<AdminParticipantsBloc, AdminParticipantsState>(
        listener: (context, state) {
          if (state is AdminParticipantsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AdminParticipantsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<AdminParticipantsBloc, AdminParticipantsState>(
          builder: (context, state) {
            if (state is AdminParticipantsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminParticipantsLoaded) {
              return _buildContent(context, state);
            }

            if (state is AdminParticipantsError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            return const Center(child: Text('Memuat data...'));
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminParticipantsLoaded state) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Peserta (${state.bookings.length})',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              PrimaryButton(
                text: isDesktop ? '+ Tambah Manual' : '+ Manual',
                isExpanded: false,
                onPressed: () => _showAddManualModal(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.bookings.isEmpty)
            _buildEmptyState()
          else if (isDesktop)
            _buildTable(context, state.bookings)
          else
            _buildMobileList(context, state.bookings),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada peserta',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<EventBooking> bookings) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(AppColors.background),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('ID Booking')),
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('HP / Angkatan')),
          DataColumn(label: Text('Tiket')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Tgl Bayar')),
          DataColumn(label: Text('Catatan')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: bookings.asMap().entries.map((entry) {
          final index = entry.key;
          final booking = entry.value;
          return _buildDataRow(context, booking, index + 1);
        }).toList(),
      ),
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    EventBooking booking,
    int sequenceNumber,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(sequenceNumber.toString())),
        DataCell(
          Text(
            booking.bookingId,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(booking.displayName)),
        DataCell(Text('${booking.displayPhone}\n${booking.displayAngkatan}')),
        DataCell(Text(booking.displayTicketCount.toString())),
        DataCell(
          Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(booking.displayPrice),
          ),
        ),
        DataCell(_buildStatusBadge(booking)),
        DataCell(
          Text(
            booking.paymentDate != null
                ? DateFormat(
                    'd MMM, HH:mm',
                    'id',
                  ).format(booking.paymentDate!.toLocal())
                : '-',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              booking.displayNotes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.primary),
                onPressed: () => _showBookingDetail(context, booking),
              ),
              if (booking.paymentStatus == 'paid')
                IconButton(
                  icon: const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Lihat Tiket',
                  onPressed: () => _showTicketPreview(context, booking),
                ),
              if (booking.paymentStatus == 'pending')
                IconButton(
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                  onPressed: () => _confirmPayment(context, booking),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(BuildContext context, List<EventBooking> bookings) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildMobileCard(context, bookings[index]),
    );
  }

  Widget _buildMobileCard(BuildContext context, EventBooking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildStatusBadge(booking),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(booking.displayPhone),
          if (booking.displayNotes != '-') ...[
            const SizedBox(height: 4),
            Text(
              'Catatan: ${booking.displayNotes}',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ],
          if (booking.paymentDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tgl Bayar: ${DateFormat('d MMM yyyy, HH:mm', 'id').format(booking.paymentDate!.toLocal())}',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${booking.displayTicketCount} Tiket'),
              Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp',
                  decimalDigits: 0,
                ).format(booking.displayPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlineButton(
                text: 'Detail',
                isExpanded: false,
                onPressed: () => _showBookingDetail(context, booking),
              ),
              if (booking.paymentStatus == 'paid') ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColors.primary,
                  ),
                  onPressed: () => _showTicketPreview(context, booking),
                ),
              ],
              if (booking.paymentStatus == 'pending') ...[
                const SizedBox(width: 8),
                PrimaryButton(
                  text: 'Validasi',
                  isExpanded: false,
                  onPressed: () => _confirmPayment(context, booking),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EventBooking booking) {
    Color color;
    String label;

    switch (booking.paymentStatus) {
      case 'paid':
        color = AppColors.success;
        label = 'LUNAS';
        break;
      case 'pending':
        color = AppColors.warning;
        label = 'PENDING';
        break;
      default:
        color = AppColors.error;
        label = booking.paymentStatus.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showAddManualModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AdminParticipantsBloc>(),
        child: _ManualBookingModal(eventId: widget.eventId),
      ),
    );
  }

  void _showBookingDetail(BuildContext context, EventBooking booking) {
    showDialog(
      context: context,
      builder: (dialogContext) => _BookingDetailModal(
        booking: booking,
        onShowTickets: () => _showTicketPreview(context, booking),
      ),
    );
  }

  void _showTicketPreview(BuildContext context, EventBooking booking) {
    final bloc = context.read<AdminParticipantsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: _TicketPreviewModal(booking: booking),
      ),
    );
  }

  void _confirmPayment(BuildContext context, EventBooking booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Validasi Pembayaran'),
        content: Text(
          'Apakah Anda yakin ingin mengganti status booking ${booking.bookingId} menjadi LUNAS?\n\nTiket peserta akan otomatis di-generate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminParticipantsBloc>().add(
                UpdateParticipantStatus(
                  eventId: widget.eventId,
                  bookingId: booking.id,
                  status: 'paid',
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Ya, Validasi'),
          ),
        ],
      ),
    );
  }
}

class _ManualBookingModal extends StatefulWidget {
  final String eventId;

  const _ManualBookingModal({required this.eventId});

  @override
  State<_ManualBookingModal> createState() => _ManualBookingModalState();
}

class _ManualBookingModalState extends State<_ManualBookingModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _angkatanController = TextEditingController();
  final _countController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedTicketId;
  String? _selectedChannel;

  @override
  void initState() {
    super.initState();
    context.read<AdminParticipantsBloc>().add(LoadTickets(widget.eventId));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _angkatanController.dispose();
    _countController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tambah Peserta Manual',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap / Koordinator',
                        hintText: 'Masukkan nama pendaftar',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'No. HP',
                              hintText: '0812...',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _angkatanController,
                            decoration: const InputDecoration(
                              labelText: 'Angkatan',
                              hintText: 'Contoh: 1995',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AdminParticipantsBloc, AdminParticipantsState>(
                      builder: (context, state) {
                        if (state is AdminParticipantsLoaded) {
                          final tickets = state.availableTickets ?? [];
                          return DropdownButtonFormField<String>(
                            value: _selectedTicketId,
                            decoration: const InputDecoration(
                              labelText: 'Jenis Tiket',
                              border: OutlineInputBorder(),
                            ),
                            items: tickets.map((t) {
                              return DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedTicketId = v),
                            validator: (v) => v == null ? 'Pilih tiket' : null,
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _countController,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Tiket',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null ||
                                    int.tryParse(v) == null ||
                                    int.parse(v) < 1
                                ? 'Minimal 1'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Total Biaya',
                              hintText: 'Misal: 150000',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || int.tryParse(v) == null
                                ? 'Wajib diisi'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedChannel,
                      decoration: const InputDecoration(
                        labelText: 'Channel Pendaftaran',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'manual_transfer',
                          child: Text('Manual Transfer'),
                        ),
                        DropdownMenuItem(
                          value: 'manual_cash',
                          child: Text('Manual Cash'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedChannel = v),
                      validator: (v) => v == null ? 'Pilih channel' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        hintText: 'Keterangan tambahan...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Simpan Pendaftaran',
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final price = int.parse(_priceController.text);
    final data = {
      'event': widget.eventId,
      'coordinator_name': _nameController.text,
      'coordinator_phone': _phoneController.text,
      'coordinator_angkatan': _angkatanController.text,
      'manual_ticket_count': int.parse(_countController.text),
      'manual_ticket_type': _selectedTicketId,
      'subtotal': price,
      'service_fee': 0,
      'total_price': price,
      'registration_channel': _selectedChannel,
      'notes': _notesController.text,
      'payment_status': 'pending',
    };

    context.read<AdminParticipantsBloc>().add(
      CreateManualBookingAction(eventId: widget.eventId, data: data),
    );
    Navigator.pop(context);
  }
}

class _BookingDetailModal extends StatelessWidget {
  final EventBooking booking;
  final VoidCallback? onShowTickets;

  const _BookingDetailModal({required this.booking, this.onShowTickets});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(booking.bookingId),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Nama', booking.displayName),
            _buildInfoRow('No. HP', booking.displayPhone),
            _buildInfoRow('Angkatan', booking.displayAngkatan),
            if (booking.paymentDate != null)
              _buildInfoRow(
                'Tgl Bayar',
                DateFormat(
                  'd MMMM yyyy, HH:mm',
                  'id',
                ).format(booking.paymentDate!.toLocal()),
              ),
            const Divider(),
            _buildInfoRow('Jumlah Tiket', '${booking.displayTicketCount}'),
            _buildInfoRow(
              'Total Harga',
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp',
                decimalDigits: 0,
              ).format(booking.displayPrice),
            ),
            _buildInfoRow('Status', booking.paymentStatus.toUpperCase()),
            _buildInfoRow('Catatan', booking.displayNotes),
            const SizedBox(height: 16),
            if (booking.paymentStatus == 'paid')
              PrimaryButton(
                text: 'Lihat Tiket',
                onPressed: () {
                  Navigator.pop(context);
                  onShowTickets?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketPreviewModal extends StatefulWidget {
  final EventBooking booking;

  const _TicketPreviewModal({required this.booking});

  @override
  State<_TicketPreviewModal> createState() => _TicketPreviewModalState();
}

class _TicketPreviewModalState extends State<_TicketPreviewModal> {
  final Map<String, ScreenshotController> _screenshotControllers = {};

  @override
  void initState() {
    super.initState();
    context.read<AdminParticipantsBloc>().add(
      LoadBookingTickets(widget.booking.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<AdminParticipantsBloc, AdminParticipantsState>(
          builder: (context, state) {
            final tickets = (state is AdminParticipantsLoaded)
                ? state.selectedBookingTickets
                : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Preview Tiket',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (tickets == null)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  )
                else if (tickets.isEmpty)
                  const Text('Tidak ada tiket ditemukan.')
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareAllTickets(context, tickets),
                          icon: const Icon(Icons.share),
                          label: const Text('Share All'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _printAllTickets(context, tickets),
                          icon: const Icon(Icons.print),
                          label: const Text('Print All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: tickets.map((t) {
                          _screenshotControllers.putIfAbsent(
                            t.id,
                            () => ScreenshotController(),
                          );
                          return _buildTicketItem(context, t);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketItem(BuildContext context, EventBookingTicket ticket) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Screenshot(
            controller: _screenshotControllers[ticket.id]!,
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
                    widget.booking.event?.title ?? 'Event',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('EEEE, d MMM yyyy', 'id').format(widget.booking.event?.date.toLocal() ?? DateTime.now())} - ${widget.booking.event?.time ?? '-'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.booking.event?.location ?? '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                  const Divider(height: 24),
                  _buildTicketRow('TIKET', ticket.ticketName),
                  _buildTicketRow(
                    'NAMA',
                    (widget.booking.registrationChannel == 'app' ||
                            widget.booking.userId.isNotEmpty)
                        ? (ticket.userName.isNotEmpty
                              ? ticket.userName
                              : 'Peserta')
                        : '(Koordinator) ${widget.booking.coordinatorName ?? '-'}',
                  ),
                  () {
                    final displayOptions =
                        (widget.booking.registrationChannel == 'app' ||
                            widget.booking.userId.isNotEmpty)
                        ? ticket.options.values.join(', ')
                        : (widget.booking.notes ?? '-');
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _shareTicket(context, ticket),
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () => _printTicket(context, ticket),
                icon: const Icon(Icons.print, size: 18),
                label: const Text('Print'),
              ),
            ],
          ),
        ],
      ),
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

  Future<void> _shareTicket(
    BuildContext context,
    EventBookingTicket ticket,
  ) async {
    try {
      final controller = _screenshotControllers[ticket.id];
      if (controller == null) return;

      final image = await controller.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/tikets_${ticket.ticketCode}.png',
      ).create();
      await imagePath.writeAsBytes(image);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath.path)],
          text: 'Tiket IKA SMANSARA: ${ticket.userName} - ${ticket.ticketCode}',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing ticket: $e');
    }
  }

  Future<void> _shareAllTickets(
    BuildContext context,
    List<EventBookingTicket> tickets,
  ) async {
    try {
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

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: filesToShare,
          text: 'Semua tiket pendaftaran ${widget.booking.bookingId}',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing all tickets: $e');
    }
  }

  Future<void> _printTicket(
    BuildContext context,
    EventBookingTicket ticket,
  ) async {
    final event = widget.booking.event;
    if (event == null) return;

    try {
      final getPrinterSettings = GetIt.I<GetPrinterSettings>();
      final printerSettings = await getPrinterSettings();
      final printerService = GetIt.I<PrinterService>();

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _printAllTickets(
    BuildContext context,
    List<EventBookingTicket> tickets,
  ) async {
    for (var ticket in tickets) {
      if (!mounted) break;
      await _printTicket(context, ticket);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
