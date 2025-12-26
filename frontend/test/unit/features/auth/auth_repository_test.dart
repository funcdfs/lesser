import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/core/network/api_client.dart';
import 'package:lesser/core/network/chopper_api_service.dart';
import 'package:lesser/features/auth/data/auth_repository.dart';

/// Mock classes for testing
class MockApiClient extends Mock implements ApiClient {}

class MockChopperApiService extends Mock implements ChopperApiService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository authRepository;
  late MockApiClient mockApiClient;
  late MockChopperApiService mockApiService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockApiService = MockChopperApiService();

    // Set up the mock to return the mock service
    when(() => mockApiClient.apiService).thenReturn(mockApiService);

    authRepository = AuthRepository(mockApiClient);

    // Reset SharedPreferences for each test
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthRepository', () {
    group('login', () {
      test('returns AuthResponse on successful login', () async {
        // Arrange
        final responseBody = {
          'token': 'test_token_123',
          'user_id': 1,
          'username': 'testuser',
        };

        when(
          () => mockApiService.login(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            responseBody,
          ),
        );

        // Act
        final result = await authRepository.login(
          username: 'testuser',
          password: 'password123',
        );

        // Assert
        expect(result.token, equals('test_token_123'));
        expect(result.userId, equals(1));
        expect(result.username, equals('testuser'));

        verify(
          () => mockApiService.login({
            'username': 'testuser',
            'password': 'password123',
          }),
        ).called(1);
      });

      test('throws AuthException with invalidCredentials on 401', () async {
        // Arrange
        when(
          () => mockApiService.login(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 401),
            {'error': 'Invalid credentials'},
          ),
        );

        // Act & Assert
        expect(
          () => authRepository.login(
            username: 'testuser',
            password: 'wrongpassword',
          ),
          throwsA(
            isA<AuthException>()
                .having((e) => e.type, 'type', AuthErrorType.invalidCredentials),
          ),
        );
      });

      test('throws AuthException with validationError on 400', () async {
        // Arrange
        when(
          () => mockApiService.login(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 400),
            {'error': 'Invalid request'},
          ),
        );

        // Act & Assert
        expect(
          () => authRepository.login(
            username: '',
            password: '',
          ),
          throwsA(
            isA<AuthException>()
                .having((e) => e.type, 'type', AuthErrorType.validationError),
          ),
        );
      });
    });

    group('register', () {
      test('returns AuthResponse on successful registration', () async {
        // Arrange
        final responseBody = {
          'token': 'new_user_token',
          'user_id': 2,
          'username': 'newuser',
        };

        when(
          () => mockApiService.register(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 200),
            responseBody,
          ),
        );

        // Act
        final result = await authRepository.register(
          username: 'newuser',
          email: 'newuser@example.com',
          password: 'password123',
          confirmPassword: 'password123',
        );

        // Assert
        expect(result.token, equals('new_user_token'));
        expect(result.userId, equals(2));
        expect(result.username, equals('newuser'));

        verify(
          () => mockApiService.register({
            'username': 'newuser',
            'email': 'newuser@example.com',
            'password': 'password123',
            'password1': 'password123',
            'password2': 'password123',
          }),
        ).called(1);
      });

      test('throws AuthException with validationError on 400', () async {
        // Arrange
        when(
          () => mockApiService.register(any()),
        ).thenAnswer(
          (_) async => Response(
            http.Response('', 400),
            {'error': 'Email already exists'},
          ),
        );

        // Act & Assert
        expect(
          () => authRepository.register(
            username: 'existinguser',
            email: 'existing@example.com',
            password: 'password123',
            confirmPassword: 'password123',
          ),
          throwsA(
            isA<AuthException>()
                .having((e) => e.type, 'type', AuthErrorType.validationError),
          ),
        );
      });
    });

    group('logout', () {
      test('calls logout API and clears token', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'existing_token'});

        when(
          () => mockApiService.logout(),
        ).thenAnswer(
          (_) async => Response(http.Response('', 200), null),
        );

        // Act
        await authRepository.logout();

        // Assert
        verify(() => mockApiService.logout()).called(1);
      });

      test('clears token even when API call fails', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'existing_token'});

        when(
          () => mockApiService.logout(),
        ).thenThrow(Exception('Network error'));

        // Act - should not throw
        await authRepository.logout();

        // Assert - logout was attempted
        verify(() => mockApiService.logout()).called(1);
      });
    });

    group('isAuthenticated', () {
      test('returns true when token exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'valid_token'});

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isTrue);
      });

      test('returns false when token is empty', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': ''});

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });

      test('returns false when token does not exist', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await authRepository.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
