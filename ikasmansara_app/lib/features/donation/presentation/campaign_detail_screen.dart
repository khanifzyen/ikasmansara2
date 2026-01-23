import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ikasmansara_app/core/theme/app_colors.dart';
import 'package:ikasmansara_app/core/theme/app_text_styles.dart';
import 'package:ikasmansara_app/core/utils/formatters.dart';
import 'package:ikasmansara_app/common_widgets/buttons/primary_button.dart';

import 'package:ikasmansara_app/features/donation/presentation/providers/donation_providers.dart';

class CampaignDetailScreen extends ConsumerWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignAsync = ref.watch(getCampaignDetailProvider(campaignId));

    return Scaffold(
      body: campaignAsync.when(
        data: (campaign) {
          final progress = (campaign.collectedAmount / campaign.targetAmount)
              .clamp(0.0, 1.0);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: campaign.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: campaign.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.error)),
                        )
                      : Container(
                          color: AppColors.primary,
                          child: const Center(
                            child: Icon(
                              Icons.volunteer_activism,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Urgent
                      if (campaign.isUrgent)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MENDESAK',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(campaign.title, style: AppTextStyles.h3),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Organizer: ${campaign.organizer}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Progress Section
                      Text('Terkumpul', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Formatters.currency(campaign.collectedAmount),
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'dari ${Formatters.currency(campaign.targetAmount)}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border,
                        color: AppColors.secondary,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${campaign.daysLeft} hari lagi',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text('Deskripsi', style: AppTextStyles.h4),
                      const SizedBox(height: 8),
                      // Rendering simple text if HTML parsing is complex without dependency
                      // Ideally use flutter_html or similar for rich text
                      Text(
                        campaign
                            .description, // Assuming plain text or basic string for now
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 100), // Spacing for FAB/BottomBar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: PrimaryButton(
          text: 'Donasi Sekarang',
          onPressed: () {
            // Placeholder action - e.g. launch WhatsApp or payment link
            // launchUrl(Uri.parse('https://wa.me/6281234567890?text=Halo%20saya%20ingin%20donasi'));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur Pembayaran belum tersedia')),
            );
          },
        ),
      ),
    );
  }
}
