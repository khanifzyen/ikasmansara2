import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/adaptive/adaptive_grid.dart';
import '../bloc/donation_list_bloc.dart';

class DonationListPage extends StatelessWidget {
  const DonationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DonationListBloc>()..add(FetchDonations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Program Donasi'),
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
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppBreakpoints.maxContentWidth,
                  ),
                  child: AdaptiveGridView(
                    padding: EdgeInsets.all(
                      AppSizes.horizontalPadding(context),
                    ),
                    itemCount: state.donations.length,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.62,
                    itemBuilder: (context, index) {
                      final donation = state.donations[index];
                      final imageUrl = donation.banner.isNotEmpty
                          ? donation.banner
                          : 'assets/images/placeholder_event.png';

                      return _CampaignCard(
                        title: donation.title,
                        description: donation.description,
                        imageUrl: imageUrl,
                        targetAmount: donation.targetAmount,
                        currentAmount: donation.collectedAmount,
                        donorCount: donation.donorCount,
                        isUrgent: donation.isUrgent,
                        deadline: donation.deadline,
                        onTap: () => context.pushNamed(
                          'donation-detail',
                          extra: donation.id,
                        ),
                      );
                    },
                  ),
                ),
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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          hoverColor: AppColors.primaryLight.withValues(alpha: 0.15),
          child: Container(
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 11,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl.startsWith('http')
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: AppColors.textGrey,
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                },
                              )
                            : Image.asset(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: AppColors.textGrey,
                                    ),
                                  );
                                },
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
                          child: Text(
                            'URGENT',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 10,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Berakhir ${DateFormat('d MMM yyyy').format(deadline)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textGrey,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              currencyFormat.format(currentAmount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'dari ${currencyFormat.format(targetAmount)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        color: AppColors.primary,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$percentage% • $donorCount Donatur',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Donasi Sekarang',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
