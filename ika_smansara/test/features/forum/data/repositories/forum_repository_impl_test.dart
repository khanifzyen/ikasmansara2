import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/forum/data/datasources/forum_remote_data_source.dart';
import 'package:ika_smansara/features/forum/data/models/forum_post_model.dart';
import 'package:ika_smansara/features/forum/data/models/forum_comment_model.dart';
import 'package:ika_smansara/features/forum/data/repositories/forum_repository_impl.dart';
import 'package:ika_smansara/features/forum/domain/entities/forum_post.dart';
import 'package:ika_smansara/features/forum/domain/entities/forum_post.dart' as domain show ForumComment;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ForumRemoteDataSource>()])
import 'forum_repository_impl_test.mocks.dart';

void main() {
  late ForumRepositoryImpl repository;
  late MockForumRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockForumRemoteDataSource();
    repository = ForumRepositoryImpl(mockRemoteDataSource);
  });

  group('ForumRepositoryImpl', () {
    final tPostModels = [
      ForumPostModel(
        id: 'post1',
        collectionId: 'col1',
        collectionName: 'posts',
        created: DateTime(2025, 2, 18).toIso8601String(),
        updated: DateTime(2025, 2, 18).toIso8601String(),
        content: 'Test content',
        image: ['img1.jpg', 'img2.jpg'],
        category: 'Discussion',
        visibility: 'public',
        likeCount: 10,
        commentCount: 5,
        isPinned: false,
        status: 'active',
        expand: {
          'user': {
            'id': 'user1',
            'name': 'User One',
            'avatar': 'avatar1.jpg',
          }
        },
      ),
    ];

    group('getPosts', () {
      test('should return list of posts', () async {
        // Arrange
        when(mockRemoteDataSource.getPosts(category: anyNamed('category')))
            .thenAnswer((_) async => tPostModels);

        // Act
        final result = await repository.getPosts(category: 'Discussion');

        // Assert
        expect(result, hasLength(1));
        expect(result[0], isA<ForumPost>());
        expect(result[0].content, equals('Test content'));
        expect(result[0].authorName, equals('User One'));
        verify(mockRemoteDataSource.getPosts(category: 'Discussion'));
      });

      test('should return empty list when no posts', () async {
        // Arrange
        when(mockRemoteDataSource.getPosts(category: anyNamed('category')))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getPosts();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle errors', () async {
        // Arrange
        when(mockRemoteDataSource.getPosts(category: anyNamed('category')))
            .thenThrow(Exception('Failed to load'));

        // Act & Assert
        expect(
          () => repository.getPosts(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createPost', () {
      final tCreatedModel = ForumPostModel(
        id: 'post1',
        collectionId: 'col1',
        collectionName: 'posts',
        created: DateTime(2025, 2, 18).toIso8601String(),
        updated: DateTime(2025, 2, 18).toIso8601String(),
        content: 'Test content',
        image: ['img1.jpg'],
        category: 'Discussion',
        visibility: 'public',
        likeCount: 0,
        commentCount: 0,
        isPinned: false,
        status: 'active',
        expand: {
          'user': {
            'id': 'user1',
            'name': 'User One',
            'avatar': 'avatar1.jpg',
          }
        },
      );

      test('should create post successfully', () async {
        // Arrange
        when(mockRemoteDataSource.createPost(
          any,
          any,
          any,
          any,
        )).thenAnswer((_) async => tCreatedModel);

        // Act
        final result = await repository.createPost(
          'New post content',
          'Discussion',
          'public',
          ['img1.jpg'],
        );

        // Assert
        expect(result, isA<ForumPost>());
        expect(result.content, equals('Test content'));
        expect(result.authorName, equals('User One'));
        verify(mockRemoteDataSource.createPost(
          'New post content',
          'Discussion',
          'public',
          ['img1.jpg'],
        ));
      });

      test('should handle create errors', () async {
        // Arrange
        when(mockRemoteDataSource.createPost(
          any,
          any,
          any,
          any,
        )).thenThrow(Exception('Create failed'));

        // Act & Assert
        expect(
          () => repository.createPost(
            'New content',
            'Discussion',
            'public',
            ['img1.jpg'],
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getComments', () {
      test('should return list of comments', () async {
        // Arrange
        final commentModels = [
          ForumCommentModel(
            id: 'comment1',
            created: DateTime(2025, 2, 18).toIso8601String(),
            content: 'Test comment',
            expand: {
              'user': {
                'id': 'user1',
                'name': 'User One',
                'avatar': 'avatar1.jpg',
              }
            },
          ),
        ];
        when(mockRemoteDataSource.getComments('post1'))
            .thenAnswer((_) async => commentModels);

        // Act
        final result = await repository.getComments('post1');

        // Assert
        expect(result, hasLength(1));
        expect(result[0], isA<domain.ForumComment>());
        expect(result[0].content, equals('Test comment'));
        verify(mockRemoteDataSource.getComments('post1'));
      });

      test('should return empty comments', () async {
        // Arrange
        when(mockRemoteDataSource.getComments('post1'))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getComments('post1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('addComment', () {
      test('should add comment successfully', () async {
        // Arrange
        final commentModel = ForumCommentModel(
          id: 'comment1',
          created: DateTime(2025, 2, 18).toIso8601String(),
          content: 'Test comment',
          expand: {
            'user': {
              'id': 'user1',
              'name': 'User One',
              'avatar': 'avatar1.jpg',
            }
          },
        );
        when(mockRemoteDataSource.addComment('post1', 'New comment'))
            .thenAnswer((_) async => commentModel);

        // Act
        final result = await repository.addComment('post1', 'New comment');

        // Assert
        expect(result, isA<domain.ForumComment>());
        expect(result.content, equals('Test comment'));
        verify(mockRemoteDataSource.addComment('post1', 'New comment'));
      });

      test('should handle add comment errors', () async {
        // Arrange
        when(mockRemoteDataSource.addComment(any, any))
            .thenThrow(Exception('Add failed'));

        // Act & Assert
        expect(
          () => repository.addComment('post1', 'content'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('toggleLike', () {
      test('should toggle like successfully', () async {
        // Arrange
        when(mockRemoteDataSource.toggleLike('post1'))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.toggleLike('post1');

        // Assert
        expect(result, isTrue);
        verify(mockRemoteDataSource.toggleLike('post1'));
      });

      test('should return false when unliked', () async {
        // Arrange
        when(mockRemoteDataSource.toggleLike('post1'))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.toggleLike('post1');

        // Assert
        expect(result, isFalse);
      });

      test('should handle toggle errors', () async {
        // Arrange
        when(mockRemoteDataSource.toggleLike(any))
            .thenThrow(Exception('Toggle failed'));

        // Act & Assert
        expect(
          () => repository.toggleLike('post1'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
