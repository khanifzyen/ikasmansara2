import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeNewsSection extends StatelessWidget {
  const HomeNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Berita & Info', style: AppTextStyles.h3),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur Berita & Info akan segera hadir!'),
                    ),
                  );
                },
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
        Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index != 2 ? 16 : 0),
              child: _NewsTile(index: index),
            );
          }),
        ),
      ],
    );
  }
}

class _NewsTile extends StatelessWidget {
  final int index;
  const _NewsTile({required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 80,
            height: 80,
            color: AppColors.background,
            child: Icon(
              Icons.article_outlined,
              color: AppColors.textGrey,
              size: 32,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reuni Akbar Angkatan 90-2020 Akan Segera Dilaksanakan',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '12 Jan 2026 • Kegiatan',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
