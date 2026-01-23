import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../common_widgets/cards/campaign_card.dart';

class HomeCampaignSlider extends StatelessWidget {
  const HomeCampaignSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Program Donasi', style: AppTextStyles.h3),
              InkWell(
                onTap: () => context.go('/donation'),
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RepaintBoundary(
          child: SizedBox(
            height: 280, // Height for CampaignCard + padding
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Dummy count
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 280,
                  child: CampaignCard(
                    title: 'Beasiswa Anak Alumni Berprestasi 2024',
                    currentAmount: 15000000,
                    targetAmount: 50000000,
                    daysLeft: 12,
                    isUrgent: index == 0,
                    imageUrl: null, // Use placeholder to avoid network lag
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
