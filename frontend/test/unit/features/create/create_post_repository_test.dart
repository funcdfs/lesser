import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/chopper_api_service.dart';
import 'package:lesser/features/create/data/create_post_repository.dart';

/// Mock classes for testing
class MockApiClient extends Mock implements ApiClient {}

class MockChopperApiService extends Mock implements ChopperApiService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CreatePostRepository createPostRepository;
  late MockApiClient mockApiClient;
  late MockChopperApiService mockApiService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockApiService = MockChopperApiService();

    when(() => mockApiClient.apiService).thenReturn(mockApiService);

    createPostRepository = CreatePostRepository(mockApiClient);
  });

  group('CreatePostRepository', () {
    group('createPost', () {
      test('returns Post on successful creation with content only', () async {
        // Arrange
        final responseBody = {
          'id': '123',
          'username': 'testuser',
          'content': 'Test post content',
          'created_at': '2024-01-01T12:00:00Z',
          'likes': 0,
          'image_urls': <String>[],
          'comments_count': 0,
          'reposts_count': 0,
          'bookmarks_count': 0,
          'shares_count': 0,
          'is_liked': false,
        };

        when(
          () => mockApiService.createPost(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            responseBody,
          ),
        );

        // Act
        final result = await createPostRepository.createPost(
          content: 'Test post content',
        );

        // Assert
        expect(result.id, equals('123'));
        expect(result.content, equals('Test post content'));
        expect(result.username, equals('testuser'));

        verify(
          () => mockApiService.createPost({'content': 'Test post content'}),
        ).called(1);
      });

      test('returns Post on successful creation with content and location',
          () async {
        // Arrange
        final responseBody = {
          'id': '456',
          'username': 'testuser',
          'content': 'Post with location',
          'created_at': '2024-01-01T12:00:00Z',
          'likes': 0,
          'location': 'New York',
          'image_urls': <String>[],
          'comments_count': 0,
          'reposts_count': 0,
          'bookmarks_count': 0,
          'shares_count': 0,
          'is_liked': false,
        };

        when(
          () => mockApiService.createPost(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            responseBody,
          ),
        );

        // Act
        final result = await createPostRepository.createPost(
          content: 'Post with location',
          location: 'New York',
        );

        // Assert
        expect(result.id, equals('456'));
        expect(result.content, equals('Post with location'));
        expect(result.location, equals('New York'));

        verify(
          () => mockApiService.createPost({
            'content': 'Post with location',
            'location': 'New York',
          }),
        ).called(1);
      });

      test('does not include location when empty string', () async {
        // Arrange
        final responseBody = {
          'id': '789',
          'username': 'testuser',
          'content': 'Post without location',
          'created_at': '2024-01-01T12:00:00Z',
          'likes': 0,
          'image_urls': <String>[],
          'comments_count': 0,
          'reposts_count': 0,
          'bookmarks_count': 0,
          'shares_count': 0,
          'is_liked': false,
        };

        when(
          () => mockApiService.createPost(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            responseBody,
          ),
        );

        // Act
        await createPostRepository.createPost(
          content: 'Post without location',
          location: '',
        );

        // Assert - location should not be included
        verify(
          () => mockApiService.createPost({'content': 'Post without location'}),
        ).called(1);
      });

      test('throws exception on API error', () async {
        // Arrange
        when(
          () => mockApiService.createPost(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 400),
            {'error': 'Bad request'},
          ),
        );

        // Act & Assert
        expect(
          () => createPostRepository.createPost(content: 'Test'),
          throwsException,
        );
      });
    });
  });
}
