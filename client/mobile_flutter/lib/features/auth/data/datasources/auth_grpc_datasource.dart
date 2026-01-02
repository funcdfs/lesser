import 'package:grpc/grpc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/unified_grpc_client.dart';
import '../../../../generated/protos/auth/auth.pb.dart' as auth_pb;
import '../models/token_model.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Auth gRPC data source implementation
/// 使用 AuthGrpcClient 替代 Gateway 客户端
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
      final result = await _grpcClient.auth.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result.success && result.user != null) {
        return (
          user: _protoUserToModel(result.user!),
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
      final result = await _grpcClient.auth.login(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        return (
          user: _protoUserToModel(result.user!),
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
      await _grpcClient.auth.logout();
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // 当前用户信息在登录时已返回，无需单独请求
    throw const ServerException(message: '请使用登录返回的用户信息');
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final result = await _grpcClient.auth.refreshToken();

      if (result.success) {
        return result.accessToken!;
      }

      throw _mapErrorCodeToException(result.errorCode, result.errorMessage);
    } on GrpcError catch (e) {
      throw _handleGrpcError(e);
    }
  }

  UserModel _protoUserToModel(auth_pb.User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      displayName: user.displayName.isNotEmpty ? user.displayName : user.username,
      avatarUrl: user.avatarUrl.isNotEmpty ? user.avatarUrl : null,
      bio: user.bio.isNotEmpty ? user.bio : null,
    );
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
