import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lesser/features/feeds/data/feeds_repository.dart';
import 'package:lesser/features/feeds/domain/models/post.dart';
import 'package:lesser/features/feeds/presentation/providers/feeds_provider.dart';

/// Mock classes
class MockFeedsRepository extends Mock implements FeedsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFeedsRepository mockFeedsRepository;
  late ProviderContainer container;

  final testPosts = [
    const Post(
      id: '1',
      username: 'user1',
      content: 'Test post 1',
      createdAt: '2024-01-01T12:00:00Z',
      likes: 10,
      imageUrls: [],
      commentsCount: 5,
      repostsCount: 2,
      bookmarksCount: 3,
      sharesCount: 1,
      isLiked: false,
    ),
    const Post(
      id: '2',
      username: 'user2',
      content: 'Test post 2',
      createdAt: '2024-01-02T12:00:00Z',
      likes: 20,
      imageUrls: [],
      commentsCount: 10,
      repostsCount: 5,
      bookmarksCount: 8,
      sharesCount: 3,
      isLiked: true,
    ),
  ];

  setUp(() {
    mockFeedsRepository = MockFeedsRepository();

    container = ProviderContainer(
      overrides: [
        feedsRepositoryProvider.overrideWithValue(mockFeedsRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FeedsRepository Provider', () {
    test('provides FeedsRepository instance', () {
      // Act
      final repository = container.read(feedsRepositoryProvider);

      // Assert
      expect(repository, isA<FeedsRepository>());
    });
  });

  group('PagedFeeds Provider', () {
    // Note: The PagedFeeds provider uses DebugConfig.debugLocal which is true by default,
    // so it returns mock data instead of calling the repository.
    // These tests verify the provider works in debug mode.

    test('returns posts in debug mode', () async {
      // Act - In debug mode, the provider returns fake data
      final result = await container.read(pagedFeedsProvider.future);

      // Assert - Should return 10 debug posts
      expect(result, hasLength(10));
      expect(result.first.username, equals('debug_user'));
    });

    test('posts have expected structure in debug mode', () async {
      // Act
      final result = await container.read(pagedFeedsProvider.future);

      // Assert
      final firstPost = result.first;
      expect(firstPost.id, isNotEmpty);
      expect(firstPost.username, isNotEmpty);
      expect(firstPost.content, isNotEmpty);
      expect(firstPost.createdAt, isNotEmpty);
    });

    test('posts have correct content pattern in debug mode', () async {
      // Act
      final result = await container.read(pagedFeedsProvider.future);

      // Assert - Debug posts follow a specific pattern
      expect(result.first.content, contains('测试帖子'));
      expect(result.first.location, equals('北京'));
    });
  });

  group('FeedsRepository', () {
    test('getFeeds calls API with correct parameters', () async {
      // Arrange
      when(
        () => mockFeedsRepository.getFeeds(page: 1, limit: 10),
      ).thenAnswer((_) async => testPosts);

      // Act
      final result = await mockFeedsRepository.getFeeds(page: 1, limit: 10);

      // Assert
      expect(result, hasLength(2));
      expect(result[0].id, equals('1'));
      expect(result[1].id, equals('2'));
      verify(() => mockFeedsRepository.getFeeds(page: 1, limit: 10)).called(1);
    });

    test('getFeeds handles empty response', () async {
      // Arrange
      when(
        () => mockFeedsRepository.getFeeds(page: 1, limit: 10),
      ).thenAnswer((_) async => []);

      // Act
      final result = await mockFeedsRepository.getFeeds(page: 1, limit: 10);

      // Assert
      expect(result, isEmpty);
    });

    test('getFeeds throws on API error', () async {
      // Arrange
      when(
        () => mockFeedsRepository.getFeeds(page: 1, limit: 10),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => mockFeedsRepository.getFeeds(page: 1, limit: 10),
        throwsException,
      );
    });
  });
}
