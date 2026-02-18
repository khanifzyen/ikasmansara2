import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/forum/domain/entities/forum_post.dart';
import 'package:ika_smansara/features/forum/domain/repositories/forum_repository.dart';
import 'package:ika_smansara/features/forum/domain/usecases/add_forum_comment.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ForumRepository>()])
import 'add_forum_comment_test.mocks.dart';

void main() {
  late AddForumComment useCase;
  late MockForumRepository mockRepository;

  setUp(() {
    mockRepository = MockForumRepository();
    useCase = AddForumComment(mockRepository);
  });

  group('AddForumComment UseCase', () {
    final tComment = ForumComment(
      id: 'c1',
      content: 'New comment',
      createdAt: DateTime(2025, 2, 18),
      authorId: 'author1',
      authorName: 'Commenter',
      authorAvatar: 'commenter.jpg',
    );

    test('should add comment to post', () async {
      // Arrange
      when(mockRepository.addComment('post1', 'New comment'))
          .thenAnswer((_) async => tComment);

      // Act
      final result = await useCase(postId: 'post1', content: 'New comment');

      // Assert
      expect(result, equals(tComment));
      expect(result.content, equals('New comment'));
      verify(mockRepository.addComment('post1', 'New comment'));
    });

    test('should add comment with empty content', () async {
      // Arrange
      final emptyComment = ForumComment(
        id: 'c2',
        content: '',
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'Author',
      );
      when(mockRepository.addComment('post1', ''))
          .thenAnswer((_) async => emptyComment);

      // Act
      final result = await useCase(postId: 'post1', content: '');

      // Assert
      expect(result.content, equals(''));
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Post not found');
      when(mockRepository.addComment('invalid', 'test'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(postId: 'invalid', content: 'test'),
        throwsA(exception),
      );
    });

    test('should handle very long comment', () async {
      // Arrange
      final longContent = 'A' * 1000;
      final longComment = ForumComment(
        id: 'c3',
        content: longContent,
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'LongWriter',
      );
      when(mockRepository.addComment('post1', longContent))
          .thenAnswer((_) async => longComment);

      // Act
      final result = await useCase(postId: 'post1', content: longContent);

      // Assert
      expect(result.content.length, equals(1000));
    });
  });
}
