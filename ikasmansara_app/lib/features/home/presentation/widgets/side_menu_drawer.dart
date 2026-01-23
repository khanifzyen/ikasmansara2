import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Menu Lainnya', style: AppTextStyles.h3),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menu Grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MenuIcon(
                icon: LucideIcons.store,
                label: 'Market',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/market'); // Need to add market route later
                },
              ),
              _MenuIcon(
                icon: LucideIcons.messageSquare,
                label: 'Forum',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/forum'); // Need to add forum route later
                },
              ),
              _MenuIcon(
                icon: LucideIcons.creditCard,
                label: 'E-KTA',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/ekta');
                },
              ),
              _MenuIcon(
                icon: LucideIcons.user,
                label: 'Profil',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile');
                },
              ),
              _MenuIcon(
                icon: LucideIcons.info,
                label: 'Tentang',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/about');
                },
              ),
              _MenuIcon(
                icon: LucideIcons.logOut,
                label: 'Keluar',
                color: AppColors.error,
                iconColor: AppColors.error,
                bgColor: AppColors.error.withValues(alpha: 0.1),
                onTap: () {
                  // Implement logout logic
                  Navigator.pop(context);
                  context.go('/login');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;
  final Color? bgColor;

  const _MenuIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor ?? AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color ?? AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
