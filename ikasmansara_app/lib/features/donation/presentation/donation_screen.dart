import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikasmansara_app/common_widgets/cards/campaign_card.dart';
import 'package:ikasmansara_app/common_widgets/layout/empty_state.dart';
import 'package:ikasmansara_app/common_widgets/layout/loading_shimmer.dart';
import 'package:ikasmansara_app/features/donation/presentation/donation_list_controller.dart';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  @override
  Widget build(BuildContext context) {
    final campaignState = ref.watch(donationListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Program Donasi'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(donationListControllerProvider.notifier).refresh(),
        child: campaignState.when(
          data: (campaigns) {
            if (campaigns.isEmpty) {
              return const EmptyState(
                message: 'Belum ada program donasi saat ini.',
                title: 'Tidak Ada Donasi',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: campaigns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final campaign = campaigns[index];
                return CampaignCard(
                  title: campaign.title,
                  targetAmount: campaign.targetAmount,
                  currentAmount: campaign.collectedAmount,
                  daysLeft: campaign.daysLeft,
                  imageUrl:
                      campaign.imageUrl ??
                      'https://placehold.co/600x400', // Placeholder
                  isUrgent: campaign.isUrgent,
                  onTap: () {
                    context.go('/donation/${campaign.id}');
                  },
                );
              },
            );
          },
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          loading: () => LoadingShimmer.list(),
        ),
      ),
    );
  }
}
