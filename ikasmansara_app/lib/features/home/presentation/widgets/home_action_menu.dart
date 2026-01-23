import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeActionMenu extends StatelessWidget {
  const HomeActionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // 4 Menu Items hanya untuk Market, Loker, Donasi, dan Berita
    final menuItems = [
      {'icon': LucideIcons.store, 'label': 'Market', 'route': '/market'},
      {'icon': LucideIcons.briefcase, 'label': 'Loker', 'route': '/loker'},
      {'icon': LucideIcons.heart, 'label': 'Donasi', 'route': '/donation'},
      {'icon': LucideIcons.newspaper, 'label': 'Berita', 'route': '/news'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return InkWell(
            onTap: () {
              // Navigation Logic
              final route = item['route'] as String;
              if (route == '/donation') {
                final shell = StatefulNavigationShell.of(context);
                shell.goBranch(2); // Navigate to Donation tab
              } else if (route == '/loker') {
                final shell = StatefulNavigationShell.of(context);
                shell.goBranch(3); // Navigate to Loker tab
              } else {
                // For Market and Berita, just push the route
                context.push(route);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
