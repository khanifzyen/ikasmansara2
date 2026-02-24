import 'package:flutter_test/flutter_test.dart';
import 'package:ika_smansara/features/forum/domain/entities/forum_post.dart';

void main() {
  group('ForumPost Entity', () {
    test('should create ForumPost instance correctly', () {
      // Arrange
      final post = ForumPost(
        id: '1',
        content: 'Test post content',
        images: ['img1.jpg', 'img2.jpg'],
        category: 'general',
        visibility: 'public',
        likeCount: 10,
        commentCount: 5,
        isPinned: false,
        status: 'active',
        createdAt: DateTime(2025),
        authorId: 'author1',
        authorName: 'John Doe',
        authorAvatar: 'avatar.jpg',
        isLiked: false,
      );

      // Assert
      expect(post.id, equals('1'));
      expect(post.content, equals('Test post content'));
      expect(post.images.length, equals(2));
      expect(post.likeCount, equals(10));
      expect(post.isLiked, isFalse);
    });

    test('should implement Equatable', () {
      // Arrange
      final post1 = ForumPost(
        id: '1',
        content: 'Content',
        images: [],
        category: 'test',
        visibility: 'public',
        likeCount: 0,
        commentCount: 0,
        isPinned: false,
        status: 'active',
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'Author',
      );
      final post2 = ForumPost(
        id: '1',
        content: 'Content',
        images: [],
        category: 'test',
        visibility: 'public',
        likeCount: 0,
        commentCount: 0,
        isPinned: false,
        status: 'active',
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'Author',
      );
      final post3 = ForumPost(
        id: '2',
        content: 'Different',
        images: [],
        category: 'test',
        visibility: 'public',
        likeCount: 0,
        commentCount: 0,
        isPinned: false,
        status: 'active',
        createdAt: DateTime(2025),
        authorId: 'a2',
        authorName: 'Author2',
      );

      // Assert
      expect(post1, equals(post2));
      expect(post1, isNot(equals(post3)));
    });

    test('copyWith should update values', () {
      // Arrange
      final original = ForumPost(
        id: '1',
        content: 'Original',
        images: [],
        category: 'test',
        visibility: 'public',
        likeCount: 0,
        commentCount: 0,
        isPinned: false,
        status: 'active',
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'Author',
      );

      // Act
      final updated = original.copyWith(
        content: 'Updated',
        likeCount: 10,
        isLiked: true,
      );

      // Assert
      expect(updated.content, equals('Updated'));
      expect(updated.likeCount, equals(10));
      expect(updated.isLiked, isTrue);
      expect(original.content, equals('Original'));
    });
  });

  group('ForumComment Entity', () {
    test('should create ForumComment instance correctly', () {
      // Arrange
      final comment = ForumComment(
        id: 'c1',
        content: 'Test comment',
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'Commenter',
        authorAvatar: 'commenter.jpg',
      );

      // Assert
      expect(comment.id, equals('c1'));
      expect(comment.content, equals('Test comment'));
      expect(comment.authorName, equals('Commenter'));
    });

    test('should handle nullable avatar', () {
      // Arrange
      final comment = ForumComment(
        id: 'c1',
        content: 'Test',
        createdAt: DateTime(2025),
        authorId: 'a1',
        authorName: 'NoAvatar',
      );

      // Assert
      expect(comment.authorAvatar, isNull);
    });
  });
}
