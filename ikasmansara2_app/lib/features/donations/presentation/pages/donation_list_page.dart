import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class DonationListPage extends StatelessWidget {
  const DonationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Program Donasi'),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CampaignCard(
            title: 'Renovasi Masjid Sekolah SMAN 1 Jepara',
            description: 'Mari bantu adik-adik kita beribadah dengan nyaman.',
            imageUrl: 'assets/images/logo-ika.png', // Placeholder
            targetAmount: 50000000,
            currentAmount: 35000000,
            donorCount: 145,
            isUrgent: true,
            onTap: () => context.push('/donation-detail'),
          ),
          _CampaignCard(
            title: 'Beasiswa Anak Alumni Kurang Mampu',
            description:
                'Bantuan biaya pendidikan bagi anak alumni yang membutuhkan.',
            imageUrl: 'assets/images/logo-ika.png', // Placeholder
            targetAmount: 20000000,
            currentAmount: 12500000,
            donorCount: 88,
            isUrgent: false,
            onTap: () {},
          ),
          _CampaignCard(
            title: 'Dana Tali Kasih (Alumni Sakit)',
            description: 'Solidaritas untuk rekan alumni yang sedang sakit.',
            imageUrl: 'assets/images/logo-ika.png', // Placeholder
            targetAmount: 10000000, // Flexible target
            currentAmount: 2000000,
            donorCount: 15,
            isUrgent: false,
            onTap: () {},
          ),
        ],
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
  final VoidCallback onTap;

  const _CampaignCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetAmount,
    required this.currentAmount,
    required this.donorCount,
    required this.isUrgent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                        image: DecorationImage(
                          image: AssetImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Placeholder icon if asset not found logic could be here
                      child: const Center(
                        child: Icon(
                          Icons.volunteer_activism,
                          size: 50,
                          color: Colors.grey,
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

                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${currentAmount.toStringAsFixed(0)}', // Basic formatting
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'dari Rp ${targetAmount.toStringAsFixed(0)}',
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
