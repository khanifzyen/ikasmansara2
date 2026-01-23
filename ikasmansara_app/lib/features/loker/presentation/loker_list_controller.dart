import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikasmansara_app/features/loker/presentation/providers/loker_providers.dart';

import '../domain/entities/job_entity.dart';
import '../domain/usecases/get_jobs.dart';

final lokerListControllerProvider =
    NotifierProvider.autoDispose<LokerListController, LokerListState>(
      LokerListController.new,
    );

// --- State ---

class LokerListState extends Equatable {
  final AsyncValue<List<JobEntity>> jobs;
  final String searchQuery;
  final String selectedType; // 'Semua', 'Fulltime', 'Internship', 'Remote'

  const LokerListState({
    required this.jobs,
    this.searchQuery = '',
    this.selectedType = 'Semua',
  });

  factory LokerListState.initial() {
    return const LokerListState(jobs: AsyncValue.loading());
  }

  LokerListState copyWith({
    AsyncValue<List<JobEntity>>? jobs,
    String? searchQuery,
    String? selectedType,
  }) {
    return LokerListState(
      jobs: jobs ?? this.jobs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object> get props => [jobs, searchQuery, selectedType];
}

// --- Controller ---

class LokerListController extends AutoDisposeNotifier<LokerListState> {
  // Use a getter to access the dependency lazily
  GetJobs get _getJobs =>
      ref.read(getJobsUseCaseProvider as ProviderListenable<GetJobs>);

  @override
  LokerListState build() {
    // Load jobs initially. Using microtask to avoid building state synchronously during build.
    Future.microtask(() => loadJobs());
    return LokerListState.initial();
  }

  Future<void> loadJobs() async {
    // Avoid setting state if invalid
    state = state.copyWith(jobs: const AsyncValue.loading());
    try {
      final jobs = await _getJobs(
        query: state.searchQuery,
        type: state.selectedType,
      );
      state = state.copyWith(jobs: AsyncValue.data(jobs));
    } catch (e, stack) {
      state = state.copyWith(jobs: AsyncValue.error(e, stack));
    }
  }

  void search(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    loadJobs();
  }

  void filterByType(String type) {
    if (state.selectedType == type) return;
    state = state.copyWith(selectedType: type);
    loadJobs();
  }

  void refresh() {
    loadJobs();
  }
}
