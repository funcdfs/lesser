import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/chopper_api_service.dart';
import 'package:lesser/features/feeds/data/comments_repository.dart';

/// Mock classes for testing
class MockApiClient extends Mock implements ApiClient {}

class MockChopperApiService extends Mock implements ChopperApiService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CommentsRepository commentsRepository;
  late MockApiClient mockApiClient;
  late MockChopperApiService mockApiService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockApiService = MockChopperApiService();

    when(() => mockApiClient.apiService).thenReturn(mockApiService);

    commentsRepository = CommentsRepository(mockApiClient);
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('CommentsRepository', () {
    group('getComments', () {
      test('returns list of comments on successful response', () async {
        // Arrange
        final responseBody = [
          {
            'id': '1',
            'post_id': 'post1',
            'user_id': 'user1',
            'username': 'testuser1',
            'content': 'Great post!',
            'created_at': '2024-01-15T10:30:00Z',
            'likes_count': 5,
            'avatar_url': 'https://example.com/avatar1.jpg',
            'is_liked': false,
            'reply_count': 2,
            'is_from_author': false,
            'is_verified': true,
          },
          {
            'id': '2',
            'post_id': 'post1',
            'user_id': 'user2',
            'username': 'testuser2',
            'content': 'Thanks for sharing!',
            'created_at': '2024-01-15T11:00:00Z',
            'likes_count': 3,
            'avatar_url': '',
            'is_liked': true,
            'reply_count': 0,
            'is_from_author': true,
            'is_verified': false,
          },
        ];

        when(
          () => mockApiService.getComments(any(), any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            responseBody,
          ),
        );

        // Act
        final result = await commentsRepository.getComments(
          postId: 'post1',
          page: 1,
          limit: 20,
        );

        // Assert
        expect(result.length, equals(2));
        expect(result[0].id, equals('1'));
        expect(result[0].username, equals('testuser1'));
        expect(result[0].content, equals('Great post!'));
        expect(result[0].likesCount, equals(5));
        expect(result[0].isVerified, isTrue);
        expect(result[1].id, equals('2'));
        expect(result[1].isFromAuthor, isTrue);

        verify(() => mockApiService.getComments('post1', 1, 20)).called(1);
      });

      test('handles paginated response format', () async {
        // Arrange
        final responseBody = {
          'results': [
            {
              'id': '1',
              'post_id': 'post1',
              'user_id': 'user1',
              'username': 'testuser1',
              'content': 'Comment 1',
              'created_at': '2024-01-15T10:30:00Z',
            },
          ],
          'count': 1,
          'next': null,
          'previous': null,
        };

        when(
          () => mockApiService.getComments(any(), any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            responseBody,
          ),
        );

        // Act
        final result = await commentsRepository.getComments(
          postId: 'post1',
          page: 1,
          limit: 20,
        );

        // Assert
        expect(result.length, equals(1));
        expect(result[0].content, equals('Comment 1'));
      });

      test('returns empty list when response is empty', () async {
        // Arrange
        when(
          () => mockApiService.getComments(any(), any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            [],
          ),
        );

        // Act
        final result = await commentsRepository.getComments(
          postId: 'post1',
          page: 1,
          limit: 20,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('createComment', () {
      test('returns created comment on success', () async {
        // Arrange
        final responseBody = {
          'id': '3',
          'post_id': 'post1',
          'user_id': 'currentUser',
          'username': 'currentUser',
          'content': 'New comment',
          'created_at': '2024-01-15T12:00:00Z',
          'likes_count': 0,
        };

        when(
          () => mockApiService.createComment(any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 201),
            responseBody,
          ),
        );

        // Act
        final result = await commentsRepository.createComment(
          postId: 'post1',
          content: 'New comment',
        );

        // Assert
        expect(result.id, equals('3'));
        expect(result.content, equals('New comment'));
        expect(result.postId, equals('post1'));

        verify(
          () => mockApiService.createComment('post1', {'content': 'New comment'}),
        ).called(1);
      });

      test('throws exception on API error', () async {
        // Arrange
        when(
          () => mockApiService.createComment(any(), any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 400),
            {'error': 'Invalid content'},
          ),
        );

        // Act & Assert
        expect(
          () => commentsRepository.createComment(
            postId: 'post1',
            content: '',
          ),
          throwsException,
        );
      });
    });

    group('deleteComment', () {
      test('completes successfully on 204 response', () async {
        // Arrange
        when(
          () => mockApiService.deleteComment(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 204),
            null,
          ),
        );

        // Act & Assert - should not throw
        await commentsRepository.deleteComment('comment1');

        verify(() => mockApiService.deleteComment('comment1')).called(1);
      });

      test('throws exception on API error', () async {
        // Arrange
        when(
          () => mockApiService.deleteComment(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 403),
            {'error': 'Not authorized'},
          ),
        );

        // Act & Assert
        expect(
          () => commentsRepository.deleteComment('comment1'),
          throwsException,
        );
      });
    });
  });
}
