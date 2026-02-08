import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  final bool showHeader;
  final bool showFooter;
  final bool isPermanent;

  const AdminSidebar({
    super.key,
    this.showHeader = true,
    this.showFooter = true,
    this.isPermanent = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          if (showHeader)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🎓', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Panel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'IKA SMANSARA',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _AdminMenuItem(
                  icon: '🏠',
                  label: 'Dashboard',
                  isSelected: currentPath == '/admin',
                  onTap: () => _handleNavigation(context, '/admin'),
                ),
                const Divider(height: 1),
                _AdminMenuItem(
                  icon: '👥',
                  label: 'Users',
                  subtitle: 'Kelola & verifikasi user',
                  isSelected: currentPath.startsWith('/admin/users'),
                  onTap: () => _handleNavigation(context, '/admin/users'),
                ),
                _AdminMenuItem(
                  icon: '📅',
                  label: 'Events',
                  subtitle: 'Kelola event & peserta',
                  isSelected: currentPath.startsWith('/admin/events'),
                  onTap: () => _handleNavigation(context, '/admin/events'),
                ),
                _AdminMenuItem(
                  icon: '💰',
                  label: 'Donasi',
                  subtitle: 'Kelola campaign donasi',
                  isSelected: currentPath.startsWith('/admin/donations'),
                  onTap: () => _handleNavigation(context, '/admin/donations'),
                ),
                _AdminMenuItem(
                  icon: '📰',
                  label: 'Berita',
                  subtitle: 'Kelola berita & artikel',
                  isSelected: currentPath.startsWith('/admin/news'),
                  onTap: () => _handleNavigation(context, '/admin/news'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'MODERASI',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                _AdminMenuItem(
                  icon: '💬',
                  label: 'Forum',
                  subtitle: 'Moderasi post & komentar',
                  isSelected: currentPath.startsWith('/admin/forum'),
                  onTap: () => _handleNavigation(context, '/admin/forum'),
                ),
                _AdminMenuItem(
                  icon: '💼',
                  label: 'Loker',
                  subtitle: 'Approval lowongan kerja',
                  isSelected: currentPath.startsWith('/admin/loker'),
                  onTap: () => _handleNavigation(context, '/admin/loker'),
                ),
                _AdminMenuItem(
                  icon: '🛒',
                  label: 'Market',
                  subtitle: 'Approval iklan jual-beli',
                  isSelected: currentPath.startsWith('/admin/market'),
                  onTap: () => _handleNavigation(context, '/admin/market'),
                ),
                _AdminMenuItem(
                  icon: '📷',
                  label: 'Memory',
                  subtitle: 'Approval galeri kenangan',
                  isSelected: currentPath.startsWith('/admin/memory'),
                  onTap: () => _handleNavigation(context, '/admin/memory'),
                ),
              ],
            ),
          ),

          if (showFooter)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: InkWell(
                onTap: () => context.go('/home'),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: AppColors.textGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kembali ke Aplikasi',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    if (!isPermanent) {
      Navigator.pop(context);
    }
    context.push(route);
  }
}

class _AdminMenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withValues(alpha: 0.1)
              : null,
          border: isSelected
              ? const Border(
                  right: BorderSide(color: AppColors.primary, width: 3),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColors.background,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textDark,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
