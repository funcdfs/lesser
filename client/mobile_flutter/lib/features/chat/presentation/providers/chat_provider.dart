import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Conversations state
enum ConversationsStatus { initial, loading, loaded, error }

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

/// Conversations notifier
class ConversationsNotifier extends StateNotifier<ConversationsState> {
  ConversationsNotifier({
    required ChatRepository repository,
  })  : _repository = repository,
        super(const ConversationsState());

  final ChatRepository _repository;

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
}

/// Chat room state
enum ChatRoomStatus { initial, loading, loaded, error, sending }

class ChatRoomState {
  const ChatRoomState({
    this.status = ChatRoomStatus.initial,
    this.conversation,
    this.messages = const [],
    this.errorMessage,
  });

  final ChatRoomStatus status;
  final Conversation? conversation;
  final List<Message> messages;
  final String? errorMessage;

  ChatRoomState copyWith({
    ChatRoomStatus? status,
    Conversation? conversation,
    List<Message>? messages,
    String? errorMessage,
  }) {
    return ChatRoomState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}

/// Chat room notifier
class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  ChatRoomNotifier({
    required ChatRepository repository,
  })  : _repository = repository,
        super(const ChatRoomState());

  final ChatRepository _repository;

  Future<void> loadConversation(String conversationId) async {
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
          (messages) => state = state.copyWith(
            status: ChatRoomStatus.loaded,
            conversation: conversation,
            messages: messages,
          ),
        );
      },
    );
  }

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
}

/// Conversations provider
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final repository = getIt<ChatRepository>();
  return ConversationsNotifier(repository: repository);
});

/// Chat room provider
final chatRoomProvider =
    StateNotifierProvider<ChatRoomNotifier, ChatRoomState>((ref) {
  final repository = getIt<ChatRepository>();
  return ChatRoomNotifier(repository: repository);
});
