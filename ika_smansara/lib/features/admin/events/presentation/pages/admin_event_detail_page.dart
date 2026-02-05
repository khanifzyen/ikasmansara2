import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../events/domain/entities/event.dart';
import '../../../core/presentation/widgets/admin_list_card.dart';
import '../../data/datasources/admin_events_remote_data_source.dart';
import '../../data/repositories/admin_events_repository_impl.dart';

class AdminEventDetailPage extends StatefulWidget {
  final String eventId;

  const AdminEventDetailPage({super.key, required this.eventId});

  @override
  State<AdminEventDetailPage> createState() => _AdminEventDetailPageState();
}

class _AdminEventDetailPageState extends State<AdminEventDetailPage> {
  final _repository = AdminEventsRepositoryImpl(AdminEventsRemoteDataSource());
  Event? _event;
  bool _isLoading = true;
  String? _error;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final event = await _repository.getEventById(widget.eventId);
      setState(() {
        _event = event;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus() async {
    if (_event == null) return;

    final newStatus = _event!.status == 'active' ? 'draft' : 'active';
    setState(() => _isProcessing = true);

    try {
      await _repository.updateEventStatus(widget.eventId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status event diubah ke ${newStatus == 'active' ? 'Aktif' : 'Draft'}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadEvent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Event'),
        content: const Text('Apakah Anda yakin ingin menghapus event ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await _repository.deleteEvent(widget.eventId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event berhasil dihapus'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Event',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          if (_event != null)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: _isProcessing ? null : _deleteEvent,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadEvent, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_event == null) {
      return const Center(child: Text('Event tidak ditemukan'));
    }

    final event = _event!;
    final dateFormatted = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id',
    ).format(event.date);
    final isActive = event.status == 'active';
    final isPast = event.date.isBefore(DateTime.now());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          if (event.banner != null)
            CachedNetworkImage(
              imageUrl: event.banner!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 200,
                color: AppColors.primaryLight,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 200,
                color: AppColors.primaryLight,
                child: const Icon(
                  Icons.event,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            Container(
              height: 200,
              color: AppColors.primaryLight,
              child: const Center(
                child: Icon(Icons.event, size: 64, color: AppColors.primary),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Row(
                  children: [
                    AdminBadge(
                      text: isPast ? 'Selesai' : (isActive ? 'Aktif' : 'Draft'),
                      type: isPast
                          ? AdminBadgeType.grey
                          : (isActive
                                ? AdminBadgeType.success
                                : AdminBadgeType.warning),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Info Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Tanggal',
                        value: dateFormatted,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: 'Waktu',
                        value: event.time,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.location_on,
                        label: 'Lokasi',
                        value: event.location,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deskripsi',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textGrey,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Button
                if (!isPast)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _toggleStatus,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(isActive ? Icons.pause : Icons.play_arrow),
                      label: Text(isActive ? 'Set ke Draft' : 'Aktifkan Event'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? AppColors.warning
                            : AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textGrey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
