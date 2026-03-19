import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/entities/event_winner_entity.dart';
import '../../domain/entities/event_prize_entity.dart';
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
          loaded: (winners, prizes) => _buildLoaded(context, winners, prizes),
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
    List<EventPrizeEntity> prizes,
  ) {
    final groupedWinners = groupBy(winners, (EventWinnerEntity e) => e.prizeName ?? 'Tanpa Hadiah');

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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => BlocProvider.value(
                          value: context.read<AdminDoorprizeCubit>(),
                          child: const _PrizeManagementDialog(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.card_giftcard, size: 18),
                    label: const Text('Daftar Hadiah'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
            ],
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 32),
          Text(
            'Riwayat Pengundian',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          if (winners.isEmpty) _buildEmptyState(),
          if (winners.isNotEmpty) ...[
            ...groupedWinners.entries.map(
              (entry) => _buildPrizeGroup(context, entry.key, entry.value),
            ),
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

class _PrizeManagementDialog extends StatefulWidget {
  const _PrizeManagementDialog();

  @override
  State<_PrizeManagementDialog> createState() => _PrizeManagementDialogState();
}

class _PrizeManagementDialogState extends State<_PrizeManagementDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _editingPrizeId;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _quantityController.clear();
    _editingPrizeId = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Daftar Hadiah Undian', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<AdminDoorprizeCubit, AdminDoorprizeState>(
          builder: (context, state) {
            if (state is! AdminDoorprizeLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final prizes = state.prizes;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Hadiah',
                          hintText: 'Cth: Sepeda Motor',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah',
                          hintText: '1',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        final name = _nameController.text.trim();
                        final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
                        if (name.isNotEmpty && qty > 0) {
                          if (_editingPrizeId != null) {
                            context.read<AdminDoorprizeCubit>().updatePrize(
                              id: _editingPrizeId!,
                              name: name,
                              quantity: qty,
                            );
                          } else {
                            context.read<AdminDoorprizeCubit>().addPrize(
                              name: name,
                              quantity: qty,
                            );
                          }
                          _clearForm();
                        }
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(80, 48),
                        backgroundColor: _editingPrizeId != null ? Colors.orange : AppColors.primary,
                      ),
                      child: Text(_editingPrizeId != null ? 'Simpan' : 'Tambah', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (_editingPrizeId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _clearForm,
                        child: const Text('Batal Edit'),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Divider(),
                if (prizes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Belum ada hadiah yang ditambahkan.',
                        style: GoogleFonts.inter(color: AppColors.textGrey),
                      ),
                    ),
                  ),
                if (prizes.isNotEmpty)
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: prizes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final prize = prizes[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(prize.name, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                          subtitle: Builder(
                            builder: (context) {
                              int claimed = state.winners.where((w) => w.prizeId == prize.id && w.status == 'won').length;
                              int remaining = prize.quantity - claimed;
                              return Text(
                                'Sisa: $remaining / ${prize.quantity}', 
                                style: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 13)
                              );
                            }
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                onPressed: () {
                                  setState(() {
                                    _editingPrizeId = prize.id;
                                    _nameController.text = prize.name;
                                    _quantityController.text = prize.quantity.toString();
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => context.read<AdminDoorprizeCubit>().deletePrize(prize.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

