import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grpc/grpc.dart';
import '../../generated/protos/auth/auth.pbgrpc.dart' as auth_pb;
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// Token 状态
enum TokenStatus {
  valid,
  expiringSoon,
  expired,
  missing,
}

/// Token 管理器
/// 负责 Token 过期检测、自动刷新和认证失败处理
class TokenManager {
  TokenManager({
    required FlutterSecureStorage secureStorage,
    required this.authServiceClient,
    this.onAuthenticationRequired,
    this.tokenRefreshThreshold = const Duration(minutes: 5),
  }) : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;
  final auth_pb.AuthServiceClient authServiceClient;
  final VoidCallback? onAuthenticationRequired;

  /// Token 即将过期的阈值（提前刷新）
  final Duration tokenRefreshThreshold;

  /// 是否正在刷新 Token
  bool _isRefreshing = false;

  /// 刷新 Token 的 Completer（用于合并并发刷新请求）
  Completer<bool>? _refreshCompleter;

  /// Token 刷新监听器
  final List<void Function(String newToken)> _tokenRefreshListeners = [];

  /// 添加 Token 刷新监听器
  void addTokenRefreshListener(void Function(String newToken) listener) {
    _tokenRefreshListeners.add(listener);
  }

  /// 移除 Token 刷新监听器
  void removeTokenRefreshListener(void Function(String newToken) listener) {
    _tokenRefreshListeners.remove(listener);
  }

  /// 获取当前 Access Token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// 获取当前 Refresh Token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  /// 检查 Token 状态
  Future<TokenStatus> checkTokenStatus() async {
    final accessToken = await getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      return TokenStatus.missing;
    }

    try {
      final payload = _decodeJwtPayload(accessToken);
      if (payload == null) {
        return TokenStatus.expired;
      }

      final exp = payload['exp'] as int?;
      if (exp == null) {
        return TokenStatus.expired;
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      if (expirationTime.isBefore(now)) {
        return TokenStatus.expired;
      }

      final timeUntilExpiration = expirationTime.difference(now);
      if (timeUntilExpiration < tokenRefreshThreshold) {
        return TokenStatus.expiringSoon;
      }

      return TokenStatus.valid;
    } catch (e) {
      log.e('解析 Token 失败: $e', tag: 'TokenManager');
      return TokenStatus.expired;
    }
  }

  /// 解码 JWT Payload
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      // 补齐 Base64 填充
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      log.e('JWT 解码失败: $e', tag: 'TokenManager');
      return null;
    }
  }

  /// 获取 Token 过期时间
  Future<DateTime?> getTokenExpiration() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    final payload = _decodeJwtPayload(accessToken);
    if (payload == null) return null;

    final exp = payload['exp'] as int?;
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  /// 确保 Token 有效
  /// 如果 Token 即将过期或已过期，自动刷新
  /// 返回有效的 Access Token，如果无法获取则返回 null
  Future<String?> ensureValidToken() async {
    final status = await checkTokenStatus();

    switch (status) {
      case TokenStatus.valid:
        return await getAccessToken();

      case TokenStatus.expiringSoon:
        log.i('Token 即将过期，尝试刷新', tag: 'TokenManager');
        final success = await refreshToken();
        if (success) {
          return await getAccessToken();
        }
        // 刷新失败但 Token 还没过期，继续使用
        return await getAccessToken();

      case TokenStatus.expired:
        log.i('Token 已过期，尝试刷新', tag: 'TokenManager');
        final success = await refreshToken();
        if (success) {
          return await getAccessToken();
        }
        // 刷新失败，触发重新登录
        _triggerReauthentication();
        return null;

      case TokenStatus.missing:
        log.w('Token 不存在', tag: 'TokenManager');
        _triggerReauthentication();
        return null;
    }
  }

  /// 刷新 Token
  /// 返回是否刷新成功
  Future<bool> refreshToken() async {
    // 如果已经在刷新，等待现有的刷新完成
    if (_isRefreshing && _refreshCompleter != null) {
      log.d('等待现有的 Token 刷新完成', tag: 'TokenManager');
      return await _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshTokenValue = await getRefreshToken();
      if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
        log.w('没有可用的 Refresh Token', tag: 'TokenManager');
        _refreshCompleter!.complete(false);
        return false;
      }

      final request = auth_pb.RefreshRequest()
        ..refreshToken = refreshTokenValue;

      final response = await authServiceClient.refreshToken(request);

      // 保存新的 Token
      await _secureStorage.write(
        key: 'access_token',
        value: response.accessToken,
      );
      await _secureStorage.write(
        key: 'refresh_token',
        value: response.refreshToken,
      );

      log.i('Token 刷新成功', tag: 'TokenManager');

      // 通知监听器
      for (final listener in _tokenRefreshListeners) {
        listener(response.accessToken);
      }

      _refreshCompleter!.complete(true);
      return true;
    } on GrpcError catch (e) {
      log.e('Token 刷新失败: [${e.code}] ${e.message}', tag: 'TokenManager');

      // 如果是认证错误，清除 Token 并触发重新登录
      if (e.code == StatusCode.unauthenticated) {
        await _clearTokens();
        _triggerReauthentication();
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      log.e('Token 刷新异常: $e', tag: 'TokenManager');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// 清除所有 Token
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_id');
  }

  /// 触发重新认证
  void _triggerReauthentication() {
    log.i('触发重新登录', tag: 'TokenManager');
    onAuthenticationRequired?.call();
  }

  /// 处理 gRPC 认证错误
  /// 尝试刷新 Token 并重试请求
  Future<T> handleAuthError<T>(
    Future<T> Function() request, {
    int maxRetries = 1,
  }) async {
    int retries = 0;

    while (true) {
      try {
        // 确保 Token 有效
        final token = await ensureValidToken();
        if (token == null) {
          throw GrpcError.unauthenticated('Token 无效');
        }

        return await request();
      } on GrpcError catch (e) {
        if (e.code == StatusCode.unauthenticated && retries < maxRetries) {
          log.i('认证失败，尝试刷新 Token 并重试', tag: 'TokenManager');
          retries++;

          final success = await refreshToken();
          if (!success) {
            _triggerReauthentication();
            rethrow;
          }
          // 继续循环重试
        } else {
          rethrow;
        }
      }
    }
  }
}

