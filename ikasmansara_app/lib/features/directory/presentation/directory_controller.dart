import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ikasmansara_app/features/directory/data/datasources/directory_remote_data_source.dart';
import 'package:ikasmansara_app/features/directory/data/repositories/directory_repository_impl.dart';
import 'package:ikasmansara_app/features/directory/domain/entities/alumni_entity.dart';
import 'package:ikasmansara_app/features/directory/domain/repositories/directory_repository.dart';
import 'package:ikasmansara_app/features/directory/domain/usecases/search_alumni.dart';
import 'package:ikasmansara_app/core/network/pocketbase_service.dart'; // Added this import

// 1. Providers
final directoryRepositoryProvider = Provider<DirectoryRepository>((ref) {
  final pbService = PocketBaseService();
  final remoteDataSource = DirectoryRemoteDataSourceImpl(pbService.pb);
  return DirectoryRepositoryImpl(remoteDataSource);
});

final searchAlumniUseCaseProvider = Provider<SearchAlumni>((ref) {
  final repo = ref.watch(directoryRepositoryProvider);
  return SearchAlumni(repo);
});

// 2. Controller State
class DirectoryState {
  final AsyncValue<List<AlumniEntity>> alumniList;
  final String searchQuery;
  final String?
  filterAngkatan; // Change to String to handle "Semua" or allow parsing
  final String? filterJob;
  final String? filterDomicile;

  DirectoryState({
    required this.alumniList,
    this.searchQuery = '',
    this.filterAngkatan,
    this.filterJob,
    this.filterDomicile,
  });

  DirectoryState copyWith({
    AsyncValue<List<AlumniEntity>>? alumniList,
    String? searchQuery,
    String? filterAngkatan,
    String? filterJob,
    String? filterDomicile,
  }) {
    return DirectoryState(
      alumniList: alumniList ?? this.alumniList,
      searchQuery: searchQuery ?? this.searchQuery,
      filterAngkatan: filterAngkatan ?? this.filterAngkatan,
      filterJob: filterJob ?? this.filterJob,
      filterDomicile: filterDomicile ?? this.filterDomicile,
    );
  }
}

// 3. Controller
class DirectoryController extends StateNotifier<DirectoryState> {
  final SearchAlumni _searchAlumni;

  DirectoryController(this._searchAlumni)
    : super(DirectoryState(alumniList: const AsyncValue.loading())) {
    loadAlumni();
  }

  Future<void> loadAlumni() async {
    state = state.copyWith(alumniList: const AsyncValue.loading());
    try {
      // Parse angkatan safe
      int? angkatanInt;
      if (state.filterAngkatan != null && state.filterAngkatan != 'Semua') {
        angkatanInt = int.tryParse(state.filterAngkatan!);
      }

      final result = await _searchAlumni(
        query: state.searchQuery,
        angkatan: angkatanInt,
        jobType: state.filterJob == 'Semua' ? null : state.filterJob,
        domicile: state.filterDomicile == 'Semua' ? null : state.filterDomicile,
      );
      state = state.copyWith(alumniList: AsyncValue.data(result));
    } catch (e, st) {
      state = state.copyWith(alumniList: AsyncValue.error(e, st));
    }
  }

  void search(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);
    loadAlumni();
  }

  void setAngkatanFilter(String? value) {
    if (state.filterAngkatan == value) return;
    state = DirectoryState(
      alumniList: state.alumniList,
      searchQuery: state.searchQuery,
      filterAngkatan: value,
      filterJob: state.filterJob,
      filterDomicile: state.filterDomicile,
    );
    loadAlumni();
  }

  void setJobFilter(String? value) {
    if (state.filterJob == value) return;
    state = DirectoryState(
      alumniList: state.alumniList,
      searchQuery: state.searchQuery,
      filterAngkatan: state.filterAngkatan,
      filterJob: value,
      filterDomicile: state.filterDomicile,
    );
    loadAlumni();
  }

  void resetFilters() {
    if (state.filterAngkatan == null && state.filterJob == null) return;
    state = DirectoryState(
      alumniList: state.alumniList,
      searchQuery: state.searchQuery,
      // Filters reset to null by default
    );
    loadAlumni();
  }
}

final directoryControllerProvider =
    StateNotifierProvider<DirectoryController, DirectoryState>((ref) {
      final searchUseCase = ref.watch(searchAlumniUseCaseProvider);
      return DirectoryController(searchUseCase);
    });
