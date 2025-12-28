import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/chat_websocket_service.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

/// 会话列表状态枚举
enum ConversationsStatus { initial, loading, loaded, error }

/// 会话列表状态
class ConversationsState {
  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
    this.errorMessage,
  });

  final ConversationsStatus status;
  final List<Conversation> conversations;
  final String? errorMessage;

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<Conversation>? conversations,
    String? errorMessage,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      errorMessage: errorMessage,
    );
  }
}

/// 会话列表状态管理器
class ConversationsNotifier extends StateNotifier<ConversationsState> {
  ConversationsNotifier({
    required ChatRepository repository,
  })  : _repository = repository,
        super(const ConversationsState());

  final ChatRepository _repository;

  /// 加载会话列表
  Future<void> loadConversations() async {
    state = state.copyWith(status: ConversationsStatus.loading);

    final result = await _repository.getConversations();

    result.fold(
      (failure) => state = state.copyWith(
        status: ConversationsStatus.error,
        errorMessage: failure.message,
      ),
      (conversations) => state = state.copyWith(
        status: ConversationsStatus.loaded,
        conversations: conversations,
      ),
    );
  }

  /// 刷新会话列表
  Future<void> refresh() async {
    final result = await _repository.getConversations();
    result.fold(
      (failure) => {},
      (conversations) => state = state.copyWith(
        conversations: conversations,
      ),
    );
  }
}

/// 聊天室状态枚举
enum ChatRoomStatus { initial, loading, loaded, error, sending }

/// 聊天室状态
class ChatRoomState {
  const ChatRoomState({
    this.status = ChatRoomStatus.initial,
    this.conversation,
    this.messages = const [],
    this.errorMessage,
    this.currentUserId,
  });

  final ChatRoomStatus status;
  final Conversation? conversation;
  final List<Message> messages;
  final String? errorMessage;
  final String? currentUserId;

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    String? errorMessage,
    String? currentUserId,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

/// 聊天室状态管理器
class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  ChatRoomNotifier({
    required ChatRepository repository,
    required ChatWebSocketService webSocketService,
    String? currentUserId,
  })  : _repository = repository,
        _webSocketService = webSocketService,
        super(ChatRoomState(currentUserId: currentUserId)) {
    // 如果用户已认证，连接 WebSocket
    if (currentUserId != null) {
      _webSocketService.connect(currentUserId);
    }
    // 监听实时消息
    _messageSubscription = _webSocketService.messageStream.listen(_onMessageReceived);
  }

  final ChatRepository _repository;
  final ChatWebSocketService _webSocketService;
  StreamSubscription<Message>? _messageSubscription;
  String? _currentConversationId;

  /// 处理接收到的实时消息
  void _onMessageReceived(Message message) {
    // 只处理当前会话的消息
    if (message.conversationId == _currentConversationId) {
      // 不添加自己发送的消息（已通过乐观更新添加）
      if (message.senderId != state.currentUserId) {
        state = state.copyWith(
          messages: [message, ...state.messages],
        );
      }
    }
  }

  /// 设置当前用户ID
  void setCurrentUserId(String userId) {
    state = state.copyWith(currentUserId: userId);
    _webSocketService.connect(userId);
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
          },
        );
      },
    );
  }

  /// 发送消息
  Future<void> sendMessage(String content) async {
    if (state.conversation == null) return;

    state = state.copyWith(status: ChatRoomStatus.sending);

    final result = await _repository.sendMessage(
      conversationId: state.conversation!.id,
      content: content,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ChatRoomStatus.loaded,
        errorMessage: failure.message,
      ),
      (message) => state = state.copyWith(
        status: ChatRoomStatus.loaded,
        messages: [message, ...state.messages],
      ),
    );
  }

  /// 加载更多历史消息
  Future<void> loadMoreMessages() async {
    if (state.conversation == null || state.messages.isEmpty) return;

    final currentPage = (state.messages.length / 50).ceil() + 1;
    final result = await _repository.getMessages(
      conversationId: state.conversation!.id,
      page: currentPage,
    );

    result.fold(
      (failure) => {},
      (messages) {
        if (messages.isNotEmpty) {
          state = state.copyWith(
            messages: [...state.messages, ...messages],
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    if (_currentConversationId != null) {
      _webSocketService.unsubscribeFromConversation(_currentConversationId!);
    }
    super.dispose();
  }
}

/// 会话列表 Provider
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final repository = getIt<ChatRepository>();
  return ConversationsNotifier(repository: repository);
});

/// 聊天室 Provider
final chatRoomProvider =
    StateNotifierProvider<ChatRoomNotifier, ChatRoomState>((ref) {
  final repository = getIt<ChatRepository>();
  final webSocketService = getIt<ChatWebSocketService>();
  final authState = ref.watch(authProvider);
  return ChatRoomNotifier(
    repository: repository,
    webSocketService: webSocketService,
    currentUserId: authState.user?.id,
  );
});
