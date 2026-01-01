import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grpc/grpc.dart';
import '../grpc/grpc_client.dart';
import '../grpc/chat_grpc_client.dart';
import '../utils/app_logger.dart';

/// 统一 gRPC 客户端
/// 整合 Gateway 和 Chat gRPC 客户端，提供统一的认证拦截器
class UnifiedGrpcClient {
  UnifiedGrpcClient({
    required FlutterSecureStorage secureStorage,
    String? gatewayHost,
    int? gatewayPort,
    String? chatHost,
    int? chatPort,
  })  : _secureStorage = secureStorage,
        _gatewayHost = gatewayHost ?? 'localhost',
        _gatewayPort = gatewayPort ?? 50053,
        _chatHost = chatHost ?? 'localhost',
        _chatPort = chatPort ?? 50052;

  final FlutterSecureStorage _secureStorage;
  final String _gatewayHost;
  final int _gatewayPort;
  final String _chatHost;
  final int _chatPort;

  GrpcClientManager? _gatewayManager;
  GrpcClientManager? _chatManager;
  ChatGrpcClient? _chatClient;
  GatewayGrpcClient? _gatewayClient;

  /// 获取 Gateway gRPC 管理器
  GrpcClientManager get gatewayManager {
    _gatewayManager ??= GrpcClientManager(
      secureStorage: _secureStorage,
      host: _gatewayHost,
      port: _gatewayPort,
    );
    return _gatewayManager!;
  }

  /// 获取 Chat gRPC 管理器
  GrpcClientManager get chatManager {
    _chatManager ??= GrpcClientManager(
      secureStorage: _secureStorage,
      host: _chatHost,
      port: _chatPort,
    );
    return _chatManager!;
  }

  /// 获取 Chat gRPC 客户端
  ChatGrpcClient get chat {
    _chatClient ??= ChatGrpcClient(chatManager);
    return _chatClient!;
  }

  /// 获取 Gateway gRPC 客户端
  GatewayGrpcClient get gateway {
    _gatewayClient ??= GatewayGrpcClient(gatewayManager, _secureStorage);
    return _gatewayClient!;
  }

  /// 关闭所有连接
  Future<void> shutdown() async {
    await _gatewayManager?.shutdown();
    await _chatManager?.shutdown();
    _gatewayManager = null;
    _chatManager = null;
    _chatClient = null;
    _gatewayClient = null;
  }
}

/// Gateway gRPC 客户端
/// 封装 Gateway 相关的 gRPC 调用（包括同步 Auth）
class GatewayGrpcClient {
  GatewayGrpcClient(this._manager, this._secureStorage);

  final GrpcClientManager _manager;
  final FlutterSecureStorage _secureStorage;

  /// 用户登录（同步）
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      // 直接调用 Gateway 的 Login RPC
      // 注意：需要生成 gateway.proto 的 Dart 代码
      // 这里使用简化的实现
      final channel = _manager.channel;
      final stub = GatewayServiceClient(channel);
      
      final request = LoginRequest()
        ..username = username
        ..password = password;
      
      final response = await stub.login(request);
      
      if (response.success) {
        // 保存 token
        await _secureStorage.write(key: 'access_token', value: response.accessToken);
        await _secureStorage.write(key: 'refresh_token', value: response.refreshToken);
        await _secureStorage.write(key: 'user_id', value: response.userId);
        
        return AuthResult(
          success: true,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          userId: response.userId,
        );
      } else {
        return AuthResult(
          success: false,
          errorCode: response.errorCode,
          errorMessage: response.errorMessage,
        );
      }
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Login');
      return AuthResult(
        success: false,
        errorCode: e.code.toString(),
        errorMessage: GrpcErrorHandler.getErrorMessage(e),
      );
    }
  }

  /// 用户注册（同步）
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final channel = _manager.channel;
      final stub = GatewayServiceClient(channel);
      
      final request = RegisterRequest()
        ..username = username
        ..email = email
        ..password = password;
      
      final response = await stub.register(request);
      
      if (response.success) {
        // 保存 token
        await _secureStorage.write(key: 'access_token', value: response.accessToken);
        await _secureStorage.write(key: 'refresh_token', value: response.refreshToken);
        await _secureStorage.write(key: 'user_id', value: response.userId);
        
        return AuthResult(
          success: true,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          userId: response.userId,
        );
      } else {
        return AuthResult(
          success: false,
          errorCode: response.errorCode,
          errorMessage: response.errorMessage,
        );
      }
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Register');
      return AuthResult(
        success: false,
        errorCode: e.code.toString(),
        errorMessage: GrpcErrorHandler.getErrorMessage(e),
      );
    }
  }

  /// 刷新 Token
  Future<AuthResult> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        return AuthResult(
          success: false,
          errorCode: 'NO_REFRESH_TOKEN',
          errorMessage: '没有可用的刷新令牌',
        );
      }

      final channel = _manager.channel;
      final stub = GatewayServiceClient(channel);
      
      final request = RefreshTokenRequest()..refreshToken = refreshToken;
      final response = await stub.refreshToken(request);
      
      if (response.success) {
        // 更新 token
        await _secureStorage.write(key: 'access_token', value: response.accessToken);
        await _secureStorage.write(key: 'refresh_token', value: response.refreshToken);
        
        return AuthResult(
          success: true,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          userId: response.userId,
        );
      } else {
        return AuthResult(
          success: false,
          errorCode: response.errorCode,
          errorMessage: response.errorMessage,
        );
      }
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'RefreshToken');
      return AuthResult(
        success: false,
        errorCode: e.code.toString(),
        errorMessage: GrpcErrorHandler.getErrorMessage(e),
      );
    }
  }

  /// 登出
  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_id');
  }
}

/// 认证结果
class AuthResult {
  AuthResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.errorCode,
    this.errorMessage,
  });

  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? errorCode;
  final String? errorMessage;
}

// 注意：以下类需要从生成的 gateway.proto Dart 代码导入
// 这里提供占位定义，实际使用时需要替换为生成的代码

/// Gateway Service Client (占位，需要从生成代码导入)
class GatewayServiceClient {
  GatewayServiceClient(this._channel);
  final ClientChannel _channel;

  Future<AuthResponse> login(LoginRequest request) async {
    // TODO: 实现实际的 gRPC 调用
    throw UnimplementedError('需要从生成的 proto 代码导入');
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    throw UnimplementedError('需要从生成的 proto 代码导入');
  }

  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    throw UnimplementedError('需要从生成的 proto 代码导入');
  }
}

/// 登录请求 (占位)
class LoginRequest {
  String username = '';
  String password = '';
}

/// 注册请求 (占位)
class RegisterRequest {
  String username = '';
  String email = '';
  String password = '';
}

/// 刷新 Token 请求 (占位)
class RefreshTokenRequest {
  String refreshToken = '';
}

/// 认证响应 (占位)
class AuthResponse {
  bool success = false;
  String accessToken = '';
  String refreshToken = '';
  String userId = '';
  String errorCode = '';
  String errorMessage = '';
}
