import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/chopper_api_service.dart';
import 'package:lesser/features/feeds/data/feeds_repository.dart';

/// Mock classes for testing
class MockApiClient extends Mock implements ApiClient {}

class MockChopperApiService extends Mock implements ChopperApiService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FeedsRepository feedsRepository;
  late MockApiClient mockApiClient;
  late MockChopperApiService mockApiService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockApiService = MockChopperApiService();

    when(() => mockApiClient.apiService).thenReturn(mockApiService);

    feedsRepository = FeedsRepository(mockApiClient);
  });

  group('FeedsRepository', () {
    group('getFeeds', () {
      test('returns list of posts on successful response', () async {
        // Arrange
        final responseBody = [
          {
            'id': '1',
            'username': 'user1',
            'content': 'Test post 1',
            'created_at': '2024-01-15T10:30:00Z',
            'likes': 10,
            'location': 'Beijing',
            'image_urls': ['https://example.com/image1.jpg'],
            'comments_count': 5,
            'reposts_count': 2,
            'bookmarks_count': 3,
            'shares_count': 1,
            'is_liked': false,
          },
          {
            'id': '2',
            'username': 'user2',
            'content': 'Test post 2',
            'created_at': '2024-01-15T11:00:00Z',
            'likes': 20,
            'location': null,
            'image_urls': [],
            'comments_count': 10,
            'reposts_count': 5,
            'bookmarks_count': 8,
            'shares_count': 3,
            'is_liked': true,
          },
        ];

        when(
          () => mockApiService.getFeeds(any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            responseBody,
          ),
        );

        // Act
        final result = await feedsRepository.getFeeds(page: 1, limit: 20);

        // Assert
        expect(result.length, equals(2));
        expect(result[0].id, equals('1'));
        expect(result[0].username, equals('user1'));
        expect(result[0].content, equals('Test post 1'));
        expect(result[0].likes, equals(10));
        expect(result[1].id, equals('2'));
        expect(result[1].isLiked, isTrue);

        verify(() => mockApiService.getFeeds(1, 20)).called(1);
      });

      test('returns empty list when response is empty', () async {
        // Arrange
        when(
          () => mockApiService.getFeeds(any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            [],
          ),
        );

        // Act
        final result = await feedsRepository.getFeeds(page: 1, limit: 20);

        // Assert
        expect(result, isEmpty);
      });

      test('throws exception on API error', () async {
        // Arrange
        when(
          () => mockApiService.getFeeds(any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 500),
            {'error': 'Internal server error'},
          ),
        );

        // Act & Assert
        expect(
          () => feedsRepository.getFeeds(page: 1, limit: 20),
          throwsException,
        );
      });

      test('passes correct pagination parameters', () async {
        // Arrange
        when(
          () => mockApiService.getFeeds(any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            [],
          ),
        );

        // Act
        await feedsRepository.getFeeds(page: 3, limit: 10);

        // Assert
        verify(() => mockApiService.getFeeds(3, 10)).called(1);
      });
    });
  });
}
