import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/chat_websocket_service.dart';
import '../../data/models/message_model.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

// 导出 ConversationUpdatePayload, MessagesReadPayload 和 WebSocketError 供其他地方使用
export '../../data/datasources/chat_websocket_service.dart' show ConversationUpdatePayload, MessagesReadPayload, WebSocketError;

/// 会话列表状态枚举
enum ConversationsStatus { initial, loading, loaded, error }

/// 会话列表状态
class ConversationsState {
  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
    this.errorMessage,
    this.totalUnreadCount = 0,
  });

  final ConversationsStatus status;
  final List<Conversation> conversations;
  final String? errorMessage;
  final int totalUnreadCount; // 总未读数（包括待处理的增量）

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<Conversation>? conversations,
    String? errorMessage,
    int? totalUnreadCount,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      errorMessage: errorMessage,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
    );
  }
}

/// 会话列表状态管理器
class ConversationsNotifier extends Notifier<ConversationsState> {
  late final ChatRepository _repository;
  late final ChatWebSocketService _webSocketService;
  StreamSubscription<ConversationUpdatePayload>? _updateSubscription;
  StreamSubscription<int>? _totalUnreadSubscription;
  String? _activeConversationId;

  @override
  ConversationsState build() {
    _repository = getIt<ChatRepository>();
    _webSocketService = getIt<ChatWebSocketService>();
    
    // 监听会话更新通知（未读数/最后消息变化）
    _updateSubscription = _webSocketService.conversationUpdateStream.listen(_onConversationUpdate);
    
    // 监听总未读数变化
    _totalUnreadSubscription = _webSocketService.totalUnreadCountStream.listen(_onTotalUnreadCountUpdate);

    // 清理订阅
    ref.onDispose(() {
      _updateSubscription?.cancel();
      _totalUnreadSubscription?.cancel();
    });
    
    return const ConversationsState();
  }

  /// 计算并更新总未读数
  /// [extraDelta] 是额外的增量（可选）
  /// 如果服务端推送了总数，优先使用 _onTotalUnreadCountUpdate
  void _updateTotalUnreadCount(List<Conversation> conversations, {int extraDelta = 0}) {
    final listUnread = conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
    // 注意：这里我们使用列表计算的总和作为 fallback
    // 理想情况下，应该有一个单独的接口获取 accurate total count
    state = state.copyWith(
      conversations: conversations,
      totalUnreadCount: listUnread + extraDelta,
    );
  }

  /// 处理总未读数更新 (ws 推送)
  void _onTotalUnreadCountUpdate(int count) {
    state = state.copyWith(totalUnreadCount: count);
  }

  /// 处理会话更新通知
  /// 注意：服务端发送的 unreadCount 是该用户在该会话的真实未读数，不是增量
  void _onConversationUpdate(ConversationUpdatePayload update) {
    // 找到需要更新的会话
    final index = state.conversations.indexWhere((c) => c.id == update.conversationId);
    if (index == -1) {
      // 会话不在列表中，可能是新会话，刷新列表
      refresh();
      return;
    }

    // 创建新的会话列表
    final conversations = List<Conversation>.from(state.conversations);
    final oldUnread = conversations[index].unreadCount;
    
    // 解析 lastMessage（如果有）
    Message? newLastMessage;
    if (update.lastMessage != null) {
      newLastMessage = MessageModel.fromJson(update.lastMessage!);
    }
    
    // 如果当前会话是活跃的（用户正在查看），未读数保持为 0
    final newUnreadCount = update.conversationId == _activeConversationId 
        ? 0 
        : update.unreadCount;
    
    final updatedConv = conversations[index].copyWith(
      unreadCount: newUnreadCount,
      lastMessage: newLastMessage ?? conversations[index].lastMessage,
    );

    // 移除旧位置，插入到最前面（最新消息的会话排在前面）
    conversations.removeAt(index);
    conversations.insert(0, updatedConv);

    // 更新总未读数：减去旧的，加上新的
    // 注意：如果有 totalUnreadCountStream，这里可能不需要手动计算，
    // 但为了 UI 即时响应，我们还是先做一个乐观更新
    final delta = newUnreadCount - oldUnread;
    final newTotalUnread = (state.totalUnreadCount + delta).clamp(0, double.infinity).toInt();
    
    state = state.copyWith(
      conversations: conversations,
      totalUnreadCount: newTotalUnread,
    );
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    state = state.copyWith(status: ConversationsStatus.loading);

    final result = await _repository.getConversations();

    result.fold(
      (failure) => state = state.copyWith(
        status: ConversationsStatus.error,
        errorMessage: failure.message,
      ),
      (conversations) {
        state = state.copyWith(status: ConversationsStatus.loaded);
        _updateTotalUnreadCount(conversations);
      },
    );
  }

