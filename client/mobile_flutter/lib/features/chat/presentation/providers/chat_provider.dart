import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/unified_grpc_client.dart';
import '../../../../core/network/stream_event_handler.dart';
import '../../../../generated/protos/chat/chat.pb.dart' as pb;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/message_model.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

/// 会话更新载荷（用于内部事件处理）
class ConversationUpdatePayload {
  const ConversationUpdatePayload({
    required this.conversationId,
    required this.unreadCount,
    this.lastMessage,
  });

  final String conversationId;
  final int unreadCount;
  final Map<String, dynamic>? lastMessage;
}

/// 消息已读载荷
class MessagesReadPayload {
  const MessagesReadPayload({
    required this.conversationId,
    required this.readerId,
    required this.messageIds,
  });

  final String conversationId;
  final String readerId;
  final List<String> messageIds;
}

/// gRPC 流错误
class GrpcStreamError {
  const GrpcStreamError({
    required this.code,
    required this.message,
    required this.action,
  });

  final String code;
  final String message;
  final String action;
}

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
  final int totalUnreadCount;

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
  late final UnifiedGrpcClient _grpcClient;
  late final StreamEventHandler _eventHandler;
  
  StreamSubscription<pb.ServerEvent>? _serverEventSubscription;
  String? _activeConversationId;

  @override
  ConversationsState build() {
    _repository = getIt<ChatRepository>();
    _grpcClient = getIt<UnifiedGrpcClient>();
    _eventHandler = getIt<StreamEventHandler>();
    
    // 监听 gRPC 双向流的服务端事件
    _serverEventSubscription = _grpcClient.chatStream.serverEvents.listen(_handleServerEvent);

    // 清理订阅
    ref.onDispose(() {
      _serverEventSubscription?.cancel();
    });
    
    return const ConversationsState();
  }

  /// 处理服务端事件
  void _handleServerEvent(pb.ServerEvent event) {
    // 分发事件到 StreamEventHandler
    _eventHandler.handleEvent(event);
    
    // 处理会话更新事件
    if (event.hasConversationUpdate()) {
      _onConversationUpdate(event.conversationUpdate);
    }
    
    // 处理未读数更新事件
    if (event.hasUnreadUpdate()) {
      _onUnreadCountUpdate(event.unreadUpdate);
    }
  }

  /// 处理会话更新通知
  void _onConversationUpdate(pb.ConversationUpdateEvent update) {
    final index = state.conversations.indexWhere((c) => c.id == update.conversationId);
    if (index == -1) {
      // 会话不在列表中，可能是新会话，刷新列表
      refresh();
      return;
    }

    final conversations = List<Conversation>.from(state.conversations);
    final oldUnread = conversations[index].unreadCount;
    
    // 解析 lastMessage（如果有）
    Message? newLastMessage;
    if (update.hasLastMessage()) {
      newLastMessage = _protoMessageToEntity(update.lastMessage);
    }
    
    // 如果当前会话是活跃的（用户正在查看），未读数保持为 0
    final newUnreadCount = update.conversationId == _activeConversationId 
        ? 0 
        : update.unreadCount.toInt();
    
    final updatedConv = conversations[index].copyWith(
      unreadCount: newUnreadCount,
      lastMessage: newLastMessage ?? conversations[index].lastMessage,
    );

    // 移除旧位置，插入到最前面（最新消息的会话排在前面）
    conversations.removeAt(index);
    conversations.insert(0, updatedConv);

    // 更新总未读数
    final delta = newUnreadCount - oldUnread;
    final newTotalUnread = (state.totalUnreadCount + delta).clamp(0, double.infinity).toInt();
    
    state = state.copyWith(
      conversations: conversations,
      totalUnreadCount: newTotalUnread,
    );
  }

  /// 处理未读数更新
  void _onUnreadCountUpdate(pb.UnreadCountUpdateEvent update) {
    // 如果是总未读数更新
    if (update.conversationId.isEmpty) {
      state = state.copyWith(totalUnreadCount: update.count.toInt());
      return;
    }
    
    // 单个会话的未读数更新
    final index = state.conversations.indexWhere((c) => c.id == update.conversationId);
    if (index == -1) return;
    
    final conversations = List<Conversation>.from(state.conversations);
    conversations[index] = conversations[index].copyWith(unreadCount: update.count.toInt());
    _updateTotalUnreadCount(conversations);
  }

  /// 计算并更新总未读数
  void _updateTotalUnreadCount(List<Conversation> conversations, {int extraDelta = 0}) {
    final listUnread = conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
    state = state.copyWith(
      conversations: conversations,
      totalUnreadCount: listUnread + extraDelta,
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
      (failure) {},
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

  /// 标记会话为活跃（用户进入聊天）
  void enterConversation(String conversationId) {
    _activeConversationId = conversationId;
    clearUnreadCount(conversationId);
  }

  /// 标记会话为非活跃（用户离开聊天）
  void leaveConversation() {
    _activeConversationId = null;
  }

  /// Proto Message 转 Entity
  Message _protoMessageToEntity(pb.Message msg) {
    return MessageModel(
      id: msg.id,
      conversationId: msg.conversationId,
      senderId: msg.senderId,
      content: msg.content,
      messageType: _stringToMessageType(msg.messageType),
      createdAt: msg.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(msg.createdAt.seconds.toInt() * 1000)
          : DateTime.now(),
      readAt: msg.hasReadAt()
          ? DateTime.fromMillisecondsSinceEpoch(msg.readAt.seconds.toInt() * 1000)
          : null,
    );
  }

  MessageType _stringToMessageType(String type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'file': return MessageType.file;
      case 'video': return MessageType.video;
      case 'link': return MessageType.link;
      case 'system': return MessageType.system;
      default: return MessageType.text;
    }
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
  final bool hasNewMessages;
  final bool hasMoreMessages;

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
  late UnifiedGrpcClient _grpcClient;
  
  StreamSubscription<pb.ServerEvent>? _serverEventSubscription;
  String? _currentConversationId;

  @override
  ChatRoomState build() {
    _repository = getIt<ChatRepository>();
    _grpcClient = getIt<UnifiedGrpcClient>();
    
    final authState = ref.watch(authProvider);
    
    // 监听 gRPC 双向流的服务端事件
    _serverEventSubscription = _grpcClient.chatStream.serverEvents.listen(_handleServerEvent);
    
    // 清理订阅
    ref.onDispose(() {
      _serverEventSubscription?.cancel();
      if (_currentConversationId != null) {
        _grpcClient.chatStream.unsubscribe(_currentConversationId!);
        // 注意：不能在 onDispose 中使用 ref，直接调用 leaveConversation
        // 由于 provider 已经被 dispose，这里不再通知 conversationsProvider
      }
    });
    
    return ChatRoomState(currentUserId: authState.user?.id);
  }

  /// 处理服务端事件
  void _handleServerEvent(pb.ServerEvent event) {
    // 处理新消息
    if (event.hasNewMessage()) {
      _onMessageReceived(event.newMessage);
    }
    
    // 处理消息已读
    if (event.hasMessageRead()) {
      _onMessagesRead(event.messageRead);
    }
    
    // 处理错误
    if (event.hasError()) {
      _onStreamError(event.error);
    }
  }

  /// 处理接收到的实时消息
  void _onMessageReceived(pb.NewMessageEvent event) {
    final message = _protoMessageToEntity(event.message);
    
    // 只处理当前会话的消息
    if (message.conversationId != _currentConversationId) return;

    // 检查消息是否已存在（防止重复）
    final exists = state.messages.any((m) => m.id == message.id);
    if (exists) return;

    // 不添加自己发送的消息（已通过乐观更新添加）
    if (message.senderId == state.currentUserId) return;

    state = state.copyWith(
      messages: [message, ...state.messages],
      hasNewMessages: true,
    );

    // 如果用户当前在聊天室中，收到消息应立即标记为已读
    if (_currentConversationId != null) {
      _repository.markAsRead(_currentConversationId!);
      ref.read(conversationsProvider.notifier).clearUnreadCount(_currentConversationId!);
    }
  }

  /// 处理消息已读通知
  void _onMessagesRead(pb.MessageReadEvent event) {
    // 只处理当前会话的已读通知
    if (event.conversationId != _currentConversationId) return;
    
    // 只处理对方读取我发送的消息
    if (event.readerId == state.currentUserId) return;

    // 更新消息的已读状态
    final updatedMessages = state.messages.map((m) {
      if (m.id == event.messageId && m.senderId == state.currentUserId) {
        return m.copyWithRead();
      }
      return m;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  /// 处理 gRPC 流错误
  void _onStreamError(pb.ErrorEvent error) {
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
      _grpcClient.chatStream.unsubscribe(_currentConversationId!);
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
            _grpcClient.chatStream.subscribe(conversationId);
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
          state = state.copyWith(
            status: ChatRoomStatus.loaded,
            hasMoreMessages: false,
          );
        } else {
          final existingIds = state.messages.map((m) => m.id).toSet();
          final newMessages = messages.where((m) => !existingIds.contains(m.id)).toList();
          
          state = state.copyWith(
            status: ChatRoomStatus.loaded,
            messages: [...state.messages, ...newMessages],
            hasMoreMessages: messages.length >= 50,
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

  /// Proto Message 转 Entity
  Message _protoMessageToEntity(pb.Message msg) {
    return MessageModel(
      id: msg.id,
      conversationId: msg.conversationId,
      senderId: msg.senderId,
      content: msg.content,
      messageType: _stringToMessageType(msg.messageType),
      createdAt: msg.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(msg.createdAt.seconds.toInt() * 1000)
          : DateTime.now(),
      readAt: msg.hasReadAt()
          ? DateTime.fromMillisecondsSinceEpoch(msg.readAt.seconds.toInt() * 1000)
          : null,
    );
  }

  MessageType _stringToMessageType(String type) {
    switch (type) {
      case 'image': return MessageType.image;
      case 'file': return MessageType.file;
      case 'video': return MessageType.video;
      case 'link': return MessageType.link;
      case 'system': return MessageType.system;
      default: return MessageType.text;
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
