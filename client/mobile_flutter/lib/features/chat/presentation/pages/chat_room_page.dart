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
  bool _isAtBottom = true;

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
    // 加载更多历史消息
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(chatRoomProvider.notifier).loadMoreMessages();
    }
    
    // 检测是否在底部（reverse: true 时，底部是 pixels == 0）
    final atBottom = _scrollController.position.pixels < 50;
    if (atBottom != _isAtBottom) {
      setState(() {
        _isAtBottom = atBottom;
      });
      if (atBottom) {
        ref.read(chatRoomProvider.notifier).clearNewMessagesFlag();
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    ref.read(chatRoomProvider.notifier).clearNewMessagesFlag();
  }

  void _handleSend(String content) {
    ref.read(chatRoomProvider.notifier).sendMessage(content);
    // 发送消息后滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
      floatingActionButton: (!_isAtBottom || chatRoomState.hasNewMessages)
          ? _buildScrollToBottomButton(chatRoomState.hasNewMessages)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildScrollToBottomButton(bool hasNewMessages) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: FloatingActionButton.small(
        onPressed: _scrollToBottom,
        backgroundColor: hasNewMessages ? AppColors.primary : AppColors.surfaceLight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard_arrow_down,
              color: hasNewMessages ? Colors.white : AppColors.textPrimaryLight,
            ),
            if (hasNewMessages)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
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