  /// 刷新会话列表
  Future<void> refresh() async {
    final result = await _repository.getConversations();
    result.fold(
      (failure) => {},
      (conversations) {
        _updateTotalUnreadCount(conversations);
      },
    );
  }

  /// 清除指定会话的未读数（进入聊天室时调用）
  void clearUnreadCount(String conversationId) {
    final index = state.conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final conversations = List<Conversation>.from(state.conversations);
    conversations[index] = conversations[index].copyWith(unreadCount: 0);
    _updateTotalUnreadCount(conversations);
  }

  /// Mark conversation as active (user entered chat)
  void enterConversation(String conversationId) {
    _activeConversationId = conversationId;
    clearUnreadCount(conversationId);
  }

  /// Mark conversation as inactive (user left chat)
  void leaveConversation() {
    _activeConversationId = null;
  }
}

/// 聊天室状态枚举
enum ChatRoomStatus { initial, loading, loaded, error, sending, loadingMore }

/// 聊天室状态
class ChatRoomState {
  const ChatRoomState({
    this.status = ChatRoomStatus.initial,
    this.conversation,
    this.messages = const [],
    this.errorMessage,
    this.currentUserId,
    this.hasNewMessages = false,
    this.hasMoreMessages = true,
  });

  final ChatRoomStatus status;
  final Conversation? conversation;
  final List<Message> messages;
  final String? errorMessage;
  final String? currentUserId;
  final bool hasNewMessages; // 是否有新消息（用于显示跳转到底部按钮）
  final bool hasMoreMessages; // 是否还有更多历史消息

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    String? errorMessage,
    String? currentUserId,
    bool? hasNewMessages,
    bool? hasMoreMessages,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      currentUserId: currentUserId ?? this.currentUserId,
      hasNewMessages: hasNewMessages ?? this.hasNewMessages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
    );
  }
}

/// 聊天室状态管理器
class ChatRoomNotifier extends Notifier<ChatRoomState> {
  late ChatRepository _repository;
  late ChatWebSocketService _webSocketService;
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<MessagesReadPayload>? _messagesReadSubscription;
  StreamSubscription<WebSocketError>? _errorSubscription;
  String? _currentConversationId;

  @override
  ChatRoomState build() {
    _repository = getIt<ChatRepository>();
    _webSocketService = getIt<ChatWebSocketService>();
    
    final authState = ref.watch(authProvider);
    
    // 监听实时消息（只有订阅了具体会话才会收到）
    _messageSubscription = _webSocketService.messageStream.listen(_onMessageReceived);
    // 监听消息已读通知
    _messagesReadSubscription = _webSocketService.messagesReadStream.listen(_onMessagesRead);
    // 监听 WebSocket 错误（如订阅失败）
    _errorSubscription = _webSocketService.errorStream.listen(_onWebSocketError);
    
    // 清理订阅
    ref.onDispose(() {
      _messageSubscription?.cancel();
      _messagesReadSubscription?.cancel();
      _errorSubscription?.cancel();
      if (_currentConversationId != null) {
        _webSocketService.unsubscribeFromConversation(_currentConversationId!);
        // Leave conversation to update global unread count logic
        ref.read(conversationsProvider.notifier).leaveConversation();
      }
    });
    
    return ChatRoomState(currentUserId: authState.user?.id);
  }

  /// 处理接收到的实时消息
  void _onMessageReceived(Message message) {
    // 只处理当前会话的消息
    if (message.conversationId != _currentConversationId) return;

    // 检查消息是否已存在（防止重复）
    final exists = state.messages.any((m) => m.id == message.id);
    if (exists) return;

    // 不添加自己发送的消息（已通过乐观更新添加）
    if (message.senderId == state.currentUserId) return;

    state = state.copyWith(
      messages: [message, ...state.messages],
      hasNewMessages: true, // 标记有新消息
    );
  }

