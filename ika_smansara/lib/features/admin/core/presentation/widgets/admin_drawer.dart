import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

/// Admin Drawer - Hamburger menu for admin navigation
class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'IKA SMANSARA',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
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
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin');
                    },
                  ),
                  const Divider(height: 1),
                  _AdminMenuItem(
                    icon: '👥',
                    label: 'Users',
                    subtitle: 'Kelola & verifikasi user',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/users');
                    },
                  ),
                  _AdminMenuItem(
                    icon: '📅',
                    label: 'Events',
                    subtitle: 'Kelola event & peserta',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/events');
                    },
                  ),
                  _AdminMenuItem(
                    icon: '💰',
                    label: 'Donasi',
                    subtitle: 'Kelola campaign donasi',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/donations');
                    },
                  ),
                  _AdminMenuItem(
                    icon: '📰',
                    label: 'Berita',
                    subtitle: 'Kelola berita & artikel',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/news');
                    },
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
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/forum');
                    },
                  ),
                  _AdminMenuItem(
                    icon: '💼',
                    label: 'Loker',
                    subtitle: 'Approval lowongan kerja',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/loker');
                    },
                  ),
                  _AdminMenuItem(
                    icon: '🛒',
                    label: 'Market',
                    subtitle: 'Approval iklan jual-beli',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/market');
                    },
                  ),
                  _AdminMenuItem(
                    icon: '📷',
                    label: 'Memory',
                    subtitle: 'Approval galeri kenangan',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/memory');
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 18, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home');
                    },
                    child: Text(
                      'Kembali ke Aplikasi',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
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
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
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
            Icon(Icons.chevron_right, size: 20, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