/// 回调类型定义
typedef VoidCallback = void Function();


/// Token 自动刷新拦截器
/// 在 gRPC 请求前检查 Token 状态，自动刷新即将过期的 Token
class TokenRefreshInterceptor extends ClientInterceptor {
  TokenRefreshInterceptor(this._tokenManager, this._secureStorage);

  final TokenManager _tokenManager;
  final FlutterSecureStorage _secureStorage;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    return _interceptWithTokenRefresh(
      () => invoker(method, request, options),
      options,
      (newOptions) => invoker(method, request, newOptions),
    );
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    // 对于流式请求，在建立连接前确保 Token 有效
    // 注意：流式请求的 Token 刷新需要在连接建立前完成
    return invoker(method, requests, options);
  }

  ResponseFuture<R> _interceptWithTokenRefresh<R>(
    ResponseFuture<R> Function() originalCall,
    CallOptions options,
    ResponseFuture<R> Function(CallOptions) retryCall,
  ) {
    // 创建一个新的 ResponseFuture 来处理 Token 刷新逻辑
    final completer = Completer<R>();

    _executeWithTokenRefresh(
      originalCall,
      options,
      retryCall,
      completer,
    );

    // 返回原始调用，让调用者可以获取 headers 等信息
    return originalCall();
  }

  Future<void> _executeWithTokenRefresh<R>(
    ResponseFuture<R> Function() originalCall,
    CallOptions options,
    ResponseFuture<R> Function(CallOptions) retryCall,
    Completer<R> completer,
  ) async {
    try {
      // 检查 Token 状态
      final status = await _tokenManager.checkTokenStatus();

      if (status == TokenStatus.expiringSoon) {
        // Token 即将过期，后台刷新（不阻塞当前请求）
        _tokenManager.refreshToken();
      } else if (status == TokenStatus.expired ||
          status == TokenStatus.missing) {
        // Token 已过期或不存在，先刷新再请求
        final success = await _tokenManager.refreshToken();
        if (!success) {
          completer.completeError(
            GrpcError.unauthenticated('Token 刷新失败'),
          );
          return;
        }
      }

      // 执行原始请求
      final result = await originalCall();
      completer.complete(result);
    } on GrpcError catch (e) {
      if (e.code == StatusCode.unauthenticated) {
        // 认证失败，尝试刷新 Token 并重试
        log.i('请求认证失败，尝试刷新 Token', tag: 'TokenRefreshInterceptor');

        final success = await _tokenManager.refreshToken();
        if (success) {
          try {
            // 使用新 Token 重试
            final newToken = await _secureStorage.read(key: 'access_token');
            final newOptions = options.mergedWith(
              CallOptions(
                metadata: {'authorization': 'Bearer $newToken'},
              ),
            );
            final result = await retryCall(newOptions);
            completer.complete(result);
            return;
          } catch (retryError) {
            completer.completeError(retryError);
            return;
          }
        }
      }
      completer.completeError(e);
    } catch (e) {
      completer.completeError(e);
    }
  }
}

/// 带 Token 自动刷新的 gRPC 客户端包装器
class TokenAwareGrpcClient<T> {
  TokenAwareGrpcClient({
    required this.client,
    required this.tokenManager,
  });

  final T client;
  final TokenManager tokenManager;

  /// 执行带 Token 自动刷新的请求
  Future<R> call<R>(Future<R> Function(T client) request) async {
    return await tokenManager.handleAuthError(() => request(client));
  }
}

/// Token 过期监控器
/// 定期检查 Token 状态，在即将过期时自动刷新
class TokenExpirationMonitor {
  TokenExpirationMonitor({
    required this.tokenManager,
    this.checkInterval = const Duration(minutes: 1),
  });

  final TokenManager tokenManager;
  final Duration checkInterval;

  Timer? _timer;
  bool _isRunning = false;

  /// 开始监控
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(checkInterval, (_) => _checkAndRefresh());
    log.i('Token 过期监控已启动', tag: 'TokenExpirationMonitor');
  }

  /// 停止监控
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    log.i('Token 过期监控已停止', tag: 'TokenExpirationMonitor');
  }

  Future<void> _checkAndRefresh() async {
    final status = await tokenManager.checkTokenStatus();

    if (status == TokenStatus.expiringSoon) {
      log.i('Token 即将过期，自动刷新', tag: 'TokenExpirationMonitor');
      await tokenManager.refreshToken();
    } else if (status == TokenStatus.expired) {
      log.w('Token 已过期', tag: 'TokenExpirationMonitor');
      await tokenManager.refreshToken();
    }
  }

  /// 释放资源
  void dispose() {
    stop();
  }
}