  /// 处理消息已读通知
  void _onMessagesRead(MessagesReadPayload payload) {
    // 只处理当前会话的已读通知
    if (payload.conversationId != _currentConversationId) return;
    
    // 只处理对方读取我发送的消息
    if (payload.readerId == state.currentUserId) return;

    // 更新消息的已读状态
    final updatedMessages = state.messages.map((m) {
      if (payload.messageIds.contains(m.id) && m.senderId == state.currentUserId) {
        return m.copyWithRead();
      }
      return m;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  /// 处理 WebSocket 错误
  void _onWebSocketError(WebSocketError error) {
    // 只处理订阅相关的错误
    if (error.action == 'subscribe') {
      state = state.copyWith(
        errorMessage: '实时消息订阅失败: ${error.message}',
      );
    }
  }

  /// 进入会话时清除未读数的回调
  void _onEnterConversation(String conversationId) {
    ref.read(conversationsProvider.notifier).enterConversation(conversationId);
  }

  /// 加载会话详情和消息
  Future<void> loadConversation(String conversationId) async {
    // 取消订阅之前的会话
    if (_currentConversationId != null) {
      _webSocketService.unsubscribeFromConversation(_currentConversationId!);
    }

    _currentConversationId = conversationId;
    state = state.copyWith(status: ChatRoomStatus.loading);

    final conversationResult = await _repository.getConversation(conversationId);
    final messagesResult = await _repository.getMessages(
      conversationId: conversationId,
    );

    conversationResult.fold(
      (failure) => state = state.copyWith(
        status: ChatRoomStatus.error,
        errorMessage: failure.message,
      ),
      (conversation) {
        messagesResult.fold(
          (failure) => state = state.copyWith(
            status: ChatRoomStatus.error,
            errorMessage: failure.message,
          ),
          (messages) {
            state = state.copyWith(
              status: ChatRoomStatus.loaded,
              conversation: conversation,
              messages: messages,
            );
            // 订阅会话以接收实时更新
            _webSocketService.subscribeToConversation(conversationId);
            // 清除该会话的未读数（本地 + 服务端）
            _onEnterConversation(conversationId);
            // 异步调用服务端标记已读（不阻塞 UI）
            _repository.markAsRead(conversationId);
          },
        );
      },
    );
  }

  /// 发送消息（带乐观更新）
  Future<void> sendMessage(String content) async {
    if (state.conversation == null || state.currentUserId == null) return;

    // 生成临时消息ID用于乐观更新
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMessage = Message(
      id: tempId,
      conversationId: state.conversation!.id,
      senderId: state.currentUserId!,
      content: content,
      messageType: MessageType.text,
      createdAt: DateTime.now(),
    );

    // 乐观更新：立即显示消息
    state = state.copyWith(
      status: ChatRoomStatus.sending,
      messages: [tempMessage, ...state.messages],
    );

    final result = await _repository.sendMessage(
      conversationId: state.conversation!.id,
      content: content,
    );

    result.fold(
      (failure) {
        // 发送失败：移除临时消息，显示错误
        state = state.copyWith(
          status: ChatRoomStatus.loaded,
          messages: state.messages.where((m) => m.id != tempId).toList(),
          errorMessage: failure.message,
        );
      },
      (message) {
        // 发送成功：用真实消息替换临时消息
        state = state.copyWith(
          status: ChatRoomStatus.loaded,
          messages: state.messages.map((m) => m.id == tempId ? message : m).toList(),
        );
      },
    );
  }

  /// 加载更多历史消息
  Future<void> loadMoreMessages() async {
    // 防止重复加载或无效加载
    if (state.conversation == null || 
        state.messages.isEmpty ||
        state.status == ChatRoomStatus.loadingMore ||
        !state.hasMoreMessages) {
      return;
    }

    state = state.copyWith(status: ChatRoomStatus.loadingMore);

    final currentPage = (state.messages.length / 50).ceil() + 1;
    final result = await _repository.getMessages(
      conversationId: state.conversation!.id,
      page: currentPage,
    );

    result.fold(
      (failure) {
        state = state.copyWith(status: ChatRoomStatus.loaded);
      },
      (messages) {
        if (messages.isEmpty) {
          // 没有更多消息了
          state = state.copyWith(
            status: ChatRoomStatus.loaded,
            hasMoreMessages: false,
          );
        } else {
          // 过滤掉已存在的消息（防止重复）
          final existingIds = state.messages.map((m) => m.id).toSet();
          final newMessages = messages.where((m) => !existingIds.contains(m.id)).toList();
          
          state = state.copyWith(
            status: ChatRoomStatus.loaded,
            messages: [...state.messages, ...newMessages],
            hasMoreMessages: messages.length >= 50, // 假设每页 50 条
          );
        }
      },
    );
  }

  /// 清除新消息标记（用户滚动到底部时调用）
  void clearNewMessagesFlag() {
    if (state.hasNewMessages) {
      state = state.copyWith(hasNewMessages: false);
    }
  }
}

/// 会话列表 Provider
final conversationsProvider = NotifierProvider<ConversationsNotifier, ConversationsState>(
  ConversationsNotifier.new,
);

/// 聊天室 Provider
final chatRoomProvider =
    NotifierProvider.autoDispose<ChatRoomNotifier, ChatRoomState>(
  ChatRoomNotifier.new,
);
