import 'package:glados/glados.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';

/// Property-based tests for Post Model Serialization
/// Feature: frontend-code-improvement, Property 1: Model Serialization Round-Trip
/// Validates: Requirements 2.3

void main() {
  group('Post Model - Property-Based Serialization Tests', () {
    // Property 1: Model Serialization Round-Trip
    // For any valid Post object, serializing to JSON and deserializing back
    // SHALL produce an equivalent object.
    Glados3(any.lowercaseLetters, any.positiveIntOrZero, any.bool).test(
      'Property 1: Post serialization round-trip - toJson then fromJson returns equivalent object',
      (content, likes, isLiked) {
        // Create a post with generated values
        final post = Post(
          id: 'post-${content.hashCode}',
          username: 'testuser',
          content: content.isEmpty ? 'default content' : content,
          createdAt: '2024-01-15T10:30:00Z',
          likes: likes,
          location: content.isEmpty ? null : 'Location-$content',
          imageUrls: const [],
          commentsCount: likes ~/ 2,
          repostsCount: likes ~/ 3,
          bookmarksCount: likes ~/ 4,
          sharesCount: likes ~/ 5,
          isLiked: isLiked,
        );

        // Act: Serialize to JSON and deserialize back
        final json = post.toJson();
        final reconstructedPost = Post.fromJson(json);

        // Assert: The reconstructed post should equal the original
        expect(reconstructedPost, equals(post));
        expect(reconstructedPost.id, equals(post.id));
        expect(reconstructedPost.username, equals(post.username));
        expect(reconstructedPost.content, equals(post.content));
        expect(reconstructedPost.likes, equals(post.likes));
        expect(reconstructedPost.location, equals(post.location));
        expect(reconstructedPost.isLiked, equals(post.isLiked));
      },
    );

    // Additional example-based tests for specific edge cases
    test('Post with images should round-trip correctly', () {
      final imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];
      final originalPost = Post(
        id: 'img-post',
        username: 'photographer',
        content: 'Beautiful photo',
        createdAt: '2024-01-17T09:00:00Z',
        likes: 500,
        location: 'Beijing',
        imageUrls: imageUrls,
        commentsCount: 50,
        repostsCount: 20,
        bookmarksCount: 30,
        sharesCount: 10,
        isLiked: true,
      );

      final json = originalPost.toJson();
      final reconstructedPost = Post.fromJson(json);

      expect(reconstructedPost, equals(originalPost));
      expect(reconstructedPost.imageUrls, equals(imageUrls));
      expect(reconstructedPost.isLiked, isTrue);
    });

    test('Post with null location should round-trip correctly', () {
      final originalPost = Post(
        id: 'post-no-location',
        username: 'user1',
        content: 'Content without location',
        createdAt: '2024-01-18T10:00:00Z',
        likes: 5,
        location: null,
        imageUrls: const [],
        commentsCount: 0,
        repostsCount: 0,
        bookmarksCount: 0,
        sharesCount: 0,
        isLiked: false,
      );

      final json = originalPost.toJson();
      final reconstructedPost = Post.fromJson(json);

      expect(reconstructedPost, equals(originalPost));
      expect(reconstructedPost.location, isNull);
    });

    test('toJson should produce valid JSON structure with snake_case keys', () {
      final post = Post(
        id: 'test-post',
        username: 'testuser',
        content: 'Test content',
        createdAt: '2024-01-15T10:30:00Z',
        likes: 42,
        location: 'Beijing',
        imageUrls: const ['https://example.com/img.jpg'],
        commentsCount: 5,
        repostsCount: 2,
        bookmarksCount: 3,
        sharesCount: 1,
        isLiked: true,
      );

      final json = post.toJson();

      expect(json['id'], equals('test-post'));
      expect(json['username'], equals('testuser'));
      expect(json['likes'], equals(42));
      expect(json['location'], equals('Beijing'));
      expect(json['created_at'], equals('2024-01-15T10:30:00Z'));
      expect(json['image_urls'], equals(['https://example.com/img.jpg']));
      expect(json['comments_count'], equals(5));
      expect(json['is_liked'], equals(true));
    });
  });
}
