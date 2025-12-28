import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  const ChatRoomPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatRoomProvider.notifier)
          .loadConversation(widget.conversationId);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(chatRoomProvider.notifier).loadMoreMessages();
    }
  }

  void _handleSend(String content) {
    ref.read(chatRoomProvider.notifier).sendMessage(content);
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomState = ref.watch(chatRoomProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chatRoomState.conversation?.name ??
              chatRoomState.conversation?.members.firstOrNull?.displayName ??
              'Chat',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show conversation info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages(chatRoomState)),
          ChatInput(
            onSend: _handleSend,
            isLoading: chatRoomState.status == ChatRoomStatus.sending,
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(ChatRoomState chatRoomState) {
    switch (chatRoomState.status) {
      case ChatRoomStatus.initial:
      case ChatRoomStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ChatRoomStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(chatRoomState.errorMessage ?? 'An error occurred'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(chatRoomProvider.notifier)
                    .loadConversation(widget.conversationId),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case ChatRoomStatus.loaded:
      case ChatRoomStatus.sending:
        if (chatRoomState.messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(height: 16),
                Text('No messages yet'),
                SizedBox(height: 8),
                Text(
                  'Start the conversation!',
                  style: TextStyle(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: chatRoomState.messages.length,
          itemBuilder: (context, index) {
            final message = chatRoomState.messages[index];
            final isMe = message.senderId == chatRoomState.currentUserId;
            return MessageBubble(message: message, isMe: isMe);
          },
        );
    }
  }
}
