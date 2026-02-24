import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/forum/domain/entities/forum_post.dart';
import 'package:ika_smansara/features/forum/domain/repositories/forum_repository.dart';
import 'package:ika_smansara/features/forum/domain/usecases/create_forum_post.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ForumRepository>()])
import 'create_forum_post_test.mocks.dart';

void main() {
  late CreateForumPost useCase;
  late MockForumRepository mockRepository;

  setUp(() {
    mockRepository = MockForumRepository();
    useCase = CreateForumPost(mockRepository);
  });

  group('CreateForumPost UseCase', () {
    final tPost = ForumPost(
      id: '1',
      content: 'New post content',
      images: ['image1.jpg', 'image2.jpg'],
      category: 'general',
      visibility: 'public',
      likeCount: 0,
      commentCount: 0,
      isPinned: false,
      status: 'active',
      createdAt: DateTime(2025),
      authorId: 'author1',
      authorName: 'Author Name',
    );

    test('should create post with all parameters', () async {
      // Arrange
      when(mockRepository.createPost(
        'New post content',
        'general',
        'public',
        ['image1.jpg', 'image2.jpg'],
      )).thenAnswer((_) async => tPost);

      // Act
      final result = await useCase(
        content: 'New post content',
        category: 'general',
        visibility: 'public',
        images: ['image1.jpg', 'image2.jpg'],
      );

      // Assert
      expect(result, equals(tPost));
      verify(mockRepository.createPost(
        'New post content',
        'general',
        'public',
        ['image1.jpg', 'image2.jpg'],
      ));
    });

    test('should create post without images', () async {
      // Arrange
      final postNoImages = ForumPost(
        id: '2',
        content: 'Text only post',
        images: [],
        category: 'question',
        visibility: 'public',
        likeCount: 0,
        commentCount: 0,
        isPinned: false,
        status: 'active',
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'Author',
      );
      when(mockRepository.createPost(
        'Text only post',
        'question',
        'public',
        [],
      )).thenAnswer((_) async => postNoImages);

      // Act
      final result = await useCase(
        content: 'Text only post',
        category: 'question',
        visibility: 'public',
        images: [],
      );

      // Assert
      expect(result.images, isEmpty);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to create post');
      when(mockRepository.createPost(
        any,
        any,
        any,
        any,
      )).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(
          content: 'Test',
          category: 'test',
          visibility: 'public',
          images: [],
        ),
        throwsA(exception),
      );
    });
  });
}
