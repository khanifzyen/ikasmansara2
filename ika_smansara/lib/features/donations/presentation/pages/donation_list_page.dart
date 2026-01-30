import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../bloc/donation_list_bloc.dart';

class DonationListPage extends StatelessWidget {
  const DonationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DonationListBloc>()..add(FetchDonations()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Program Donasi'),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () => context.pushNamed('my-donations'),
              icon: const Icon(Icons.history),
              tooltip: 'Riwayat Donasi',
            ),
          ],
        ),
        body: BlocBuilder<DonationListBloc, DonationListState>(
          builder: (context, state) {
            if (state is DonationListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DonationListError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is DonationListLoaded) {
              if (state.donations.isEmpty) {
                return const Center(child: Text('Belum ada program donasi.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.donations.length,
                itemBuilder: (context, index) {
                  final donation = state.donations[index];
                  // Use a helper to resolve image URL
                  final imageUrl = donation.banner.isNotEmpty
                      ? donation.banner
                      : 'assets/images/placeholder_donation.png';

                  return _CampaignCard(
                    title: donation.title,
                    description: donation
                        .description, // Note: description might be HTML if editor used
                    imageUrl: imageUrl,
                    targetAmount: donation.targetAmount,
                    currentAmount: donation.collectedAmount,
                    donorCount: donation.donorCount,
                    isUrgent: donation.isUrgent,
                    deadline: donation.deadline,
                    onTap: () => context.pushNamed(
                      'donation-detail',
                      extra: donation.id, // Pass ID to detail page
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double targetAmount;
  final double currentAmount;
  final int donorCount;
  final bool isUrgent;
  final DateTime deadline;
  final VoidCallback onTap;

  const _CampaignCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetAmount,
    required this.currentAmount,
    required this.donorCount,
    required this.isUrgent,
    required this.deadline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final progress = (currentAmount / targetAmount).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(
                                    child: Icon(
                                      Icons.volunteer_activism,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                          : Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.volunteer_activism,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                    ),
                    if (isUrgent)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 16),

                // Deadline
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Berakhir ${DateFormat('d MMM yyyy').format(deadline)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(currentAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'dari ${currencyFormat.format(targetAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$percentage% Terkumpul • $donorCount Donatur',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Donasi Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
