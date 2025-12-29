import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/message_model.dart';

const _tag = 'ChatWebSocket';

/// WebSocket 消息类型常量
class WSMessageType {
  static const String message = 'message'; // 新消息（订阅会话后收到）
  static const String subscribed = 'subscribed'; // 订阅成功
  static const String unsubscribed = 'unsubscribed'; // 取消订阅成功
  static const String conversationUpdate =
      'conversation_update'; // 会话更新（未读数/最后消息）
  static const String unreadUpdate = 'unread_update'; // 总未读数更新
  static const String messagesRead = 'messages_read'; // 消息已读通知
}

/// 会话更新载荷
class ConversationUpdatePayload {
  ConversationUpdatePayload({
    required this.conversationId,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ConversationUpdatePayload.fromJson(Map<String, dynamic> json) {
    return ConversationUpdatePayload(
      conversationId: json['conversation_id'] as String,
      lastMessage: json['last_message'] as Map<String, dynamic>?,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
  final String conversationId;
  final Map<String, dynamic>? lastMessage;
  final int unreadCount;
}

/// 消息已读通知载荷
class MessagesReadPayload {
  MessagesReadPayload({
    required this.conversationId,
    required this.readerId,
    required this.messageIds,
  });

  factory MessagesReadPayload.fromJson(Map<String, dynamic> json) {
    return MessagesReadPayload(
      conversationId: json['conversation_id'] as String,
      readerId: json['reader_id'] as String,
      messageIds: (json['message_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
  final String conversationId;
  final String readerId;
  final List<String> messageIds;
}

/// WebSocket 错误信息
class WebSocketError {
  WebSocketError({required this.action, required this.message});
  final String action;
  final String message;
}

/// 聊天 WebSocket 服务
/// 负责管理实时消息的 WebSocket 连接
class ChatWebSocketService {
  ChatWebSocketService();

  WebSocketChannel? _channel;
  String? _currentUserId;
  StreamController<MessageModel>? _messageController;
  StreamController<ConversationUpdatePayload>? _conversationUpdateController;
  StreamController<MessagesReadPayload>? _messagesReadController;
  StreamController<WebSocketError>? _errorController;
  final _subscribedConversations = <String>{};
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _isDisposed = false;

  /// 确保 StreamController 已初始化
  void _ensureControllers() {
    if (_isDisposed) return;
    if (_messageController == null || _messageController!.isClosed) {
      _messageController = StreamController<MessageModel>.broadcast();
    }
    if (_conversationUpdateController == null ||
        _conversationUpdateController!.isClosed) {
      _conversationUpdateController =
          StreamController<ConversationUpdatePayload>.broadcast();
    }
    if (_messagesReadController == null || _messagesReadController!.isClosed) {
      _messagesReadController = StreamController<MessagesReadPayload>.broadcast();
    }
    if (_errorController == null || _errorController!.isClosed) {
      _errorController = StreamController<WebSocketError>.broadcast();
    }
  }

  /// 接收消息的流（订阅具体会话后收到的完整消息）
  Stream<MessageModel> get messageStream {
    _ensureControllers();
    return _messageController!.stream;
  }

  /// 会话更新的流（未读数/最后消息变化，不需要订阅具体会话）
  Stream<ConversationUpdatePayload> get conversationUpdateStream {
    _ensureControllers();
    return _conversationUpdateController!.stream;
  }

  /// 消息已读通知的流（对方已读我发送的消息）
  Stream<MessagesReadPayload> get messagesReadStream {
    _ensureControllers();
    return _messagesReadController!.stream;
  }

  /// 错误事件流（订阅失败等错误）
  Stream<WebSocketError> get errorStream {
    _ensureControllers();
    return _errorController!.stream;
  }

  /// 连接到 WebSocket 服务器
  Future<void> connect(String userId) async {
    if (_isDisposed) {
      log.w('WebSocket 服务已释放，无法连接', tag: _tag);
      return;
    }
    if (_isConnecting || (_channel != null && _currentUserId == userId)) {
      return;
    }

    _isConnecting = true;
    _currentUserId = userId;
    _ensureControllers();

    try {
      await _disconnect();

      const wsUrl = AppConstants.wsBaseUrl;
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
    if (_isDisposed || _currentUserId == null || _reconnectTimer != null) {
      return;
    }

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _reconnectTimer = null;
      if (!_isDisposed && _currentUserId != null) {
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
    if (_isDisposed) return;

    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case WSMessageType.message:
          final payload = json['payload'] as Map<String, dynamic>;
          final message = MessageModel.fromJson(payload);
          if (_messageController != null && !_messageController!.isClosed) {
            _messageController!.add(message);
          }
          log.d('收到消息: ${message.id}', tag: _tag);
          break;
        case WSMessageType.conversationUpdate:
          final payload = json['payload'] as Map<String, dynamic>;
          final update = ConversationUpdatePayload.fromJson(payload);
          if (_conversationUpdateController != null &&
              !_conversationUpdateController!.isClosed) {
            _conversationUpdateController!.add(update);
          }
          log.d('收到会话更新: ${update.conversationId}', tag: _tag);
          break;
        case WSMessageType.messagesRead:
          final payload = json['payload'] as Map<String, dynamic>;
          final readPayload = MessagesReadPayload.fromJson(payload);
          if (_messagesReadController != null &&
              !_messagesReadController!.isClosed) {
            _messagesReadController!.add(readPayload);
          }
          log.d('收到已读通知: ${readPayload.conversationId}, 消息数: ${readPayload.messageIds.length}', tag: _tag);
          break;
        case WSMessageType.unreadUpdate:
          log.d('收到未读数更新: ${json['payload']}', tag: _tag);
          // TODO: 可以添加总未读数的流
          break;
        case WSMessageType.subscribed:
          log.d('已订阅: ${json['payload']}', tag: _tag);
          break;
        case WSMessageType.unsubscribed:
          log.d('已取消订阅: ${json['payload']}', tag: _tag);
          break;
        case 'error':
          final payload = json['payload'] as Map<String, dynamic>?;
          final action = payload?['action'] as String? ?? 'unknown';
          final message = payload?['message'] as String? ?? '未知错误';
          log.e('WebSocket 错误: $message (action: $action)', tag: _tag);
          // 通知 UI 层
          if (_errorController != null && !_errorController!.isClosed) {
            _errorController!.add(
              WebSocketError(action: action, message: message),
            );
          }
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
    if (_isDisposed) return;
    _isDisposed = true;
    log.i('WebSocket 服务正在释放资源', tag: _tag);
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _channel = null;
    _messageController?.close();
    _conversationUpdateController?.close();
    _messagesReadController?.close();
    _errorController?.close();
  }
}
