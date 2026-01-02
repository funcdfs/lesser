import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grpc/grpc.dart';
import '../../generated/protos/auth/auth.pbgrpc.dart' as auth_pb;
import '../../generated/protos/chat/chat.pbgrpc.dart' as chat_pb;
import '../constants/app_constants.dart';
import '../grpc/grpc_client.dart';
import '../utils/app_logger.dart';

/// 连接状态枚举
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// 统一 gRPC 客户端
/// 整合 Gateway 和 Chat gRPC 客户端，提供统一的认证拦截器
/// 支持双向流连接管理、自动重连（指数退避）、心跳 Ping/Pong
class UnifiedGrpcClient {
  UnifiedGrpcClient({
    required FlutterSecureStorage secureStorage,
    String? gatewayHost,
    int? gatewayPort,
    String? chatHost,
    int? chatPort,
    this.onAuthenticationRequired,
    this.onConnectionStateChanged,
  })  : _secureStorage = secureStorage,
        _gatewayHost = gatewayHost ?? AppConstants.grpcHost,
        _gatewayPort = gatewayPort ?? AppConstants.grpcPort,
        _chatHost = chatHost ?? AppConstants.grpcHost,
        _chatPort = chatPort ?? AppConstants.chatGrpcPort;

  final FlutterSecureStorage _secureStorage;
  final String _gatewayHost;
  final int _gatewayPort;
  final String _chatHost;
  final int _chatPort;

  /// 认证失败回调（需要重新登录）
  final VoidCallback? onAuthenticationRequired;

  /// 连接状态变化回调
  final void Function(ConnectionState state)? onConnectionStateChanged;

  GrpcClientManager? _gatewayManager;
  GrpcClientManager? _chatManager;
  AuthGrpcClient? _authClient;
  ChatStreamClient? _chatStreamClient;

  ConnectionState _connectionState = ConnectionState.disconnected;
  ConnectionState get connectionState => _connectionState;

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

  /// 获取 Auth gRPC 客户端
  AuthGrpcClient get auth {
    _authClient ??= AuthGrpcClient(
      gatewayManager,
      _secureStorage,
      onAuthenticationRequired: onAuthenticationRequired,
    );
    return _authClient!;
  }

  /// 获取 Chat 双向流客户端
  ChatStreamClient get chatStream {
    _chatStreamClient ??= ChatStreamClient(
      chatManager,
      _secureStorage,
      onConnectionStateChanged: _handleConnectionStateChanged,
      onAuthenticationRequired: onAuthenticationRequired,
    );
    return _chatStreamClient!;
  }

  void _handleConnectionStateChanged(ConnectionState state) {
    _connectionState = state;
    onConnectionStateChanged?.call(state);
  }

  /// 关闭所有连接
  Future<void> shutdown() async {
    await _chatStreamClient?.disconnect();
    await _gatewayManager?.shutdown();
    await _chatManager?.shutdown();
    _gatewayManager = null;
    _chatManager = null;
    _authClient = null;
    _chatStreamClient = null;
    _connectionState = ConnectionState.disconnected;
  }
}

/// 回调类型定义
typedef VoidCallback = void Function();

/// Auth gRPC 客户端
/// 封装认证相关的 gRPC 调用
class AuthGrpcClient {
  AuthGrpcClient(
    this._manager,
    this._secureStorage, {
    this.onAuthenticationRequired,
  });

  final GrpcClientManager _manager;
  final FlutterSecureStorage _secureStorage;
  final VoidCallback? onAuthenticationRequired;

  auth_pb.AuthServiceClient? _stub;

  auth_pb.AuthServiceClient get _client {
    _stub ??= auth_pb.AuthServiceClient(_manager.channel);
    return _stub!;
  }

  /// 用户登录
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = auth_pb.LoginRequest()
        ..email = email
        ..password = password;

      final response = await _client.login(request);

      // 保存 token
      await _saveTokens(response);

      return AuthResult(
        success: true,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        user: response.user,
      );
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'Login');
      return AuthResult(
        success: false,
        errorCode: e.code.toString(),
        errorMessage: GrpcErrorHandler.getErrorMessage(e),
      );
    }
  }

  /// 用户注册
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final request = auth_pb.RegisterRequest()
        ..username = username
        ..email = email
        ..password = password;
      if (displayName != null) {
        request.displayName = displayName;
      }

      final response = await _client.register(request);

      // 保存 token
      await _saveTokens(response);

      return AuthResult(
        success: true,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        user: response.user,
      );
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
      if (refreshToken == null || refreshToken.isEmpty) {
        return AuthResult(
          success: false,
          errorCode: 'NO_REFRESH_TOKEN',
          errorMessage: '没有可用的刷新令牌',
        );
      }

      final request = auth_pb.RefreshRequest()..refreshToken = refreshToken;
      final response = await _client.refreshToken(request);

      // 更新 token
      await _saveTokens(response);

      return AuthResult(
        success: true,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id,
        user: response.user,
      );
    } on GrpcError catch (e) {
      GrpcErrorHandler.logError(e, context: 'RefreshToken');

      // 如果刷新失败且是认证错误，触发重新登录
      if (e.code == StatusCode.unauthenticated) {
        onAuthenticationRequired?.call();
      }

      return AuthResult(
        success: false,
        errorCode: e.code.toString(),
        errorMessage: GrpcErrorHandler.getErrorMessage(e),
      );
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken != null) {
        final request = auth_pb.LogoutRequest()..accessToken = accessToken;
        await _client.logout(request);
      }
    } catch (e) {
      log.w('登出请求失败: $e', tag: 'Auth');
    } finally {
      await _clearTokens();
    }
  }

  Future<void> _saveTokens(auth_pb.AuthResponse response) async {
    await _secureStorage.write(
      key: 'access_token',
      value: response.accessToken,
    );
    await _secureStorage.write(
      key: 'refresh_token',
      value: response.refreshToken,
    );
    await _secureStorage.write(key: 'user_id', value: response.user.id);
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_id');
  }
}


