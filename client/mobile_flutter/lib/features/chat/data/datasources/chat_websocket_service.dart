import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/message_model.dart';

const _tag = 'ChatWebSocket';

/// WebSocket 消息类型常量
class WSMessageType {
  static const String message = 'message';       // 新消息
  static const String subscribed = 'subscribed'; // 订阅成功
  static const String unsubscribed = 'unsubscribed'; // 取消订阅成功
}

/// 聊天 WebSocket 服务
/// 负责管理实时消息的 WebSocket 连接
class ChatWebSocketService {
  ChatWebSocketService();

  WebSocketChannel? _channel;
  String? _currentUserId;
  final _messageController = StreamController<MessageModel>.broadcast();
  final _subscribedConversations = <String>{};
  Timer? _reconnectTimer;
  bool _isConnecting = false;

  /// 接收消息的流
  Stream<MessageModel> get messageStream => _messageController.stream;

  /// 连接到 WebSocket 服务器
  Future<void> connect(String userId) async {
    if (_isConnecting || (_channel != null && _currentUserId == userId)) {
      return;
    }

    _isConnecting = true;
    _currentUserId = userId;

    try {
      await _disconnect();

      final wsUrl = AppConstants.wsBaseUrl;
      final uri = Uri.parse('$wsUrl/ws/chat?user_id=$userId');
      
      log.i('正在连接 WebSocket: $uri', tag: _tag);
      
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          log.e('WebSocket 错误: $error', tag: _tag);
          _scheduleReconnect();
        },
        onDone: () {
          log.i('WebSocket 连接已关闭', tag: _tag);
          _scheduleReconnect();
        },
      );

      // 重新订阅之前订阅的会话
      for (final convId in _subscribedConversations) {
        _sendSubscribe(convId);
      }

      log.i('WebSocket 已连接，用户: $userId', tag: _tag);
    } catch (e) {
      log.e('连接 WebSocket 失败: $e', tag: _tag);
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  /// 断开 WebSocket 连接
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _disconnect();
    _currentUserId = null;
    _subscribedConversations.clear();
  }

  Future<void> _disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
  }

  /// 安排重连
  void _scheduleReconnect() {
    if (_currentUserId == null || _reconnectTimer != null) return;

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _reconnectTimer = null;
      if (_currentUserId != null) {
        connect(_currentUserId!);
      }
    });
  }

  /// 订阅会话的实时消息更新
  void subscribeToConversation(String conversationId) {
    _subscribedConversations.add(conversationId);
    _sendSubscribe(conversationId);
  }

  /// 取消订阅会话
  void unsubscribeFromConversation(String conversationId) {
    _subscribedConversations.remove(conversationId);
    _sendUnsubscribe(conversationId);
  }

  void _sendSubscribe(String conversationId) {
    _sendCommand({'action': 'subscribe', 'conversation_id': conversationId});
  }

  void _sendUnsubscribe(String conversationId) {
    _sendCommand({'action': 'unsubscribe', 'conversation_id': conversationId});
  }

  void _sendCommand(Map<String, dynamic> command) {
    if (_channel == null) return;
    
    try {
      _channel!.sink.add(jsonEncode(command));
    } catch (e) {
      log.e('发送命令失败: $e', tag: _tag);
    }
  }

  /// 处理接收到的 WebSocket 消息
  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case WSMessageType.message:
          final payload = json['payload'] as Map<String, dynamic>;
          final message = MessageModel.fromJson(payload);
          _messageController.add(message);
          log.d('收到消息: ${message.id}', tag: _tag);
          break;
        case WSMessageType.subscribed:
          log.d('已订阅: ${json['payload']}', tag: _tag);
          break;
        case WSMessageType.unsubscribed:
          log.d('已取消订阅: ${json['payload']}', tag: _tag);
          break;
        default:
          log.w('未知消息类型: $type', tag: _tag);
      }
    } catch (e) {
      log.e('处理消息失败: $e', tag: _tag);
    }
  }

  /// 释放资源
  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageController.close();
  }
}
