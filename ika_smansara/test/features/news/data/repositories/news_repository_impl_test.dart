import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/news/data/datasources/news_remote_data_source.dart';
import 'package:ika_smansara/features/news/data/models/news_model.dart';
import 'package:ika_smansara/features/news/data/repositories/news_repository_impl.dart';
import 'package:ika_smansara/features/news/domain/entities/news.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<NewsRemoteDataSource>()])
import 'news_repository_impl_test.mocks.dart';

void main() {
  late NewsRepositoryImpl repository;
  late MockNewsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockNewsRemoteDataSource();
    repository = NewsRepositoryImpl(mockRemoteDataSource);
  });

  group('NewsRepositoryImpl', () {
    // Test data
    final tNewsModels = [
      NewsModel(
        id: 'news1',
        title: 'Test News 1',
        slug: 'test-news-1',
        category: 'Technology',
        thumbnail: 'thumb1.jpg',
        summary: 'Test summary',
        content: 'Test content',
        authorId: 'author1',
        expand: null,
        publishDate: DateTime(2025, 2, 18),
        viewCount: 100,
      ),
      NewsModel(
        id: 'news2',
        title: 'Test News 2',
        slug: 'test-news-2',
        category: 'Business',
        thumbnail: null,
        summary: 'Another summary',
        content: 'Another content',
        authorId: 'author2',
        expand: null,
        publishDate: DateTime(2025, 2, 18),
        viewCount: 50,
      ),
    ];

    final tNewsEntities = tNewsModels.map((model) => model.toEntity()).toList();

    group('getNewsList', () {
      test('should return list of news entities from data source', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsList(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenAnswer((_) async => tNewsModels);

        // Act
        final result = await repository.getNewsList(
          page: 1,
          perPage: 10,
          category: 'Technology',
        );

        // Assert
        expect(result, equals(tNewsEntities));
        expect(result, hasLength(2));
        expect(result[0].id, equals('news1'));
        expect(result[0].title, equals('Test News 1'));
        expect(result[0].category, equals('Technology'));
        expect(result[1].id, equals('news2'));
        verify(mockRemoteDataSource.getNewsList(
          page: 1,
          perPage: 10,
          category: 'Technology',
        ));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should return news list with default parameters', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsList(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenAnswer((_) async => tNewsModels);

        // Act
        final result = await repository.getNewsList();

        // Assert
        expect(result, hasLength(2));
        verify(mockRemoteDataSource.getNewsList(
          page: 1,
          perPage: 10,
          category: null,
        ));
      });

      test('should return empty list when no news available', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsList(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getNewsList();

        // Assert
        expect(result, isEmpty);
        verify(mockRemoteDataSource.getNewsList(
          page: 1,
          perPage: 10,
          category: null,
        ));
      });

      test('should handle pagination parameters correctly', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsList(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenAnswer((_) async => tNewsModels);

        // Act
        await repository.getNewsList(
          page: 2,
          perPage: 20,
        );

        // Assert
        verify(mockRemoteDataSource.getNewsList(
          page: 2,
          perPage: 20,
          category: null,
        ));
      });

      test('should handle different categories', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsList(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenAnswer((_) async => tNewsModels);

        // Act
        await repository.getNewsList(category: 'Business');
        await repository.getNewsList(category: 'Technology');

        // Assert
        verify(mockRemoteDataSource.getNewsList(
          page: 1,
          perPage: 10,
          category: 'Business',
        ));
        verify(mockRemoteDataSource.getNewsList(
          page: 1,
          perPage: 10,
          category: 'Technology',
        ));
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('Failed to load news');
        when(mockRemoteDataSource.getNewsList(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.getNewsList(),
          throwsA(exception),
        );
        verify(mockRemoteDataSource.getNewsList(
          page: 1,
          perPage: 10,
          category: null,
        ));
      });

      test('should convert models to entities correctly', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsList(
          page: anyNamed('page'),
          perPage: anyNamed('perPage'),
          category: anyNamed('category'),
        )).thenAnswer((_) async => tNewsModels);

        // Act
        final result = await repository.getNewsList();

        // Assert
        expect(result[0], isA<News>());
        expect(result[0].id, equals(tNewsModels[0].id));
        expect(result[0].title, equals(tNewsModels[0].title));
        expect(result[0].slug, equals(tNewsModels[0].slug));
        expect(result[0].category, equals(tNewsModels[0].category));
      });
    });

    group('getNewsDetail', () {
      final tNewsModel = NewsModel(
        id: 'news1',
        title: 'Test News Detail',
        slug: 'test-news-detail',
        category: 'Technology',
        thumbnail: 'thumb.jpg',
        summary: 'Detailed summary',
        content: 'Detailed content goes here',
        authorId: 'author1',
        expand: {
          'author': {
            'id': 'author1',
            'name': 'Test Author',
            'avatar': 'avatar.jpg',
          }
        },
        publishDate: DateTime(2025, 2, 18),
        viewCount: 150,
      );

      final tNewsEntity = tNewsModel.toEntity();

      test('should return news detail entity from data source', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsDetail('news1'))
            .thenAnswer((_) async => tNewsModel);

        // Act
        final result = await repository.getNewsDetail('news1');

        // Assert
        expect(result, equals(tNewsEntity));
        expect(result.id, equals('news1'));
        expect(result.title, equals('Test News Detail'));
        expect(result.category, equals('Technology'));
        verify(mockRemoteDataSource.getNewsDetail('news1'));
        verifyNoMoreInteractions(mockRemoteDataSource);
      });

      test('should propagate data source error', () async {
        // Arrange
        final exception = Exception('News not found');
        when(mockRemoteDataSource.getNewsDetail('invalid'))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.getNewsDetail('invalid'),
          throwsA(exception),
        );
        verify(mockRemoteDataSource.getNewsDetail('invalid'));
      });

      test('should call data source only once', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsDetail('news1'))
            .thenAnswer((_) async => tNewsModel);

        // Act
        await repository.getNewsDetail('news1');

        // Assert
        verify(mockRemoteDataSource.getNewsDetail('news1')).called(1);
      });

      test('should handle different news IDs', () async {
        // Arrange
        final news2 = NewsModel(
          id: 'news2',
          title: 'Another News',
          slug: 'another-news',
          category: 'Business',
          thumbnail: null,
          summary: 'Summary',
          content: 'Content',
          authorId: 'author2',
          expand: null,
          publishDate: DateTime(2025, 2, 18),
          viewCount: 0,
        );
        when(mockRemoteDataSource.getNewsDetail(any))
            .thenAnswer((_) async => tNewsModel);

        // Act
        await repository.getNewsDetail('news1');
        await repository.getNewsDetail('news2');

        // Assert
        verify(mockRemoteDataSource.getNewsDetail('news1'));
        verify(mockRemoteDataSource.getNewsDetail('news2'));
      });

      test('should convert model to entity correctly', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsDetail('news1'))
            .thenAnswer((_) async => tNewsModel);

        // Act
        final result = await repository.getNewsDetail('news1');

        // Assert
        expect(result, isA<News>());
        expect(result.id, equals(tNewsModel.id));
        expect(result.title, equals(tNewsModel.title));
        expect(result.slug, equals(tNewsModel.slug));
        expect(result.content, equals(tNewsModel.content));
      });

      test('should handle news with expand data', () async {
        // Arrange
        when(mockRemoteDataSource.getNewsDetail('news1'))
            .thenAnswer((_) async => tNewsModel);

        // Act
        final result = await repository.getNewsDetail('news1');

        // Assert
        expect(result.authorId, equals('author1'));
        // The toEntity() method should extract author info from expand
      });

      test('should handle news without thumbnail', () async {
        // Arrange
        final noThumbModel = NewsModel(
          id: 'news1',
          title: 'No Thumb',
          slug: 'no-thumb',
          category: 'Test',
          thumbnail: null,
          summary: 'Summary',
          content: 'Content',
          authorId: 'author1',
          expand: null,
          publishDate: DateTime(2025, 2, 18),
          viewCount: 0,
        );
        when(mockRemoteDataSource.getNewsDetail('news1'))
            .thenAnswer((_) async => noThumbModel);

        // Act
        final result = await repository.getNewsDetail('news1');

        // Assert
        expect(result.thumbnail, isNull);
      });

      test('should handle news with zero view count', () async {
        // Arrange
        final zeroViewModel = NewsModel(
          id: 'news1',
          title: 'New News',
          slug: 'new-news',
          category: 'Test',
          thumbnail: null,
          summary: 'Summary',
          content: 'Content',
          authorId: 'author1',
          expand: null,
          publishDate: DateTime(2025, 2, 18),
          viewCount: 0,
        );
        when(mockRemoteDataSource.getNewsDetail('news1'))
            .thenAnswer((_) async => zeroViewModel);

        // Act
        final result = await repository.getNewsDetail('news1');

        // Assert
        expect(result.viewCount, equals(0));
      });
    });
  });
}