/// Chat 双向流客户端
/// 管理 gRPC 双向流连接，支持自动重连和心跳
class ChatStreamClient {
  ChatStreamClient(
    this._manager,
    this._secureStorage, {
    this.onConnectionStateChanged,
    this.onAuthenticationRequired,
    this.heartbeatInterval = const Duration(seconds: 30),
    this.maxReconnectAttempts = 10,
  });

  final GrpcClientManager _manager;
  final FlutterSecureStorage _secureStorage;
  final void Function(ConnectionState state)? onConnectionStateChanged;
  final VoidCallback? onAuthenticationRequired;
  final Duration heartbeatInterval;
  final int maxReconnectAttempts;

  chat_pb.ChatServiceClient? _stub;
  StreamController<chat_pb.ClientEvent>? _clientEventController;
  StreamSubscription<chat_pb.ServerEvent>? _serverEventSubscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  ConnectionState _state = ConnectionState.disconnected;
  int _reconnectAttempts = 0;
  DateTime? _lastPongReceived;

  /// 订阅的会话 ID 列表（用于重连后恢复订阅）
  final Set<String> _subscribedConversations = {};

  /// 服务端事件流
  final StreamController<chat_pb.ServerEvent> _serverEventBroadcast =
      StreamController<chat_pb.ServerEvent>.broadcast();

  /// 获取服务端事件流
  Stream<chat_pb.ServerEvent> get serverEvents => _serverEventBroadcast.stream;

  /// 当前连接状态
  ConnectionState get state => _state;

  /// 是否已连接
  bool get isConnected => _state == ConnectionState.connected;

  chat_pb.ChatServiceClient get _client {
    _stub ??= chat_pb.ChatServiceClient(_manager.channel);
    return _stub!;
  }

  /// 连接双向流
  Future<void> connect() async {
    if (_state == ConnectionState.connected ||
        _state == ConnectionState.connecting) {
      return;
    }

    _updateState(ConnectionState.connecting);

    try {
      // 创建客户端事件流控制器
      _clientEventController = StreamController<chat_pb.ClientEvent>();

      // 获取认证选项（双向流不设置超时）
      final options = await _manager.getStreamCallOptions();

      // 建立双向流连接
      final serverStream = _client.streamEvents(
        _clientEventController!.stream,
        options: options,
      );

      // 监听服务端事件
      _serverEventSubscription = serverStream.listen(
        _handleServerEvent,
        onError: _handleStreamError,
        onDone: _handleStreamDone,
        cancelOnError: false,
      );

      _updateState(ConnectionState.connected);
      _reconnectAttempts = 0;

      // 启动心跳
      _startHeartbeat();

      // 恢复之前的订阅
      await _restoreSubscriptions();

      log.i('双向流连接成功', tag: 'ChatStream');
    } catch (e) {
      log.e('双向流连接失败: $e', tag: 'ChatStream');
      _updateState(ConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _stopHeartbeat();
    _cancelReconnect();

    await _clientEventController?.close();
    await _serverEventSubscription?.cancel();

    _clientEventController = null;
    _serverEventSubscription = null;

    _updateState(ConnectionState.disconnected);
    log.i('双向流已断开', tag: 'ChatStream');
  }

  /// 订阅会话
  Future<void> subscribe(String conversationId) async {
    _subscribedConversations.add(conversationId);

    if (!isConnected) {
      await connect();
      return; // connect 会自动恢复订阅
    }

    final event = chat_pb.ClientEvent()
      ..subscribe = (chat_pb.SubscribeRequest()..conversationId = conversationId);

    _sendClientEvent(event);
    log.d('订阅会话: $conversationId', tag: 'ChatStream');
  }

  /// 取消订阅会话
  void unsubscribe(String conversationId) {
    _subscribedConversations.remove(conversationId);

    if (!isConnected) return;

    final event = chat_pb.ClientEvent()
      ..unsubscribe = (chat_pb.UnsubscribeRequest()..conversationId = conversationId);

    _sendClientEvent(event);
    log.d('取消订阅会话: $conversationId', tag: 'ChatStream');
  }

  /// 通过流发送消息
  void sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    String? clientMessageId,
  }) {
    if (!isConnected) {
      log.w('未连接，无法发送消息', tag: 'ChatStream');
      return;
    }

    final event = chat_pb.ClientEvent()
      ..sendMessage = (chat_pb.SendMessageEvent()
        ..conversationId = conversationId
        ..content = content
        ..messageType = messageType
        ..clientMessageId = clientMessageId ?? _generateClientMessageId());

    _sendClientEvent(event);
    log.d('发送消息到会话: $conversationId', tag: 'ChatStream');
  }

