import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lesser/features/auth/data/auth_repository.dart';
import 'package:lesser/features/auth/domain/models/auth_state.dart';
import 'package:lesser/features/auth/domain/models/user.dart';
import 'package:lesser/features/auth/presentation/providers/auth_provider.dart';

/// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    SharedPreferences.setMockInitialValues({});

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Auth Provider', () {
    group('initial state', () {
      test('starts with initial state', () {
        // Act
        final state = container.read(authProvider);

        // Assert
        expect(state, isA<AuthStateInitial>());
      });
    });

    group('login', () {
      test('sets authenticated state on successful login', () async {
        // Arrange
        final authResponse = AuthResponse(
          token: 'test_token',
          userId: 1,
          username: 'testuser',
        );

        when(
          () => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => authResponse);

        // Act
        await container.read(authProvider.notifier).login(
              username: 'testuser',
              password: 'password123',
            );

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateAuthenticated>());
        final authenticatedState = state as AuthStateAuthenticated;
        expect(authenticatedState.user.username, equals('testuser'));
      });

      test('sets error state on AuthException', () async {
        // Arrange
        when(
          () => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException(
          'Invalid credentials',
          AuthErrorType.invalidCredentials,
        ));

        // Act
        await container.read(authProvider.notifier).login(
              username: 'testuser',
              password: 'wrongpassword',
            );

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateError>());
      });

      test('sets error state on unexpected exception', () async {
        // Arrange
        when(
          () => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Network error'));

        // Act
        await container.read(authProvider.notifier).login(
              username: 'testuser',
              password: 'password123',
            );

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateError>());
        final errorState = state as AuthStateError;
        expect(errorState.message, equals('An unexpected error occurred'));
      });
    });

    group('register', () {
      test('sets authenticated state on successful registration', () async {
        // Arrange
        final authResponse = AuthResponse(
          token: 'new_token',
          userId: 2,
          username: 'newuser',
        );

        when(
          () => mockAuthRepository.register(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            confirmPassword: any(named: 'confirmPassword'),
          ),
        ).thenAnswer((_) async => authResponse);

        // Act
        await container.read(authProvider.notifier).register(
              username: 'newuser',
              email: 'newuser@example.com',
              password: 'password123',
              confirmPassword: 'password123',
            );

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateAuthenticated>());
        final authenticatedState = state as AuthStateAuthenticated;
        expect(authenticatedState.user.username, equals('newuser'));
        expect(authenticatedState.user.email, equals('newuser@example.com'));
      });

      test('sets error state on registration failure', () async {
        // Arrange
        when(
          () => mockAuthRepository.register(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            confirmPassword: any(named: 'confirmPassword'),
          ),
        ).thenThrow(const AuthException(
          'Email already exists',
          AuthErrorType.validationError,
        ));

        // Act
        await container.read(authProvider.notifier).register(
              username: 'existinguser',
              email: 'existing@example.com',
              password: 'password123',
              confirmPassword: 'password123',
            );

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateError>());
      });
    });

    group('logout', () {
      test('sets unauthenticated state on successful logout', () async {
        // Arrange - first login
        final authResponse = AuthResponse(
          token: 'test_token',
          userId: 1,
          username: 'testuser',
        );

        when(
          () => mockAuthRepository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => authResponse);

        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

        await container.read(authProvider.notifier).login(
              username: 'testuser',
              password: 'password123',
            );

        // Act
        await container.read(authProvider.notifier).logout();

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateUnauthenticated>());
      });

      test('sets unauthenticated state even on logout error', () async {
        // Arrange
        when(() => mockAuthRepository.logout())
            .thenThrow(Exception('Network error'));

        // Act
        await container.read(authProvider.notifier).logout();

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateUnauthenticated>());
      });
    });

    group('checkAuthStatus', () {
      test('sets unauthenticated when no token exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        await container.read(authProvider.notifier).checkAuthStatus();

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateUnauthenticated>());
      });

      test('sets authenticated when token exists and profile loads', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'valid_token'});

        final user = const User(
          id: 1,
          username: 'testuser',
          email: 'test@example.com',
        );

        when(() => mockAuthRepository.getProfile())
            .thenAnswer((_) async => user);

        // Act
        await container.read(authProvider.notifier).checkAuthStatus();

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateAuthenticated>());
      });

      test('sets unauthenticated when profile load fails', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'auth_token': 'invalid_token'});

        when(() => mockAuthRepository.getProfile()).thenThrow(const AuthException(
          'Token expired',
          AuthErrorType.invalidCredentials,
        ));

        // Act
        await container.read(authProvider.notifier).checkAuthStatus();

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AuthStateUnauthenticated>());
      });
    });
  });
}
