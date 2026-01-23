import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikasmansara_app/common_widgets/buttons/outline_button.dart';
import 'package:ikasmansara_app/common_widgets/buttons/primary_button.dart';
import 'package:ikasmansara_app/core/theme/app_colors.dart';
import 'package:ikasmansara_app/core/theme/app_text_styles.dart';
import 'package:ikasmansara_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ikasmansara_app/features/profile/presentation/profile_controller.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to settings
            },
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              ref.read(authRemoteDataSourceProvider).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(profileControllerProvider.notifier).loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: profileState.when(
            data: (profile) {
              if (profile == null) {
                return const Center(child: Text('User not found'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Name & Role
                  Text(profile.name, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.job ?? 'Alumni'} • Angkatan ${profile.angkatan ?? '-'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Edit Profil',
                          onPressed: () => context.push('/profile/edit'),
                          // height: 40, // PrimaryButton doesn't support height, defaults to 56.
                          // It's fine for now or I could wrap it.
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlineButton(
                          text: 'Lihat E-KTA',
                          onPressed: () => context.push('/ekta'),
                          // height: 40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bio Section
                  _InfoSection(
                    title: 'Bio',
                    content: profile.bio ?? 'Belum ada bio.',
                  ),

                  const Divider(height: 32),

                  // Contact Info
                  _InfoSection(title: 'Email', content: profile.email),
                  _InfoSection(
                    title: 'No. Telepon',
                    content: profile.phone ?? '-',
                  ),
                  _InfoSection(
                    title: 'LinkedIn',
                    content: profile.linkedin ?? '-',
                  ),
                  _InfoSection(
                    title: 'Instagram',
                    content: profile.instagram ?? '-',
                  ),
                ],
              );
            },
            loading: () => _buildLoadingState(),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: const CircleAvatar(radius: 50),
        ),
        const SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(height: 20, width: 150, color: Colors.white),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const _InfoSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Expanded(child: Text(content, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
