import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ikasmansara_app/features/directory/domain/usecases/search_alumni.dart';
import 'package:ikasmansara_app/features/directory/domain/entities/alumni_entity.dart';
import 'package:ikasmansara_app/features/directory/presentation/directory_controller.dart';

// Generate Mocks
class MockSearchAlumni extends Mock implements SearchAlumni {
  @override
  Future<List<AlumniEntity>> call({
    String? query,
    int? angkatan,
    String? jobType,
    String? domicile,
  }) {
    return super.noSuchMethod(
      Invocation.method(#call, [], {
        #query: query,
        #angkatan: angkatan,
        #jobType: jobType,
        #domicile: domicile,
      }),
      returnValue: Future.value(<AlumniEntity>[]),
      returnValueForMissingStub: Future.value(<AlumniEntity>[]),
    );
  }
}

void main() {
  late MockSearchAlumni mockSearchAlumni;
  late ProviderContainer container;

  setUp(() {
    mockSearchAlumni = MockSearchAlumni();
    container = ProviderContainer(
      overrides: [
        searchAlumniUseCaseProvider.overrideWithValue(mockSearchAlumni),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'DirectoryController initial state should be loading then data',
    () async {
      // Arrange
      when(mockSearchAlumni()).thenAnswer((_) async => []);

      // Act
      // final controller = container.read(directoryControllerProvider.notifier);
      // State is initialized in constructor, so initially loading.

      // Assert
      expect(
        container.read(directoryControllerProvider).alumniList,
        isA<AsyncLoading>(),
      );

      // Wait for loadAlumni to complete
      await Future.delayed(Duration.zero);

      // Verify valid data state
      expect(
        container.read(directoryControllerProvider).alumniList,
        isA<AsyncData>(),
      );
    },
  );

  test(
    'search(query) should update searchQuery and trigger loadAlumni',
    () async {
      // Arrange
      when(mockSearchAlumni(query: 'Budi')).thenAnswer((_) async => []);

      // Act
      final controller = container.read(directoryControllerProvider.notifier);
      controller.search('Budi');

      // Assert
      expect(container.read(directoryControllerProvider).searchQuery, 'Budi');
      // Wait for async
      await Future.delayed(Duration.zero);

      verify(mockSearchAlumni(query: 'Budi')).called(1);
    },
  );

  test('search with same query should NOT trigger loadAlumni', () async {
    // Arrange
    when(mockSearchAlumni(query: 'Budi')).thenAnswer((_) async => []);

    // Act
    final controller = container.read(directoryControllerProvider.notifier);
    controller.search('Budi');
    await Future.delayed(Duration.zero);
    controller.search('Budi'); // Duplicate call

    // Assert
    verify(mockSearchAlumni(query: 'Budi')).called(1); // Should still be 1
  });

  test('resetFilters should clear filters and trigger loadAlumni', () async {
    // Arrange
    when(mockSearchAlumni(angkatan: 2010)).thenAnswer((_) async => []);
    when(mockSearchAlumni()).thenAnswer((_) async => []);

    // Act
    final controller = container.read(directoryControllerProvider.notifier);
    controller.setAngkatanFilter('2010');
    await Future.delayed(Duration.zero);

    controller.resetFilters();
    await Future.delayed(Duration.zero);

    // Assert
    final state = container.read(directoryControllerProvider);
    expect(state.filterAngkatan, null);
    expect(state.filterJob, null);
    // Initial load (constructor) passes query: ''
    // Reset load passes query: ''
    verify(mockSearchAlumni(query: '')).called(2);
  });
}