  /// 发送正在输入状态
  void sendTyping({
    required String conversationId,
    required bool isTyping,
  }) {
    if (!isConnected) return;

    final event = chat_pb.ClientEvent()
      ..typing = (chat_pb.TypingEvent()
        ..conversationId = conversationId
        ..isTyping = isTyping);

    _sendClientEvent(event);
  }

  /// 发送心跳 Ping
  void _sendPing() {
    if (!isConnected) return;

    final event = chat_pb.ClientEvent()..ping = chat_pb.PingEvent();
    _sendClientEvent(event);
    log.v('发送 Ping', tag: 'ChatStream');
  }

  void _sendClientEvent(chat_pb.ClientEvent event) {
    if (_clientEventController != null && !_clientEventController!.isClosed) {
      _clientEventController!.add(event);
    }
  }

  void _handleServerEvent(chat_pb.ServerEvent event) {
    // 处理 Pong 响应
    if (event.hasPong()) {
      _lastPongReceived = DateTime.now();
      log.v('收到 Pong', tag: 'ChatStream');
      return;
    }

    // 处理错误事件
    if (event.hasError()) {
      final error = event.error;
      log.e('服务端错误: [${error.code}] ${error.message}', tag: 'ChatStream');

      // 如果是认证错误，触发重新登录
      if (error.code == 'UNAUTHENTICATED') {
        onAuthenticationRequired?.call();
      }
      return;
    }

    // 处理订阅确认
    if (event.hasSubscribed()) {
      log.d('订阅确认: ${event.subscribed.conversationId}', tag: 'ChatStream');
    }

    // 处理取消订阅确认
    if (event.hasUnsubscribed()) {
      log.d('取消订阅确认: ${event.unsubscribed.conversationId}', tag: 'ChatStream');
    }

    // 广播事件给监听者
    if (!_serverEventBroadcast.isClosed) {
      _serverEventBroadcast.add(event);
    }
  }

  void _handleStreamError(Object error) {
    log.e('双向流错误: $error', tag: 'ChatStream');

    if (error is GrpcError) {
      // 认证失败，需要重新登录
      if (error.code == StatusCode.unauthenticated) {
        onAuthenticationRequired?.call();
        return;
      }
    }

    _updateState(ConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _handleStreamDone() {
    log.i('双向流已关闭', tag: 'ChatStream');
    _updateState(ConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      _sendPing();

      // 检查是否收到 Pong 响应
      if (_lastPongReceived != null) {
        final elapsed = DateTime.now().difference(_lastPongReceived!);
        if (elapsed > heartbeatInterval * 2) {
          log.w('心跳超时，重新连接', tag: 'ChatStream');
          _reconnect();
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      log.e('达到最大重连次数，停止重连', tag: 'ChatStream');
      return;
    }

    _cancelReconnect();

    // 指数退避：1s, 2s, 4s, 8s, 16s, 最大 30s
    final delay = _calculateBackoffDelay(_reconnectAttempts);
    _reconnectAttempts++;

    log.i('将在 ${delay.inSeconds}s 后重连 (第 $_reconnectAttempts 次)', tag: 'ChatStream');

    _updateState(ConnectionState.reconnecting);

    _reconnectTimer = Timer(delay, _reconnect);
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Future<void> _reconnect() async {
    _stopHeartbeat();
    await _clientEventController?.close();
    await _serverEventSubscription?.cancel();
    _clientEventController = null;
    _serverEventSubscription = null;

    await connect();
  }

  Future<void> _restoreSubscriptions() async {
    for (final conversationId in _subscribedConversations) {
      final event = chat_pb.ClientEvent()
        ..subscribe = (chat_pb.SubscribeRequest()..conversationId = conversationId);
      _sendClientEvent(event);
      log.d('恢复订阅: $conversationId', tag: 'ChatStream');
    }
  }

  Duration _calculateBackoffDelay(int attempt) {
    const baseDelay = Duration(seconds: 1);
    const maxDelay = Duration(seconds: 30);

    final delay = baseDelay * (1 << attempt.clamp(0, 5));
    return delay > maxDelay ? maxDelay : delay;
  }

  void _updateState(ConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      onConnectionStateChanged?.call(newState);
    }
  }

  String _generateClientMessageId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      length,
      (i) => chars[(random + i * 7) % chars.length],
    ).join();
  }

  /// 释放资源
  Future<void> dispose() async {
    await disconnect();
    await _serverEventBroadcast.close();
  }
}

/// 认证结果
class AuthResult {
  AuthResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.user,
    this.errorCode,
    this.errorMessage,
  });

  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final auth_pb.User? user;
  final String? errorCode;
  final String? errorMessage;
}
