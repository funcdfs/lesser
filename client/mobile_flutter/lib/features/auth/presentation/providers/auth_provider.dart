import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';

/// Auth state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required AuthRepository repository,
  })  : _repository = repository,
        super(const AuthState());

  final AuthRepository _repository;

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final isAuthenticated = await _repository.isAuthenticated();
    if (isAuthenticated) {
      final result = await _repository.getCurrentUser();
      result.fold(
        (failure) => state = state.copyWith(
          status: AuthStatus.unauthenticated,
        ),
        (user) => state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final loginUseCase = LoginUseCase(_repository);
    final result = await loginUseCase(LoginParams(
      email: email,
      password: password,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  /// Register
  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final registerUseCase = RegisterUseCase(_repository);
    final result = await registerUseCase(RegisterParams(
      username: username,
      email: email,
      password: password,
      displayName: displayName,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final logoutUseCase = LogoutUseCase(_repository);
    await logoutUseCase();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // This will be properly initialized after DI setup
  // For now, we'll throw if repository is not registered
  final repository = getIt<AuthRepository>();
  return AuthNotifier(repository: repository);
});
