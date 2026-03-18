import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/entities/event_winner_entity.dart';
import '../bloc/admin_doorprize_cubit.dart';
import '../pages/admin_event_raffle_page.dart';

class DoorprizeTab extends StatelessWidget {
  final String eventId;

  const DoorprizeTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDoorprizeCubit, AdminDoorprizeState>(
      builder: (context, state) {
        return state.when(
          initial: () => _buildInitial(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (winners) => _buildLoaded(context, winners),
          error: (message) => _buildError(context, message),
        );
      },
    );
  }

  Widget _buildInitial(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDoorprizeCubit>().loadData();
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AdminDoorprizeCubit>().loadData(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    List<EventWinnerEntity> winners,
  ) {
    final groupedWinners = groupBy(winners, (EventWinnerEntity e) => e.prizeName);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              Text(
                'Daftar Pemenang Undian',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AdminDoorprizeCubit>(),
                      child: AdminEventRafflePage(eventId: eventId),
                    ),
                  ),
                ),
                icon: const Icon(Icons.celebration, size: 18),
                label: const Text('Buka Halaman Undian'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (winners.isEmpty) _buildEmptyState(),
          if (winners.isNotEmpty) ...[
            ...groupedWinners.entries.map((entry) => _buildPrizeGroup(context, entry.key, entry.value)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Pemenang',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan mulai undian untuk mengundi pemenang.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeGroup(
    BuildContext context,
    String prizeName,
    List<EventWinnerEntity> prizeWinners,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Text(
              prizeName,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prizeWinners.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final w = prizeWinners[index];
              final isDisqualified = w.status == 'disqualified';

              return ListTile(
                leading: Icon(
                  isDisqualified ? Icons.cancel : Icons.stars,
                  color: isDisqualified ? Colors.grey : Colors.amber,
                ),
                title: Text(
                  "${w.userName ?? 'Tanpa Nama'} (${w.ticketCode ?? '-'})",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDisqualified ? Colors.grey : AppColors.textDark,
                    decoration: isDisqualified ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isDisqualified)
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
                        tooltip: 'Diskualifikasi',
                        onPressed: () => _showDisqualifyConfirmDialog(context, w),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Hapus Pemenang',
                      onPressed: () => _showDeleteConfirmDialog(context, w),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDisqualifyConfirmDialog(BuildContext context, EventWinnerEntity winner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Diskualifikasi Pemenang?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin mendiskualifikasi ${winner.userName}? Tiket ini akan dicoret dan tidak dapat diundi karena statusnya didiskualifikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdminDoorprizeCubit>().disqualifyWinner(winner.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Diskualifikasi'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, EventWinnerEntity winner) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hapus Pemenang?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data pemenang atas nama ${winner.userName}? Data tiket ini akan bisa diundi kembali jika dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdminDoorprizeCubit>().deleteWinner(winner.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
