import 'package:grpc/grpc.dart';
import '../../generated/protos/auth/auth.pbgrpc.dart';
import 'grpc_client.dart';

/// Auth gRPC 客户端
/// 封装认证相关的 gRPC 调用
class AuthGrpcClient {
  AuthGrpcClient(this._manager) {
    _stub = AuthServiceClient(_manager.channel);
  }

  final GrpcClientManager _manager;
  late final AuthServiceClient _stub;

  /// 用户注册
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final request = RegisterRequest()
        ..username = username
        ..email = email
        ..password = password;
      if (displayName != null) {
        request.displayName = displayName;
      }
      return await _stub.register(request);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Register');
      rethrow;
    }
  }

  /// 用户登录
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest()
        ..email = email
        ..password = password;
      return await _stub.login(request);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Login');
      rethrow;
    }
  }

  /// 登出
  Future<void> logout(String accessToken) async {
    try {
      final request = LogoutRequest()..accessToken = accessToken;
      await _stub.logout(request);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Logout');
      rethrow;
    }
  }

  /// 刷新 Token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final request = RefreshRequest()..refreshToken = refreshToken;
      return await _stub.refreshToken(request);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'RefreshToken');
      rethrow;
    }
  }

  /// 验证 Token
  Future<ValidateResponse> validateToken(String accessToken) async {
    try {
      final request = ValidateRequest()..accessToken = accessToken;
      return await _stub.validateToken(request);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'ValidateToken');
      rethrow;
    }
  }

  /// 获取用户信息
  Future<User> getUser(String userId) async {
    try {
      final options = await _manager.getAuthCallOptions();
      final request = GetUserRequest()..userId = userId;
      return await _stub.getUser(request, options: options);
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'GetUser');
      rethrow;
    }
  }
}
