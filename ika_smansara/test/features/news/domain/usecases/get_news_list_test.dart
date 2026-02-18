import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/news/domain/entities/news.dart';
import 'package:ika_smansara/features/news/domain/repositories/news_repository.dart';
import 'package:ika_smansara/features/news/domain/usecases/get_news_list.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<NewsRepository>()])
import 'get_news_list_test.mocks.dart';

void main() {
  late GetNewsList useCase;
  late MockNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockNewsRepository();
    useCase = GetNewsList(mockRepository);
  });

  group('GetNewsList UseCase', () {
    final tNewsList = [
      News(
        id: '1',
        title: 'News 1',
        slug: 'news-1',
        category: 'announcement',
        thumbnail: 'thumb1.jpg',
        summary: 'Summary 1',
        content: 'Content 1',
        authorId: 'author1',
        authorName: 'Author 1',
        publishDate: DateTime(2025, 1, 1),
        viewCount: 100,
      ),
      News(
        id: '2',
        title: 'News 2',
        slug: 'news-2',
        category: 'event',
        thumbnail: 'thumb2.jpg',
        summary: 'Summary 2',
        content: 'Content 2',
        authorId: 'author2',
        authorName: 'Author 2',
        publishDate: DateTime(2025, 1, 2),
        viewCount: 200,
      ),
    ];

    test('should get news list from repository', () async {
      // Arrange
      when(mockRepository.getNewsList())
          .thenAnswer((_) async => tNewsList);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(tNewsList));
      expect(result.length, equals(2));
      verify(mockRepository.getNewsList());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get news list with pagination', () async {
      // Arrange
      when(mockRepository.getNewsList(page: 2, perPage: 20))
          .thenAnswer((_) async => tNewsList);

      // Act
      final result = await useCase(page: 2, perPage: 20);

      // Assert
      expect(result, equals(tNewsList));
      verify(mockRepository.getNewsList(page: 2, perPage: 20));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should get news list filtered by category', () async {
      // Arrange
      final categoryNews = [
        News(
          id: '1',
          title: 'Event News',
          slug: 'event-news',
          category: 'event',
          summary: 'Event summary',
          content: 'Event content',
          authorId: 'author1',
          publishDate: DateTime(2025),
          viewCount: 50,
        ),
      ];
      when(mockRepository.getNewsList(category: 'event'))
          .thenAnswer((_) async => categoryNews);

      // Act
      final result = await useCase(category: 'event');

      // Assert
      expect(result.length, equals(1));
      expect(result[0].category, equals('event'));
      verify(mockRepository.getNewsList(category: 'event'));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no news', () async {
      // Arrange
      when(mockRepository.getNewsList()).thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getNewsList());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository error', () async {
      // Arrange
      final exception = Exception('Failed to fetch news');
      when(mockRepository.getNewsList()).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(exception),
      );
      verify(mockRepository.getNewsList());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass all parameters correctly', () async {
      // Arrange
      when(mockRepository.getNewsList(
        page: 3,
        perPage: 15,
        category: 'announcement',
      )).thenAnswer((_) async => tNewsList);

      // Act
      await useCase(page: 3, perPage: 15, category: 'announcement');

      // Assert
      verify(mockRepository.getNewsList(
        page: 3,
        perPage: 15,
        category: 'announcement',
      ));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetNewsList UseCase - Edge Cases', () {
    test('should handle single news item', () async {
      // Arrange
      final singleNews = [
        News(
          id: '1',
          title: 'Single News',
          slug: 'single-news',
          category: 'test',
          summary: 'Summary',
          content: 'Content',
          authorId: 'author1',
          publishDate: DateTime(2025),
          viewCount: 0,
        ),
      ];
      when(mockRepository.getNewsList())
          .thenAnswer((_) async => singleNews);

      // Act
      final result = await useCase();

      // Assert
      expect(result.length, equals(1));
    });

    test('should handle default pagination values', () async {
      // Arrange
      when(mockRepository.getNewsList(page: 1, perPage: 10))
          .thenAnswer((_) async => []);

      // Act
      await useCase();

      // Assert
      verify(mockRepository.getNewsList(page: 1, perPage: 10));
    });

    test('should preserve news order from repository', () async {
      // Arrange
      final orderedNews = [
        News(
          id: '1',
          title: 'First',
          slug: 'first',
          category: 'test',
          summary: 'S1',
          content: 'C1',
          authorId: 'a1',
          publishDate: DateTime(2025, 1, 1),
          viewCount: 10,
        ),
        News(
          id: '2',
          title: 'Second',
          slug: 'second',
          category: 'test',
          summary: 'S2',
          content: 'C2',
          authorId: 'a2',
          publishDate: DateTime(2025, 1, 2),
          viewCount: 20,
        ),
        News(
          id: '3',
          title: 'Third',
          slug: 'third',
          category: 'test',
          summary: 'S3',
          content: 'C3',
          authorId: 'a3',
          publishDate: DateTime(2025, 1, 3),
          viewCount: 30,
        ),
      ];
      when(mockRepository.getNewsList())
          .thenAnswer((_) async => orderedNews);

      // Act
      final result = await useCase();

      // Assert
      expect(result[0].id, equals('1'));
      expect(result[1].id, equals('2'));
      expect(result[2].id, equals('3'));
    });
  });
}
