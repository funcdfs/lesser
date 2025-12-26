import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../domain/models/connection_state.dart';
import '../domain/models/message.dart';

/// WebSocket 服务
/// 
/// 负责与后端 WebSocket 服务器的连接和消息传输
class WebSocketService {
  WebSocket? _socket;
  
  /// 消息流控制器
  final _messageController = StreamController<Message>.broadcast();
  
  /// 连接状态流控制器
  final _connectionStateController = StreamController<ChatConnectionState>.broadcast();
  
  /// 当前连接状态
  ChatConnectionState _currentState = ChatConnectionState.disconnected;
  
  /// WebSocket 服务器 URL
  final String _serverUrl;
  
  /// 认证令牌
  String? _authToken;
  
  /// 重连尝试次数
  int _reconnectAttempts = 0;
  
  /// 最大重连尝试次数
  static const int _maxReconnectAttempts = 5;
  
  /// 重连延迟（毫秒）
  static const int _reconnectDelayMs = 2000;
  
  /// 是否正在重连
  bool _isReconnecting = false;
  
  /// 是否手动断开
  bool _manualDisconnect = false;
  
  WebSocketService({required String serverUrl}) : _serverUrl = serverUrl;
  
  /// 消息流
  /// 
  /// 监听此流以接收新消息
  Stream<Message> get onMessage => _messageController.stream;
  
  /// 连接状态流
  /// 
  /// 监听此流以获取连接状态变化
  Stream<ChatConnectionState> get onConnectionState => _connectionStateController.stream;
  
  /// 当前连接状态
  ChatConnectionState get currentState => _currentState;
  
  /// 是否已连接
  bool get isConnected => _currentState == ChatConnectionState.connected;
  
  /// 更新连接状态
  void _updateState(ChatConnectionState state) {
    _currentState = state;
    _connectionStateController.add(state);
  }
  
  /// 连接到 WebSocket 服务器
  /// 
  /// [authToken] 认证令牌，用于身份验证
  Future<void> connect({String? authToken}) async {
    if (_currentState == ChatConnectionState.connected ||
        _currentState == ChatConnectionState.connecting) {
      return;
    }
    
    _authToken = authToken;
    _manualDisconnect = false;
    _updateState(ChatConnectionState.connecting);
    
    try {
      final uri = Uri.parse(_serverUrl);
      final headers = <String, dynamic>{};
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      
      _socket = await WebSocket.connect(
        uri.toString(),
        headers: headers,
      );
      
      _reconnectAttempts = 0;
      _updateState(ChatConnectionState.connected);
      
      // 监听消息
      _socket!.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );
    } catch (e) {
      _updateState(ChatConnectionState.disconnected);
      _scheduleReconnect();
    }
  }
  
  /// 处理接收到的消息
  void _handleMessage(dynamic data) {
    try {
      if (data is String) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        final message = Message.fromJson(json);
        _messageController.add(message);
      }
    } catch (e) {
      // 忽略无法解析的消息
    }
  }
  
  /// 处理错误
  void _handleError(dynamic error) {
    _updateState(ChatConnectionState.disconnected);
    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }
  
  /// 处理连接关闭
  void _handleDone() {
    _socket = null;
    _updateState(ChatConnectionState.disconnected);
    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }
  
  /// 安排重连
  void _scheduleReconnect() {
    if (_isReconnecting || _manualDisconnect) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    
    _isReconnecting = true;
    _reconnectAttempts++;
    _updateState(ChatConnectionState.reconnecting);
    
    Future.delayed(Duration(milliseconds: _reconnectDelayMs * _reconnectAttempts), () {
      _isReconnecting = false;
      if (!_manualDisconnect && _currentState != ChatConnectionState.connected) {
        connect(authToken: _authToken);
      }
    });
  }
  
  /// 断开连接
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectAttempts = 0;
    
    if (_socket != null) {
      await _socket!.close();
      _socket = null;
    }
    
    _updateState(ChatConnectionState.disconnected);
  }
  
  /// 发送消息
  /// 
  /// [message] 要发送的消息
  /// 返回是否发送成功
  bool send(Message message) {
    if (_socket == null || _currentState != ChatConnectionState.connected) {
      return false;
    }
    
    try {
      final json = jsonEncode(message.toJson());
      _socket!.add(json);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 发送原始 JSON 数据
  /// 
  /// [data] 要发送的 JSON 数据
  /// 返回是否发送成功
  bool sendRaw(Map<String, dynamic> data) {
    if (_socket == null || _currentState != ChatConnectionState.connected) {
      return false;
    }
    
    try {
      final json = jsonEncode(data);
      _socket!.add(json);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 手动重连
  Future<void> reconnect() async {
    _manualDisconnect = false;
    _reconnectAttempts = 0;
    await disconnect();
    await connect(authToken: _authToken);
  }
  
  /// 释放资源
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _connectionStateController.close();
  }
}
