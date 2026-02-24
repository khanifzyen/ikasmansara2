import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/news/domain/entities/news.dart';

void main() {
  group('News Entity', () {
    late News testNews;

    setUpAll(() {
      testNews = News(
        id: '1',
        title: 'Test News Title',
        slug: 'test-news-title',
        category: 'announcement',
        thumbnail: 'thumbnail.jpg',
        summary: 'This is a test summary',
        content: 'Full content here',
        authorId: 'author1',
        authorName: 'John Doe',
        authorAvatar: 'avatar.jpg',
        publishDate: DateTime(2025, 2, 18),
        viewCount: 100,
      );
    });

    test('should create News instance correctly', () {
      // Assert
      expect(testNews.id, equals('1'));
      expect(testNews.title, equals('Test News Title'));
      expect(testNews.slug, equals('test-news-title'));
      expect(testNews.category, equals('announcement'));
      expect(testNews.thumbnail, equals('thumbnail.jpg'));
      expect(testNews.summary, equals('This is a test summary'));
      expect(testNews.content, equals('Full content here'));
      expect(testNews.authorId, equals('author1'));
      expect(testNews.authorName, equals('John Doe'));
      expect(testNews.authorAvatar, equals('avatar.jpg'));
      expect(testNews.publishDate, equals(DateTime(2025, 2, 18)));
      expect(testNews.viewCount, equals(100));
    });

    test('should handle nullable thumbnail', () {
      // Arrange
      final newsWithoutThumbnail = News(
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

      // Assert
      expect(newsWithoutThumbnail.thumbnail, isNull);
    });

    test('should handle nullable author fields', () {
      // Arrange
      final newsWithoutAuthorInfo = News(
        id: '3',
        title: 'News Without Author Info',
        slug: 'news-without-author-info',
        category: 'event',
        summary: 'Summary',
        content: 'Content',
        authorId: 'system',
        publishDate: DateTime(2025),
        viewCount: 50,
      );

      // Assert
      expect(newsWithoutAuthorInfo.authorName, isNull);
      expect(newsWithoutAuthorInfo.authorAvatar, isNull);
    });

    test('should implement Equatable', () {
      // Arrange
      final news1 = testNews;
      final news2 = News(
        id: '1',
        title: 'Test News Title',
        slug: 'test-news-title',
        category: 'announcement',
        thumbnail: 'thumbnail.jpg',
        summary: 'This is a test summary',
        content: 'Full content here',
        authorId: 'author1',
        authorName: 'John Doe',
        authorAvatar: 'avatar.jpg',
        publishDate: DateTime(2025, 2, 18),
        viewCount: 100,
      );
      final news3 = News(
        id: '2',
        title: 'Different Title',
        slug: 'different-title',
        category: 'update',
        summary: 'Different summary',
        content: 'Different content',
        authorId: 'author2',
        publishDate: DateTime(2025),
        viewCount: 0,
      );

      // Assert
      expect(news1, equals(news2));
      expect(news1, isNot(equals(news3)));
    });

    test('should compare by all props', () {
      // Arrange
      final baseNews = testNews;
      final differentId = News(
        id: '999',
        title: 'Test News Title',
        slug: 'test-news-title',
        category: 'announcement',
        thumbnail: 'thumbnail.jpg',
        summary: 'This is a test summary',
        content: 'Full content here',
        authorId: 'author1',
        authorName: 'John Doe',
        authorAvatar: 'avatar.jpg',
        publishDate: DateTime(2025, 2, 18),
        viewCount: 100,
      );
      final differentViewCount = News(
        id: '1',
        title: 'Test News Title',
        slug: 'test-news-title',
        category: 'announcement',
        thumbnail: 'thumbnail.jpg',
        summary: 'This is a test summary',
        content: 'Full content here',
        authorId: 'author1',
        authorName: 'John Doe',
        authorAvatar: 'avatar.jpg',
        publishDate: DateTime(2025, 2, 18),
        viewCount: 200,
      );

      // Assert
      expect(baseNews, isNot(equals(differentId)));
      expect(baseNews, isNot(equals(differentViewCount)));
    });
  });

  group('News Entity - Edge Cases', () {
    test('should handle zero view count', () {
      // Arrange
      final zeroViewNews = News(
        id: '1',
        title: 'Unread News',
        slug: 'unread-news',
        category: 'test',
        summary: 'Summary',
        content: 'Content',
        authorId: 'author1',
        publishDate: DateTime(2025),
        viewCount: 0,
      );

      // Assert
      expect(zeroViewNews.viewCount, equals(0));
    });

    test('should handle very long content', () {
      // Arrange
      final longContent = 'A' * 10000;
      final longContentNews = News(
        id: '1',
        title: 'Long Article',
        slug: 'long-article',
        category: 'article',
        summary: 'Summary',
        content: longContent,
        authorId: 'author1',
        publishDate: DateTime(2025),
        viewCount: 0,
      );

      // Assert
      expect(longContentNews.content.length, equals(10000));
    });

    test('should handle special characters in title', () {
      // Arrange
      final specialTitle = '🎉 Big Event! & More (Updated)';
      final specialNews = News(
        id: '1',
        title: specialTitle,
        slug: 'big-event-more-updated',
        category: 'event',
        summary: 'Summary',
        content: 'Content',
        authorId: 'author1',
        publishDate: DateTime(2025),
        viewCount: 0,
      );

      // Assert
      expect(specialNews.title, contains('🎉'));
      expect(specialNews.title, contains('&'));
    });
  });
}
