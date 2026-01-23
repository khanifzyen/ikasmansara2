import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        final name = user?.name ?? 'Alumni';
        final angkatan = user?.angkatan?.toString() ?? '-';
        final id = user?.id ?? '-';
        final memberId =
            'IKA-${id.substring(0, id.length > 5 ? 5 : id.length).toUpperCase()}';

        return RepaintBoundary(
          child: Column(
            children: [
              // Greeting & Profile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Alumni! 👋',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Selamat Datang', style: AppTextStyles.h2),
                      ],
                    ),
                    InkWell(
                      onTap: () => context.push('/profile'),
                      borderRadius: BorderRadius.circular(24),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? const Icon(
                                LucideIcons.user,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // E-KTA Preview Card
              GestureDetector(
                onTap: () => context.push('/ekta'),
                child: Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF004D38)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Pattern Decoration
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Icon(
                          LucideIcons.graduationCap,
                          size: 140,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),

                      // Card Content
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  LucideIcons.school,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'PREVIEW',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NAMA LENGKAP',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _InfoColumn(
                                      label: 'ANGKATAN',
                                      value: angkatan,
                                    ),
                                    _InfoColumn(
                                      label: 'NO. ANGGOTA',
                                      value: memberId,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _HeaderSkeleton(),
      error: (error, stack) => const _HeaderSkeleton(),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 14, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 150, height: 24, color: Colors.white),
                  ],
                ),
                const CircleAvatar(),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;

  const _InfoColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 9,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
