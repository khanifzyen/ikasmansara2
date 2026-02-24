import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/forum/domain/entities/forum_post.dart';
import 'package:ika_smansara/features/forum/domain/repositories/forum_repository.dart';
import 'package:ika_smansara/features/forum/domain/usecases/get_forum_comments.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ForumRepository>()])
import 'get_forum_comments_test.mocks.dart';

void main() {
  late GetForumComments useCase;
  late MockForumRepository mockRepository;

  setUp(() {
    mockRepository = MockForumRepository();
    useCase = GetForumComments(mockRepository);
  });

  group('GetForumComments UseCase', () {
    final tComments = [
      ForumComment(
        id: 'c1',
        content: 'Comment 1',
        createdAt: DateTime(2025, 1, 1),
        authorId: 'a1',
        authorName: 'Commenter 1',
        authorAvatar: 'avatar1.jpg',
      ),
      ForumComment(
        id: 'c2',
        content: 'Comment 2',
        createdAt: DateTime(2025, 1, 2),
        authorId: 'a2',
        authorName: 'Commenter 2',
      ),
    ];

    test('should get comments for a post', () async {
      // Arrange
      when(mockRepository.getComments('post1'))
          .thenAnswer((_) async => tComments);

      // Act
      final result = await useCase('post1');

      // Assert
      expect(result, equals(tComments));
      expect(result.length, equals(2));
      expect(result[0].content, equals('Comment 1'));
      verify(mockRepository.getComments('post1'));
    });

    test('should return empty list when no comments', () async {
      // Arrange
      when(mockRepository.getComments('post1'))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase('post1');

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Post not found');
      when(mockRepository.getComments('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('invalid'),
        throwsA(exception),
      );
    });

    test('should handle comments without avatars', () async {
      // Arrange
      final commentsNoAvatar = [
        ForumComment(
          id: 'c1',
          content: 'No avatar comment',
          createdAt: DateTime(2025),
          authorId: 'a1',
          authorName: 'NoAvatar',
        ),
      ];
      when(mockRepository.getComments('post1'))
          .thenAnswer((_) async => commentsNoAvatar);

      // Act
      final result = await useCase('post1');

      // Assert
      expect(result[0].authorAvatar, isNull);
    });
  });
}
