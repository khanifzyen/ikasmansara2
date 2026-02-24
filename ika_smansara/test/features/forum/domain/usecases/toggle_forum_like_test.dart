import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/forum/domain/entities/forum_post.dart';
import 'package:ika_smansara/features/forum/domain/repositories/forum_repository.dart';
import 'package:ika_smansara/features/forum/domain/usecases/toggle_forum_like.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ForumRepository>()])
import 'toggle_forum_like_test.mocks.dart';

void main() {
  late ToggleForumLike useCase;
  late MockForumRepository mockRepository;

  setUp(() {
    mockRepository = MockForumRepository();
    useCase = ToggleForumLike(mockRepository);
  });

  group('ToggleForumLike UseCase', () {
    test('should toggle like to true', () async {
      // Arrange
      when(mockRepository.toggleLike('post1'))
          .thenAnswer((_) async => true);

      // Act
      final result = await useCase('post1');

      // Assert
      expect(result, isTrue);
      verify(mockRepository.toggleLike('post1'));
    });

    test('should toggle like to false', () async {
      // Arrange
      when(mockRepository.toggleLike('post1'))
          .thenAnswer((_) async => false);

      // Act
      final result = await useCase('post1');

      // Assert
      expect(result, isFalse);
      verify(mockRepository.toggleLike('post1'));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Post not found');
      when(mockRepository.toggleLike('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('invalid'),
        throwsA(exception),
      );
    });

    test('should call repository with correct post ID', () async {
      // Arrange
      when(mockRepository.toggleLike('post123'))
          .thenAnswer((_) async => true);

      // Act
      await useCase('post123');

      // Assert
      verify(mockRepository.toggleLike('post123')).called(1);
    });
  });
}
