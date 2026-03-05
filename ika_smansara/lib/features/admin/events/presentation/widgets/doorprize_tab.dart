import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../domain/entities/event_prize_entity.dart';
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
          loaded: (prizes, winners) => _buildLoaded(context, prizes, winners),
          error: (message) => _buildError(context, message),
        );
      },
    );
  }

  Widget _buildInitial(BuildContext context) {
    // Auto-load on first build
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
    List<EventPrizeEntity> prizes,
    List<EventWinnerEntity> winners,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Action Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              Text(
                'Daftar Hadiah',
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
                  FilledButton.icon(
                    onPressed: winners.isEmpty
                        ? null
                        : () =>
                              _showWinnersListDialog(context, prizes, winners),
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Pemenang'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showAddPrizeDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Hadiah'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: prizes.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  _buildRaffleRoute(context, prizes),
                            ),
                          ),
                    icon: const Icon(Icons.celebration, size: 18),
                    label: const Text('Mulai Undian'),
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
          const SizedBox(height: 20),

          // Prize List
          if (prizes.isEmpty) _buildEmptyState(),
          if (prizes.isNotEmpty) ...[
            ...prizes.map((prize) => _buildPrizeCard(context, prize, winners)),
          ],
        ],
      ),
    );
  }

  Widget _buildRaffleRoute(
    BuildContext context,
    List<EventPrizeEntity> prizes,
  ) {
    return BlocProvider.value(
      value: context.read<AdminDoorprizeCubit>(),
      child: AdminEventRafflePage(eventId: eventId, prizes: prizes),
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
              'Belum Ada Hadiah',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan hadiah terlebih dahulu sebelum memulai undian.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeCard(
    BuildContext context,
    EventPrizeEntity prize,
    List<EventWinnerEntity> winners,
  ) {
    final winnersForPrize = winners
        .where((w) => w.prizeId == prize.id)
        .toList();
    final remaining = prize.quantity - winnersForPrize.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Prize Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: remaining > 0
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  remaining > 0 ? Icons.card_giftcard : Icons.check_circle,
                  color: remaining > 0
                      ? const Color(0xFFFF9800)
                      : const Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Prize Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prize.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sisa: $remaining / ${prize.quantity}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: remaining > 0
                            ? AppColors.textGrey
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditPrizeDialog(context, prize);
                  } else if (value == 'delete') {
                    _showDeleteConfirmDialog(context, prize);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPrizeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Tambah Hadiah',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Hadiah',
                hintText: 'Contoh: Sepeda Motor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final qty = int.tryParse(quantityController.text) ?? 1;
              if (name.isNotEmpty) {
                context.read<AdminDoorprizeCubit>().addPrize(
                  name: name,
                  quantity: qty,
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditPrizeDialog(BuildContext context, EventPrizeEntity prize) {
    final nameController = TextEditingController(text: prize.name);
    final quantityController = TextEditingController(
      text: prize.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Edit Hadiah',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Hadiah',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final qty = int.tryParse(quantityController.text) ?? 1;
              if (name.isNotEmpty) {
                context.read<AdminDoorprizeCubit>().updatePrize(
                  prizeId: prize.id,
                  name: name,
                  quantity: qty,
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, EventPrizeEntity prize) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Hadiah?'),
        content: Text('Apakah Anda yakin ingin menghapus "${prize.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AdminDoorprizeCubit>().deletePrize(prize.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showWinnersListDialog(
    BuildContext context,
    List<EventPrizeEntity> prizes,
    List<EventWinnerEntity> initialWinners,
  ) {
    final cubit = context.read<AdminDoorprizeCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<AdminDoorprizeCubit, AdminDoorprizeState>(
            builder: (context, state) {
              final currentWinners = state.maybeWhen(
                loaded: (_, w) => w,
                orElse: () => initialWinners,
              );

              return AlertDialog(
                title: Text(
                  'Daftar Pemenang Undian',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                content: Container(
                  width: double.maxFinite,
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: currentWinners.isEmpty
                      ? const Center(child: Text('Belum ada pemenang.'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: prizes.length,
                          itemBuilder: (context, index) {
                            final prize = prizes[index];
                            final bWinners = currentWinners
                                .where((w) => w.prizeId == prize.id)
                                .toList();

                            if (bWinners.isEmpty)
                              return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    prize.name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                ...bWinners.map(
                                  (w) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.stars,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "${w.userName ?? 'Tanpa Nama'} (${w.ticketCode ?? '-'})",
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            _showDeleteWinnerConfirmDialog(
                                              context,
                                              w,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Tutup'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteWinnerConfirmDialog(
    BuildContext context,
    EventWinnerEntity winner,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hapus Pemenang?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus kemenangan untuk \${winner.userName}? Tiket ini akan bisa diundi kembali dan kuota hadiah akan bertambah.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Tutup confirm
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
