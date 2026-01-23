import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../common_widgets/layout/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'directory_controller.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(directoryControllerProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(directoryControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Sticky Search Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Direktori Alumni', style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  Container(
                    // Reusing text field logic manually if SearchBarWidget isn't perfect fit or use standard TextField
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama, angkatan, atau instansi...',
                        prefixIcon: Icon(
                          LucideIcons.search,
                          color: AppColors.textGrey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Filter Chips
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isActive:
                        state.filterAngkatan == null && state.filterJob == null,
                    onTap: () {
                      ref
                          .read(directoryControllerProvider.notifier)
                          .resetFilters();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Angkatan 2010',
                    isActive: state.filterAngkatan == '2010',
                    onTap: () {
                      final isSelected = state.filterAngkatan == '2010';
                      ref
                          .read(directoryControllerProvider.notifier)
                          .setAngkatanFilter(isSelected ? null : '2010');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'PNS',
                    isActive: state.filterJob == 'PNS',
                    onTap: () {
                      final isSelected = state.filterJob == 'PNS';
                      ref
                          .read(directoryControllerProvider.notifier)
                          .setJobFilter(isSelected ? null : 'PNS');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Wirausaha',
                    isActive: state.filterJob == 'Wirausaha',
                    onTap: () {
                      final isSelected = state.filterJob == 'Wirausaha';
                      ref
                          .read(directoryControllerProvider.notifier)
                          .setJobFilter(isSelected ? null : 'Wirausaha');
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'BUMN',
                    isActive: state.filterJob == 'BUMN',
                    onTap: () {
                      final isSelected = state.filterJob == 'BUMN';
                      ref
                          .read(directoryControllerProvider.notifier)
                          .setJobFilter(isSelected ? null : 'BUMN');
                    },
                  ),
                ],
              ),
            ),

            // 3. Alumni List
            Expanded(
              child: state.alumniList.when(
                data: (alumni) {
                  if (alumni.isEmpty) {
                    return const EmptyState(
                      title: 'Data Kosong',
                      message: 'Data alumni tidak ditemukan',
                      icon: LucideIcons.searchX,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: alumni.length,
                    itemBuilder: (context, index) {
                      final item = alumni[index];
                      // Use MemberCard
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
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
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                // Need base URL logic here or pre-resolved URL
                                'https://ui-avatars.com/api/?name=${item.name.replaceAll(' ', '+')}&background=random',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Angkatan ${item.angkatan}',
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.fullJobTitle,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.userPlus,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fitur Connect akan segera hadir',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat data\nCheck your connection or credentials.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(directoryControllerProvider.notifier)
                              .loadAlumni(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Peta akan muncul disini')),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(LucideIcons.map, color: AppColors.primary),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.primary : AppColors.textGrey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
