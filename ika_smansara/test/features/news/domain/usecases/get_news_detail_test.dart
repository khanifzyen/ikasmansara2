import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/news/domain/entities/news.dart';
import 'package:ika_smansara/features/news/domain/repositories/news_repository.dart';
import 'package:ika_smansara/features/news/domain/usecases/get_news_detail.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<NewsRepository>()])
import 'get_news_detail_test.mocks.dart';

void main() {
  late GetNewsDetail useCase;
  late MockNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockNewsRepository();
    useCase = GetNewsDetail(mockRepository);
  });

  group('GetNewsDetail UseCase', () {
    final tNews = News(
      id: '1',
      title: 'Detailed News Title',
      slug: 'detailed-news-title',
      category: 'announcement',
      thumbnail: 'detailed-thumb.jpg',
      summary: 'This is a detailed summary',
      content: 'Full detailed content with lots of information',
      authorId: 'author1',
      authorName: 'Jane Doe',
      authorAvatar: 'jane-avatar.jpg',
      publishDate: DateTime(2025, 2, 18, 10, 30),
      viewCount: 500,
    );

    test('should get news detail from repository', () async {
      // Arrange
      when(mockRepository.getNewsDetail('1'))
          .thenAnswer((_) async => tNews);

      // Act
      final result = await useCase('1');

      // Assert
      expect(result, equals(tNews));
      expect(result.id, equals('1'));
      expect(result.title, equals('Detailed News Title'));
      expect(result.content, contains('lots of information'));
      verify(mockRepository.getNewsDetail('1'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error for not found', () async {
      // Arrange
      final exception = Exception('News not found');
      when(mockRepository.getNewsDetail('invalid'))
          .thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase('invalid'),
        throwsA(exception),
      );
      verify(mockRepository.getNewsDetail('invalid'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository with correct ID', () async {
      // Arrange
      when(mockRepository.getNewsDetail('news123'))
          .thenAnswer((_) async => tNews);

      // Act
      await useCase('news123');

      // Assert
      verify(mockRepository.getNewsDetail('news123')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle news without thumbnail', () async {
      // Arrange
      final newsNoThumbnail = News(
        id: '2',
        title: 'News Without Thumbnail',
        slug: 'news-without-thumbnail',
        category: 'update',
        summary: 'Summary',
        content: 'Content',
        authorId: 'author2',
        publishDate: DateTime(2025),
        viewCount: 0,
      );
      when(mockRepository.getNewsDetail('2'))
          .thenAnswer((_) async => newsNoThumbnail);

      // Act
      final result = await useCase('2');

      // Assert
      expect(result.thumbnail, isNull);
      expect(result.id, equals('2'));
    });

    test('should handle news without author info', () async {
      // Arrange
      final newsNoAuthor = News(
        id: '3',
        title: 'System News',
        slug: 'system-news',
        category: 'system',
        summary: 'System announcement',
        content: 'System content',
        authorId: 'system',
        publishDate: DateTime(2025),
        viewCount: 1000,
      );
      when(mockRepository.getNewsDetail('3'))
          .thenAnswer((_) async => newsNoAuthor);

      // Act
      final result = await useCase('3');

      // Assert
      expect(result.authorName, isNull);
      expect(result.authorAvatar, isNull);
      expect(result.authorId, equals('system'));
    });
  });

  group('GetNewsDetail UseCase - Edge Cases', () {
    test('should handle news with zero view count', () async {
      // Arrange
      final zeroViewNews = News(
        id: '1',
        title: 'New Unread News',
        slug: 'new-unread-news',
        category: 'test',
        summary: 'Summary',
        content: 'Content',
        authorId: 'author1',
        publishDate: DateTime(2025),
        viewCount: 0,
      );
      when(mockRepository.getNewsDetail('1'))
          .thenAnswer((_) async => zeroViewNews);

      // Act
      final result = await useCase('1');

      // Assert
      expect(result.viewCount, equals(0));
    });

    test('should handle news with very high view count', () async {
      // Arrange
      final viralNews = News(
        id: '1',
        title: 'Viral News',
        slug: 'viral-news',
        category: 'trending',
        summary: 'Viral summary',
        content: 'Viral content',
        authorId: 'author1',
        publishDate: DateTime(2025),
        viewCount: 999999,
      );
      when(mockRepository.getNewsDetail('1'))
          .thenAnswer((_) async => viralNews);

      // Act
      final result = await useCase('1');

      // Assert
      expect(result.viewCount, equals(999999));
    });

    test('should handle very long slug', () async {
      // Arrange
      final longSlug = 'this-is-a-very-long-slug-that-contains-many-words-and-describes-the-article-in-great-detail';
      final longSlugNews = News(
        id: '1',
        title: 'Long Slug News',
        slug: longSlug,
        category: 'test',
        summary: 'Summary',
        content: 'Content',
        authorId: 'author1',
        publishDate: DateTime(2025),
        viewCount: 0,
      );
      when(mockRepository.getNewsDetail('1'))
          .thenAnswer((_) async => longSlugNews);

      // Act
      final result = await useCase('1');

      // Assert
      expect(result.slug.length, greaterThan(50));
    });
  });
}
