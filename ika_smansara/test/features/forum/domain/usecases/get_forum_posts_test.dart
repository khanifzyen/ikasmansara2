import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/forum/domain/entities/forum_post.dart';
import 'package:ika_smansara/features/forum/domain/repositories/forum_repository.dart';
import 'package:ika_smansara/features/forum/domain/usecases/get_forum_posts.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ForumRepository>()])
import 'get_forum_posts_test.mocks.dart';

void main() {
  late GetForumPosts useCase;
  late MockForumRepository mockRepository;

  setUp(() {
    mockRepository = MockForumRepository();
    useCase = GetForumPosts(mockRepository);
  });

  group('GetForumPosts UseCase', () {
    final tPosts = [
      ForumPost(
        id: '1',
        content: 'Post 1',
        images: [],
        category: 'general',
        visibility: 'public',
        likeCount: 10,
        commentCount: 5,
        isPinned: false,
        status: 'active',
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'Author 1',
      ),
      ForumPost(
        id: '2',
        content: 'Post 2',
        images: [],
        category: 'general',
        visibility: 'public',
        likeCount: 20,
        commentCount: 10,
        isPinned: false,
        status: 'active',
        createdAt: DateTime(2025),
        authorId: 'a2',
        authorName: 'Author 2',
      ),
    ];

    test('should get posts from repository', () async {
      // Arrange
      when(mockRepository.getPosts()).thenAnswer((_) async => tPosts);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(tPosts));
      expect(result.length, equals(2));
      verify(mockRepository.getPosts());
    });

    test('should get posts filtered by category', () async {
      // Arrange
      final categoryPosts = [
        ForumPost(
          id: '1',
          content: 'Event post',
          images: [],
          category: 'event',
          visibility: 'public',
          likeCount: 0,
          commentCount: 0,
          isPinned: false,
          status: 'active',
          createdAt: DateTime(2025),
          authorId: 'a1',
          authorName: 'Author',
        ),
      ];
      when(mockRepository.getPosts(category: 'event'))
          .thenAnswer((_) async => categoryPosts);

      // Act
      final result = await useCase(category: 'event');

      // Assert
      expect(result.length, equals(1));
      expect(result[0].category, equals('event'));
      verify(mockRepository.getPosts(category: 'event'));
    });

    test('should return empty list when no posts', () async {
      // Arrange
      when(mockRepository.getPosts()).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to fetch posts');
      when(mockRepository.getPosts()).thenThrow(exception);

      // Act & Assert
      expect(() => useCase(), throwsA(exception));
    });
  });
}
