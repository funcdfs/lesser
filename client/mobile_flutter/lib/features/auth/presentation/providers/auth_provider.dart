import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/unified_grpc_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';

/// 认证状态枚举
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// 认证状态
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

/// 认证状态管理器
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final UnifiedGrpcClient _grpcClient;

  @override
  AuthState build() {
    _repository = getIt<AuthRepository>();
    _grpcClient = getIt<UnifiedGrpcClient>();
    return const AuthState();
  }

  /// 检查认证状态
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final isAuthenticated = await _repository.isAuthenticated();
    if (isAuthenticated) {
      final result = await _repository.getCurrentUser();
      result.fold(
        (failure) => state = state.copyWith(
          status: AuthStatus.unauthenticated,
        ),
        (user) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
          // 登录状态恢复后自动连接 gRPC 双向流
          _grpcClient.chatStream.connect();
        },
      );
    } else {
      // 如果未登录，检查是否有自动登录的环境变量
      const autoEmail = String.fromEnvironment('AUTO_LOGIN_EMAIL');
      const autoPassword = String.fromEnvironment('AUTO_LOGIN_PASSWORD');

      if (autoEmail.isNotEmpty && autoPassword.isNotEmpty) {
        await login(email: autoEmail, password: autoPassword);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    }
  }

  /// 登录
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
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        // 登录成功后自动连接 gRPC 双向流
        _grpcClient.chatStream.connect();
      },
    );
  }

  /// 注册
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
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        // 注册成功后自动连接 gRPC 双向流
        _grpcClient.chatStream.connect();
      },
    );
  }

  /// 登出
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    // 登出时断开 gRPC 双向流连接
    await _grpcClient.chatStream.disconnect();

    final logoutUseCase = LogoutUseCase(_repository);
    await logoutUseCase();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// 认证 Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
