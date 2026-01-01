import 'package:grpc/grpc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/unified_grpc_client.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Auth gRPC data source implementation
/// 使用 Gateway gRPC 客户端替代 Dio HTTP 客户端
class AuthGrpcDataSourceImpl implements AuthRemoteDataSource {
  const AuthGrpcDataSourceImpl(this._grpcClient);

  final UnifiedGrpcClient _grpcClient;

  @override
  Future<({UserModel user, TokenModel tokens})> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final result = await _grpcClient.gateway.register(
        username: username,
        email: email,
        password: password,
      );

      if (result.success) {
        return (
          user: UserModel(
            id: result.userId!,
            username: username,
            email: email,
            displayName: displayName ?? username,
          ),
          tokens: TokenModel(
            accessToken: result.accessToken!,
            refreshToken: result.refreshToken!,
          ),
        );
      }

      throw _mapErrorCodeToException(result.errorCode, result.errorMessage);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<({UserModel user, TokenModel tokens})> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _grpcClient.gateway.login(
        username: email, // Gateway 支持用户名或邮箱登录
        password: password,
      );

      if (result.success) {
        return (
          user: UserModel(
            id: result.userId!,
            username: '', // 需要额外请求获取用户信息
            email: email,
            displayName: '',
          ),
          tokens: TokenModel(
            accessToken: result.accessToken!,
            refreshToken: result.refreshToken!,
          ),
        );
      }

      throw _mapErrorCodeToException(result.errorCode, result.errorMessage);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      await _grpcClient.gateway.logout();
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // TODO: 实现通过 Gateway 获取当前用户信息
    throw const ServerException(message: 'Not implemented');
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final result = await _grpcClient.gateway.refreshToken();

      if (result.success) {
        return result.accessToken!;
      }

      throw _mapErrorCodeToException(result.errorCode, result.errorMessage);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  AppException _handleGrpcError(GrpcError e) {
    switch (e.code) {
      case StatusCode.unauthenticated:
        return UnauthorizedException(message: e.message ?? '认证失败');
      case StatusCode.permissionDenied:
        return ForbiddenException(message: e.message ?? '权限不足');
      case StatusCode.notFound:
        return NotFoundException(message: e.message ?? '资源不存在');
      case StatusCode.invalidArgument:
        return ServerException(message: e.message ?? '参数无效');
      case StatusCode.unavailable:
        return const NetworkException();
      case StatusCode.deadlineExceeded:
        return const TimeoutException();
      default:
        return ServerException(message: e.message ?? '服务器错误');
    }
  }

  AppException _mapErrorCodeToException(String? errorCode, String? errorMessage) {
    final message = errorMessage ?? 'Unknown error';
    switch (errorCode) {
      case 'UNAUTHENTICATED':
        return UnauthorizedException(message: message);
      case 'ALREADY_EXISTS':
        return ServerException(message: message, statusCode: 409);
      case 'INVALID_ARGUMENT':
        return ServerException(message: message, statusCode: 400);
      case 'NOT_FOUND':
        return NotFoundException(message: message);
      default:
        return ServerException(message: message);
    }
  }
}
