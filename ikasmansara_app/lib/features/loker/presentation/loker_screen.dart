import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../common_widgets/cards/job_card.dart';
import '../../../common_widgets/inputs/search_bar.dart';
import '../../../common_widgets/layout/empty_state.dart';
import '../../../common_widgets/layout/filter_chips.dart';
import '../../../common_widgets/layout/loading_shimmer.dart';
import '../../../core/theme/app_colors.dart';
import 'loker_list_controller.dart';

class LokerScreen extends ConsumerStatefulWidget {
  const LokerScreen({super.key});

  @override
  ConsumerState<LokerScreen> createState() => _LokerScreenState();
}

class _LokerScreenState extends ConsumerState<LokerScreen> {
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
      ref.read(lokerListControllerProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lokerListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lowongan Kerja',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchBarInput(
                    controller: _searchController,
                    hintText: 'Cari posisi, perusahaan...',
                    onChanged: _onSearchChanged,
                  ),
                ],
              ),
            ),

            // Filters
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 16),
              child: FilterChips(
                items: const [
                  'Semua',
                  'Fulltime',
                  'Internship',
                  'Remote',
                  'Contract',
                ],
                selectedIndex: [
                  'Semua',
                  'Fulltime',
                  'Internship',
                  'Remote',
                  'Contract',
                ].indexOf(state.selectedType),
                onSelected: (index) {
                  final items = [
                    'Semua',
                    'Fulltime',
                    'Internship',
                    'Remote',
                    'Contract',
                  ];
                  ref
                      .read(lokerListControllerProvider.notifier)
                      .filterByType(items[index]);
                },
              ),
            ),

            // Content
            Expanded(
              child: state.jobs.when(
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref
                            .read(lokerListControllerProvider.notifier)
                            .refresh();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const EmptyState(
                            title: 'Tidak Ditemukan',
                            message: 'Belum ada lowongan pekerjaan saat ini',
                            icon: LucideIcons.briefcase,
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.read(lokerListControllerProvider.notifier).refresh();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: jobs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return JobCard(
                          title: job.title,
                          company: job.company,
                          location: job.location,
                          jobType: job.type,
                          datePosted: 'Baru saja', // TODO: Format relative time
                          onTap: () {
                            context.push('/loker/${job.id}');
                          },
                        );
                      },
                    ),
                  );
                },
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(lokerListControllerProvider.notifier)
                              .refresh();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
                loading: () => LoadingShimmer.list(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/loker/post');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
