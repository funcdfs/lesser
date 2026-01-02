import 'dart:async';
import '../../generated/protos/chat/chat.pb.dart';
import '../utils/app_logger.dart';

/// 服务端事件类型
enum ServerEventType {
  newMessage,
  messageRead,
  conversationUpdate,
  unreadUpdate,
  userStatus,
  typingIndicator,
  subscribed,
  unsubscribed,
  messageSent,
  error,
  unknown,
}

/// 服务端事件处理器
/// 负责分发和处理来自 gRPC 双向流的服务端事件
class StreamEventHandler {
  StreamEventHandler();

  // 各类型事件的流控制器
  final _newMessageController = StreamController<NewMessageEvent>.broadcast();
  final _messageReadController = StreamController<MessageReadEvent>.broadcast();
  final _conversationUpdateController =
      StreamController<ConversationUpdateEvent>.broadcast();
  final _unreadUpdateController =
      StreamController<UnreadCountUpdateEvent>.broadcast();
  final _userStatusController = StreamController<UserStatusEvent>.broadcast();
  final _typingIndicatorController =
      StreamController<TypingIndicatorEvent>.broadcast();
  final _subscribedController = StreamController<SubscribedEvent>.broadcast();
  final _unsubscribedController =
      StreamController<UnsubscribedEvent>.broadcast();
  final _messageSentController = StreamController<MessageSentEvent>.broadcast();
  final _errorController = StreamController<ErrorEvent>.broadcast();

  // 通用事件流（所有事件）
  final _allEventsController = StreamController<ServerEvent>.broadcast();

  /// 新消息事件流
  Stream<NewMessageEvent> get onNewMessage => _newMessageController.stream;

  /// 消息已读事件流
  Stream<MessageReadEvent> get onMessageRead => _messageReadController.stream;

  /// 会话更新事件流
  Stream<ConversationUpdateEvent> get onConversationUpdate =>
      _conversationUpdateController.stream;

  /// 未读数更新事件流
  Stream<UnreadCountUpdateEvent> get onUnreadUpdate =>
      _unreadUpdateController.stream;

  /// 用户状态事件流
  Stream<UserStatusEvent> get onUserStatus => _userStatusController.stream;

  /// 正在输入指示事件流
  Stream<TypingIndicatorEvent> get onTypingIndicator =>
      _typingIndicatorController.stream;

  /// 订阅确认事件流
  Stream<SubscribedEvent> get onSubscribed => _subscribedController.stream;

  /// 取消订阅确认事件流
  Stream<UnsubscribedEvent> get onUnsubscribed =>
      _unsubscribedController.stream;

  /// 消息发送确认事件流
  Stream<MessageSentEvent> get onMessageSent => _messageSentController.stream;

  /// 错误事件流
  Stream<ErrorEvent> get onError => _errorController.stream;

  /// 所有事件流
  Stream<ServerEvent> get allEvents => _allEventsController.stream;

  /// 处理服务端事件
  /// 将事件分发到对应的流
  void handleEvent(ServerEvent event) {
    // 广播到通用事件流
    if (!_allEventsController.isClosed) {
      _allEventsController.add(event);
    }

    // 根据事件类型分发
    final eventType = _getEventType(event);

    switch (eventType) {
      case ServerEventType.newMessage:
        _handleNewMessage(event.newMessage);
        break;
      case ServerEventType.messageRead:
        _handleMessageRead(event.messageRead);
        break;
      case ServerEventType.conversationUpdate:
        _handleConversationUpdate(event.conversationUpdate);
        break;
      case ServerEventType.unreadUpdate:
        _handleUnreadUpdate(event.unreadUpdate);
        break;
      case ServerEventType.userStatus:
        _handleUserStatus(event.userStatus);
        break;
      case ServerEventType.typingIndicator:
        _handleTypingIndicator(event.typingIndicator);
        break;
      case ServerEventType.subscribed:
        _handleSubscribed(event.subscribed);
        break;
      case ServerEventType.unsubscribed:
        _handleUnsubscribed(event.unsubscribed);
        break;
      case ServerEventType.messageSent:
        _handleMessageSent(event.messageSent);
        break;
      case ServerEventType.error:
        _handleError(event.error);
        break;
      case ServerEventType.unknown:
        log.w('收到未知类型的服务端事件', tag: 'StreamEventHandler');
        break;
    }
  }

