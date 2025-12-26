import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/core/network/api_provider.dart';
import 'package:lesser/core/network/token_manager.dart';
import 'package:lesser/features/auth/data/auth_repository.dart';
import 'package:lesser/features/auth/domain/models/auth_state.dart';
import 'package:lesser/features/auth/domain/models/user.dart';

part 'auth_provider.g.dart';

/// Provider for AuthRepository
@riverpod
AuthRepository authRepository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
}

/// Provider for authentication state management
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  /// Check authentication status on app startup
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    try {
      final token = await TokenManager.getToken();

      if (token == null || token.isEmpty) {
        state = const AuthState.unauthenticated();
        return;
      }

      // Token exists, try to get user profile
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getProfile();
      state = AuthState.authenticated(user);
    } on AuthException {
      // Token might be invalid, clear it
      await TokenManager.deleteToken();
      state = const AuthState.unauthenticated();
    } catch (_) {
      // On any error, consider unauthenticated
      await TokenManager.deleteToken();
      state = const AuthState.unauthenticated();
    }
  }

  /// Login with username and password
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.login(
        username: username,
        password: password,
      );

      // Save token
      await TokenManager.saveToken(response.token);

      // Create user from response
      final user = User(
        id: response.userId,
        username: response.username,
        email: '', // Email not returned from login
      );

      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = const AuthState.error('An unexpected error occurred');
    }
  }

  /// Register a new user
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.register(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      // Save token
      await TokenManager.saveToken(response.token);

      // Create user from response
      final user = User(
        id: response.userId,
        username: response.username,
        email: email,
      );

      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      state = AuthState.error(e.message);
    } catch (e) {
      state = const AuthState.error('An unexpected error occurred');
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    state = const AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = const AuthState.unauthenticated();
    } catch (e) {
      // Even on error, clear local state and token
      await TokenManager.deleteToken();
      state = const AuthState.unauthenticated();
    }
  }

  /// Handle 401 unauthorized response
  Future<void> handleUnauthorized() async {
    await TokenManager.deleteToken();
    state = const AuthState.unauthenticated();
  }
}
