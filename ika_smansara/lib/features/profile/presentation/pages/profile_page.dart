import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_breakpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/pb_client.dart';
import '../../../../core/widgets/adaptive/adaptive_spacing.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/profile_bloc.dart';

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(FetchProfile()),
      child: Scaffold(
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is ProfileLoaded ||
                state is ProfileUpdateSuccess) {
              final user = (state is ProfileLoaded)
                  ? state.user
                  : (state as ProfileUpdateSuccess).user;
              final screenWidth = MediaQuery.sizeOf(context).width;
              final isSmallScreen = screenWidth < 600;
              final topPadding = MediaQuery.paddingOf(context).top;
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildHeader(context, user),
                  ),
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: topPadding + (isSmallScreen ? 90 : 140),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppBreakpoints.maxFormWidth,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 55),
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                AdaptiveSpacingV(multiplier: 1.0),
                                Text(
                                  user.isAlumni
                                      ? 'Alumni Angkatan ${user.angkatan ?? '-'}'
                                      : 'Masyarakat Umum',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                if (user.jobStatus != null) ...[
                                  AdaptiveSpacingV(multiplier: 1.0),
                                  Text(
                                    user.jobStatus!.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                AdaptiveSpacingV(multiplier: 6.0),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSizes.horizontalPadding(
                                      context,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        _ProfileMenuItem(
                                          icon: Icons.person_outline,
                                          label: 'Edit Profil',
                                          onTap: () {
                                            final bloc = context
                                                .read<ProfileBloc>();
                                            context
                                                .push(
                                                  '/profile/edit',
                                                  extra: user,
                                                )
                                                .then((_) {
                                                  bloc.add(FetchProfile());
                                                });
                                          },
                                        ),
                                        const Divider(height: 1),
                                        _ProfileMenuItem(
                                          icon: Icons.card_membership,
                                          label: 'E-KTA Digital',
                                          onTap: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Fitur E-KTA Digital akan segera hadir!',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const Divider(height: 1),
                                        _ProfileMenuItem(
                                          icon: Icons.settings_outlined,
                                          label: 'Pengaturan',
                                          onTap: () {
                                            context.push('/settings');
                                          },
                                        ),
                                        const Divider(height: 1),
                                        _ProfileMenuItem(
                                          icon: Icons.help_outline,
                                          label: 'Bantuan',
                                          onTap: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Fitur Bantuan segera hadir',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AdaptiveSpacingV(multiplier: 6.0),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: TextButton(
                                    onPressed: () {
                                      PBClient.instance.logout();
                                      context.go('/login');
                                    },
                                    child: Text(
                                      'Keluar',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                AdaptiveSpacingV(multiplier: 10.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity user) {
    final avatarUrl = (user.avatar != null && user.avatar!.isNotEmpty)
        ? '${AppConstants.pocketBaseUrl}/api/files/users/${user.id}/${user.avatar}'
        : null;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 600;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      height: topPadding + (isSmallScreen ? 90 : 140),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF004D38)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: topPadding + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          Positioned(
            top: topPadding + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Profil Saya',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: isSmallScreen ? -50 : -45,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.push('/profile/edit', extra: user),
                child: Hero(
                  tag: 'profile-avatar-${user.id}',
                  child: Container(
                    width: isSmallScreen ? 80 : 90,
                    height: isSmallScreen ? 80 : 90,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: avatarUrl != null
                          ? CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/logo-ika.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/logo-ika.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
