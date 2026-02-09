import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../widgets/admin_responsive_scaffold.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_list_card.dart';
import '../../bloc/admin_stats_bloc.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminStatsBloc()..add(const LoadAdminStats()),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return AdminResponsiveScaffold(
      title: 'Admin Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textGrey),
          onPressed: () {
            context.read<AdminStatsBloc>().add(const LoadAdminStats());
          },
        ),
      ],
      body: BlocBuilder<AdminStatsBloc, AdminStatsState>(
        builder: (context, state) {
          if (state is AdminStatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminStatsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminStatsBloc>().add(
                        const LoadAdminStats(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stats = state is AdminStatsLoaded ? state : null;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AdminStatsBloc>().add(const LoadAdminStats());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 24 : 16,
                    isDesktop ? 0 : 16,
                    isDesktop ? 24 : 16,
                    isDesktop ? 16 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Header
                      Container(
                        padding: EdgeInsets.all(isDesktop ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat Datang! 👋',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Admin Panel IKA SMANSARA',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  '🎓',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isDesktop ? 20 : 16),

                      // Stats Grid
                      Text(
                        'Statistik',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, gridConstraints) {
                          final spacing = isDesktop ? 16.0 : 12.0;
                          final crossAxisCount = isDesktop ? 2 : 2;
                          final totalSpacing = spacing * (crossAxisCount - 1);
                          final cardWidth =
                              (gridConstraints.maxWidth - totalSpacing) /
                              crossAxisCount;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: AdminStatCard(
                                  icon: '👥',
                                  value: stats?.totalUsers.toString() ?? '0',
                                  label: 'Total Users',
                                  onTap: () => context.push('/admin/users'),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: AdminStatCard(
                                  icon: '📅',
                                  value: stats?.totalEvents.toString() ?? '0',
                                  label: 'Events',
                                  onTap: () => context.push('/admin/events'),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: AdminStatCard(
                                  icon: '💰',
                                  value:
                                      stats?.totalDonations.toString() ?? '0',
                                  label: 'Donasi',
                                  onTap: () => context.push('/admin/donations'),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: AdminStatCard(
                                  icon: '📰',
                                  value: stats?.totalNews.toString() ?? '0',
                                  label: 'Berita',
                                  onTap: () => context.push('/admin/news'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: isDesktop ? 20 : 24),

                      // Pending Items Section
                      Text(
                        'Perlu Perhatian',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if ((stats?.pendingUsers ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AdminListCard(
                            avatarEmoji: '👤',
                            avatarColor: AppColors.warningLight,
                            title: 'User Pending Verifikasi',
                            subtitle:
                                '${stats?.pendingUsers} user menunggu verifikasi',
                            badge: const AdminBadge(
                              text: 'Pending',
                              type: AdminBadgeType.warning,
                            ),
                            onTap: () => context.push('/admin/users'),
                          ),
                        ),

                      if ((stats?.pendingLokers ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AdminListCard(
                            avatarEmoji: '💼',
                            avatarColor: AppColors.infoLight,
                            title: 'Loker Pending Approval',
                            subtitle:
                                '${stats?.pendingLokers} lowongan menunggu approval',
                            badge: const AdminBadge(
                              text: 'Review',
                              type: AdminBadgeType.info,
                            ),
                            onTap: () => context.push('/admin/loker'),
                          ),
                        ),

                      if ((stats?.pendingMarkets ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AdminListCard(
                            avatarEmoji: '🛒',
                            avatarColor: AppColors.infoLight,
                            title: 'Market Pending Approval',
                            subtitle:
                                '${stats?.pendingMarkets} iklan menunggu approval',
                            badge: const AdminBadge(
                              text: 'Review',
                              type: AdminBadgeType.info,
                            ),
                            onTap: () => context.push('/admin/market'),
                          ),
                        ),

                      if ((stats?.pendingMemories ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AdminListCard(
                            avatarEmoji: '📷',
                            avatarColor: AppColors.primaryLight,
                            title: 'Memory Pending Approval',
                            subtitle:
                                '${stats?.pendingMemories} foto menunggu approval',
                            badge: const AdminBadge(
                              text: 'Review',
                              type: AdminBadgeType.info,
                            ),
                            onTap: () => context.push('/admin/memory'),
                          ),
                        ),

                      if ((stats?.pendingUsers ?? 0) == 0 &&
                          (stats?.pendingLokers ?? 0) == 0 &&
                          (stats?.pendingMarkets ?? 0) == 0 &&
                          (stats?.pendingMemories ?? 0) == 0)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text('✅', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tidak ada item yang perlu perhatian',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: isDesktop ? 20 : 24),

                      // Quick Actions
                      Text(
                        'Aksi Cepat',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _QuickActionChip(
                            icon: '➕',
                            label: 'Tambah Event',
                            onTap: () => context.push('/admin/events/create'),
                          ),
                          _QuickActionChip(
                            icon: '📝',
                            label: 'Tulis Berita',
                            onTap: () => context.push('/admin/news/create'),
                          ),
                          _QuickActionChip(
                            icon: '📷',
                            label: 'Scan QR',
                            onTap: () => context.push('/ticket-scanner'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