  ServerEventType _getEventType(ServerEvent event) {
    switch (event.whichEvent()) {
      case ServerEvent_Event.newMessage:
        return ServerEventType.newMessage;
      case ServerEvent_Event.messageRead:
        return ServerEventType.messageRead;
      case ServerEvent_Event.conversationUpdate:
        return ServerEventType.conversationUpdate;
      case ServerEvent_Event.unreadUpdate:
        return ServerEventType.unreadUpdate;
      case ServerEvent_Event.userStatus:
        return ServerEventType.userStatus;
      case ServerEvent_Event.typingIndicator:
        return ServerEventType.typingIndicator;
      case ServerEvent_Event.subscribed:
        return ServerEventType.subscribed;
      case ServerEvent_Event.unsubscribed:
        return ServerEventType.unsubscribed;
      case ServerEvent_Event.messageSent:
        return ServerEventType.messageSent;
      case ServerEvent_Event.error:
        return ServerEventType.error;
      case ServerEvent_Event.pong:
      case ServerEvent_Event.notSet:
        return ServerEventType.unknown;
    }
  }

  void _handleNewMessage(NewMessageEvent event) {
    log.d(
      '新消息: ${event.message.id} 来自会话 ${event.message.conversationId}',
      tag: 'StreamEventHandler',
    );
    if (!_newMessageController.isClosed) {
      _newMessageController.add(event);
    }
  }

  void _handleMessageRead(MessageReadEvent event) {
    log.d(
      '消息已读: ${event.messageId} 被 ${event.readerId} 阅读',
      tag: 'StreamEventHandler',
    );
    if (!_messageReadController.isClosed) {
      _messageReadController.add(event);
    }
  }

  void _handleConversationUpdate(ConversationUpdateEvent event) {
    log.d(
      '会话更新: ${event.conversationId}',
      tag: 'StreamEventHandler',
    );
    if (!_conversationUpdateController.isClosed) {
      _conversationUpdateController.add(event);
    }
  }

  void _handleUnreadUpdate(UnreadCountUpdateEvent event) {
    log.d(
      '未读数更新: ${event.conversationId} -> ${event.count}',
      tag: 'StreamEventHandler',
    );
    if (!_unreadUpdateController.isClosed) {
      _unreadUpdateController.add(event);
    }
  }

  void _handleUserStatus(UserStatusEvent event) {
    log.d(
      '用户状态: ${event.userId} ${event.isOnline ? "在线" : "离线"}',
      tag: 'StreamEventHandler',
    );
    if (!_userStatusController.isClosed) {
      _userStatusController.add(event);
    }
  }

  void _handleTypingIndicator(TypingIndicatorEvent event) {
    log.v(
      '正在输入: ${event.userId} 在 ${event.conversationId} ${event.isTyping ? "开始" : "停止"}输入',
      tag: 'StreamEventHandler',
    );
    if (!_typingIndicatorController.isClosed) {
      _typingIndicatorController.add(event);
    }
  }

  void _handleSubscribed(SubscribedEvent event) {
    log.d(
      '订阅成功: ${event.conversationId}',
      tag: 'StreamEventHandler',
    );
    if (!_subscribedController.isClosed) {
      _subscribedController.add(event);
    }
  }

  void _handleUnsubscribed(UnsubscribedEvent event) {
    log.d(
      '取消订阅成功: ${event.conversationId}',
      tag: 'StreamEventHandler',
    );
    if (!_unsubscribedController.isClosed) {
      _unsubscribedController.add(event);
    }
  }

  void _handleMessageSent(MessageSentEvent event) {
    log.d(
      '消息发送确认: clientId=${event.clientMessageId} -> serverId=${event.message.id}',
      tag: 'StreamEventHandler',
    );
    if (!_messageSentController.isClosed) {
      _messageSentController.add(event);
    }
  }

  void _handleError(ErrorEvent event) {
    log.e(
      '服务端错误: [${event.code}] ${event.message} (action: ${event.action})',
      tag: 'StreamEventHandler',
    );
    if (!_errorController.isClosed) {
      _errorController.add(event);
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _newMessageController.close();
    await _messageReadController.close();
    await _conversationUpdateController.close();
    await _unreadUpdateController.close();
    await _userStatusController.close();
    await _typingIndicatorController.close();
    await _subscribedController.close();
    await _unsubscribedController.close();
    await _messageSentController.close();
    await _errorController.close();
    await _allEventsController.close();
  }
}


/// 会话订阅管理器
/// 管理会话订阅状态和事件过滤
class ConversationSubscriptionManager {
  ConversationSubscriptionManager(this._eventHandler);

  final StreamEventHandler _eventHandler;

  /// 已订阅的会话 ID
  final Set<String> _subscribedConversations = {};

  /// 待确认的订阅请求
  final Set<String> _pendingSubscriptions = {};

  /// 待确认的取消订阅请求
  final Set<String> _pendingUnsubscriptions = {};

  StreamSubscription<SubscribedEvent>? _subscribedSub;
  StreamSubscription<UnsubscribedEvent>? _unsubscribedSub;

