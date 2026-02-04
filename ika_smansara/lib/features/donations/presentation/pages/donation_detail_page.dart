import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../bloc/donation_detail_bloc.dart';
import '../widgets/donation_payment_sheet.dart';

class DonationDetailPage extends StatelessWidget {
  final String donationId;

  const DonationDetailPage({super.key, required this.donationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DonationDetailBloc>()..add(FetchDonationDetail(donationId)),
      child: BlocConsumer<DonationDetailBloc, DonationDetailState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Terima kasih! Donasi Anda berhasil dicatat.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(
              context,
            ); // Close sheet if open (handled in sheet usually, but good fallback)
            // Re-fetch detail to update progress
            context.read<DonationDetailBloc>().add(
              FetchDonationDetail(donationId),
            );
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is DonationDetailLoading ||
            current is DonationDetailLoaded ||
            current is DonationDetailError,
        builder: (context, state) {
          if (state is DonationDetailLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is DonationDetailError) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(title: const Text('Error')),
              body: Center(child: Text(state.message)),
            );
          } else if (state is DonationDetailLoaded) {
            final donation = state.donation;
            final imageUrl = donation.banner.isNotEmpty
                ? donation.banner
                : 'assets/images/placeholder_donation.png';

            final currencyFormat = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            );

            return Scaffold(
              backgroundColor: Colors.white,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 250,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          imageUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(color: Colors.grey[200]),
                                )
                              : Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey[200]),
                                ),
                          if (donation.isUrgent)
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Berakhir pada ${DateFormat('d MMM yyyy').format(donation.deadline)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            donation.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.background,
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Oleh: ${donation.organizer}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currencyFormat.format(
                                        donation.collectedAmount,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'dari ${currencyFormat.format(donation.targetAmount)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: donation.progress,
                                  backgroundColor: Colors.grey[300],
                                  color: AppColors.primary,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${donation.percentage}% Terkumpul',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                    Text(
                                      '${donation.donorCount} Donatur',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            donation.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Donatur Terbaru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state.recentTransactions.isEmpty)
                            const Text(
                              'Belum ada donatur. Jadilah yang pertama!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ...state.recentTransactions.map(
                            (trx) => _DonorItem(
                              name: trx.isAnonymous
                                  ? 'Hamba Allah'
                                  : trx.donorName,
                              amount: currencyFormat.format(trx.amount),
                              time: DateFormat(
                                'dd MMM, HH:mm',
                              ).format(trx.created),
                              initials: trx.isAnonymous
                                  ? 'HA'
                                  : (trx.donorName.isNotEmpty
                                        ? trx.donorName[0].toUpperCase()
                                        : '?'),
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BlocProvider.value(
                          value: context.read<DonationDetailBloc>(),
                          child: DonationPaymentSheet(donation: donation),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    child: const Text('Donasi Sekarang'),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DonorItem extends StatelessWidget {
  final String name;
  final String amount;
  final String time;
  final String initials;
  final MaterialColor color;

  const _DonorItem({
    required this.name,
    required this.amount,
    required this.time,
    required this.initials,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color[50],
            foregroundColor: color[700],
            radius: 20,
            child: Text(
              initials,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
