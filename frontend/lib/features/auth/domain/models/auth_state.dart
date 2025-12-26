import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lesser/features/auth/domain/models/user.dart';

part 'auth_state.freezed.dart';

/// Authentication state model using Freezed sealed classes.
/// Represents all possible states of the authentication flow.
@freezed
sealed class AuthState with _$AuthState {
  /// Initial state when the app starts, before checking auth status
  const factory AuthState.initial() = AuthStateInitial;

  /// Loading state during authentication operations
  const factory AuthState.loading() = AuthStateLoading;

  /// Authenticated state with user data
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;

  /// Unauthenticated state (no valid token)
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Error state with error message
  const factory AuthState.error(String message) = AuthStateError;
}