  /// 获取已订阅的会话列表
  Set<String> get subscribedConversations =>
      Set.unmodifiable(_subscribedConversations);

  /// 检查是否已订阅某会话
  bool isSubscribed(String conversationId) =>
      _subscribedConversations.contains(conversationId);

  /// 初始化监听
  void init() {
    _subscribedSub = _eventHandler.onSubscribed.listen(_handleSubscribed);
    _unsubscribedSub = _eventHandler.onUnsubscribed.listen(_handleUnsubscribed);
  }

  /// 标记订阅请求已发送
  void markSubscriptionPending(String conversationId) {
    _pendingSubscriptions.add(conversationId);
  }

  /// 标记取消订阅请求已发送
  void markUnsubscriptionPending(String conversationId) {
    _pendingUnsubscriptions.add(conversationId);
  }

  void _handleSubscribed(SubscribedEvent event) {
    final conversationId = event.conversationId;
    _pendingSubscriptions.remove(conversationId);
    _subscribedConversations.add(conversationId);
  }

  void _handleUnsubscribed(UnsubscribedEvent event) {
    final conversationId = event.conversationId;
    _pendingUnsubscriptions.remove(conversationId);
    _subscribedConversations.remove(conversationId);
  }

  /// 获取特定会话的新消息流
  Stream<NewMessageEvent> getNewMessagesForConversation(String conversationId) {
    return _eventHandler.onNewMessage
        .where((event) => event.message.conversationId == conversationId);
  }

  /// 获取特定会话的已读回执流
  Stream<MessageReadEvent> getMessageReadsForConversation(
      String conversationId) {
    return _eventHandler.onMessageRead
        .where((event) => event.conversationId == conversationId);
  }

  /// 获取特定会话的正在输入指示流
  Stream<TypingIndicatorEvent> getTypingIndicatorsForConversation(
      String conversationId) {
    return _eventHandler.onTypingIndicator
        .where((event) => event.conversationId == conversationId);
  }

  /// 获取特定会话的更新流
  Stream<ConversationUpdateEvent> getUpdatesForConversation(
      String conversationId) {
    return _eventHandler.onConversationUpdate
        .where((event) => event.conversationId == conversationId);
  }

  /// 清除所有订阅状态
  void clear() {
    _subscribedConversations.clear();
    _pendingSubscriptions.clear();
    _pendingUnsubscriptions.clear();
  }

  /// 释放资源
  Future<void> dispose() async {
    await _subscribedSub?.cancel();
    await _unsubscribedSub?.cancel();
    clear();
  }
}

/// 消息发送追踪器
/// 追踪通过流发送的消息状态
class MessageSendTracker {
  MessageSendTracker(this._eventHandler);

  final StreamEventHandler _eventHandler;

  /// 待确认的消息 Map<clientMessageId, Completer>
  final Map<String, Completer<Message>> _pendingMessages = {};

  StreamSubscription<MessageSentEvent>? _messageSentSub;
  StreamSubscription<ErrorEvent>? _errorSub;

  /// 初始化监听
  void init() {
    _messageSentSub = _eventHandler.onMessageSent.listen(_handleMessageSent);
    _errorSub = _eventHandler.onError.listen(_handleError);
  }

  /// 追踪消息发送
  /// 返回一个 Future，在收到服务端确认后完成
  Future<Message> trackMessage(String clientMessageId) {
    final completer = Completer<Message>();
    _pendingMessages[clientMessageId] = completer;

    // 设置超时
    Future.delayed(const Duration(seconds: 30), () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('消息发送超时', const Duration(seconds: 30)),
        );
        _pendingMessages.remove(clientMessageId);
      }
    });

    return completer.future;
  }

  void _handleMessageSent(MessageSentEvent event) {
    final completer = _pendingMessages.remove(event.clientMessageId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(event.message);
    }
  }

  void _handleError(ErrorEvent event) {
    // 如果错误与特定消息相关，完成对应的 completer
    if (event.action.isNotEmpty) {
      final completer = _pendingMessages.remove(event.action);
      if (completer != null && !completer.isCompleted) {
        completer.completeError(
          Exception('[${event.code}] ${event.message}'),
        );
      }
    }
  }

  /// 取消所有待确认的消息
  void cancelAll() {
    for (final completer in _pendingMessages.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('连接已断开'));
      }
    }
    _pendingMessages.clear();
  }

  /// 释放资源
  Future<void> dispose() async {
    await _messageSentSub?.cancel();
    await _errorSub?.cancel();
    cancelAll();
  }
}

/// 超时异常
class TimeoutException implements Exception {
  TimeoutException(this.message, this.duration);

  final String message;
  final Duration duration;

  @override
  String toString() => 'TimeoutException: $message (after ${duration.inSeconds}s)';
}
