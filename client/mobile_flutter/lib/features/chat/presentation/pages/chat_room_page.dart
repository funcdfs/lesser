import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/conversation.dart';
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
  bool _showScrollToBottom = false;

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
    // 加载更多历史消息（只在有更多消息且不在加载中时触发）
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        ref.read(chatRoomProvider).hasMoreMessages &&
        ref.read(chatRoomProvider).status != ChatRoomStatus.loadingMore) {
      ref.read(chatRoomProvider.notifier).loadMoreMessages();
    }
    
    // 检测是否需要显示回到底部按钮（reverse: true 时，底部是 pixels == 0）
    // 只有滚动超过一定距离时才显示按钮
    final scrolledDistance = _scrollController.position.pixels;
    final shouldShow = scrolledDistance > 300;
    
    if (shouldShow != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = shouldShow;
      });
    }
    
    // 在底部时清除新消息标记
    if (scrolledDistance < 50) {
      ref.read(chatRoomProvider.notifier).clearNewMessagesFlag();
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

  /// 获取聊天标题
  String _getChatTitle(Conversation? conversation) {
    if (conversation == null) return 'Chat';
    
    // 群聊显示群名
    if (conversation.type == ConversationType.group) {
      if (conversation.name?.isNotEmpty == true) {
        return conversation.name!;
      }
      return '群组 (${conversation.members.length})';
    }
    
    // 私聊显示对方名称
    final currentUserId = ref.read(authProvider).user?.id;
    final otherMember = _getOtherMember(conversation, currentUserId);
    if (otherMember != null) {
      if (otherMember.displayName?.isNotEmpty == true) {
        return otherMember.displayName!;
      }
      if (otherMember.username.isNotEmpty) {
        return otherMember.username;
      }
    }
    
    if (conversation.name?.isNotEmpty == true) {
      return conversation.name!;
    }
    
    return '未知用户';
  }

  /// 获取对方用户（私聊）
  User? _getOtherMember(Conversation conversation, String? currentUserId) {
    if (conversation.type != ConversationType.private) return null;
    if (conversation.members.isEmpty) return null;
    
    // 优先寻找非当前用户的成员
    final others = conversation.members.where((m) => m.id != currentUserId).toList();
    if (others.isNotEmpty) {
      return others.first;
    }
    
    // 如果只有一个人（或者是自聊），就返回第一个
    return conversation.members.first;
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomState = ref.watch(chatRoomProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildAppBarTitle(chatRoomState, isDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show conversation options
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildMessages(chatRoomState)),
              ChatInput(
                onSend: _handleSend,
                isLoading: chatRoomState.status == ChatRoomStatus.sending,
              ),
            ],
          ),
          // 滚动到底部按钮 - 放在 Stack 中以便精确定位
          if (_showScrollToBottom || chatRoomState.hasNewMessages)
            Positioned(
              right: 16,
              bottom: 80, // 在输入框上方
              child: _buildScrollToBottomButton(chatRoomState.hasNewMessages, isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(ChatRoomState chatRoomState, bool isDark) {
    final conversation = chatRoomState.conversation;
    final currentUserId = ref.read(authProvider).user?.id;
    final otherMember = conversation != null 
        ? _getOtherMember(conversation, currentUserId) 
        : null;

    return Row(
      children: [
        if (conversation != null) ...[
          UserAvatar(
            imageUrl: conversation.type == ConversationType.group 
                ? null 
                : otherMember?.avatarUrl,
            name: _getChatTitle(conversation),
            size: 36,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getChatTitle(conversation),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (conversation?.type == ConversationType.group)
                Text(
                  '${conversation!.members.length} 位成员',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollToBottomButton(bool hasNewMessages, bool isDark) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _scrollToBottom,
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasNewMessages 
                  ? AppColors.primary 
                  : (isDark ? AppColors.surfaceDark : Colors.white),
              shape: BoxShape.circle,
              border: hasNewMessages 
                  ? null 
                  : Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.5,
                    ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_down,
                  color: hasNewMessages 
                      ? Colors.white 
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  size: 24,
                ),
                if (hasNewMessages)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  chatRoomState.errorMessage ?? '加载失败',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => ref
                      .read(chatRoomProvider.notifier)
                      .loadConversation(widget.conversationId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        );
      case ChatRoomStatus.loaded:
      case ChatRoomStatus.sending:
      case ChatRoomStatus.loadingMore:
        if (chatRoomState.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '还没有消息',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '发送第一条消息开始聊天吧',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: chatRoomState.messages.length + (chatRoomState.status == ChatRoomStatus.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // 加载更多指示器
            if (chatRoomState.status == ChatRoomStatus.loadingMore && 
                index == chatRoomState.messages.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            
            final message = chatRoomState.messages[index];
            final isMe = message.senderId == chatRoomState.currentUserId;
            final isSending = message.id.startsWith('temp_');
            
            // 检查是否需要显示时间分隔
            final showTimeDivider = _shouldShowTimeDivider(
              chatRoomState.messages, 
              index,
            );
            
            return Column(
              children: [
                MessageBubble(
                  message: message,
                  isMe: isMe,
                  isSending: isSending,
                ),
                if (showTimeDivider)
                  _buildTimeDivider(message.createdAt),
              ],
            );
          },
        );
    }
  }

  /// 判断是否需要显示时间分隔线
  bool _shouldShowTimeDivider(List messages, int index) {
    if (index >= messages.length - 1) return true; // 最早的消息显示时间
    
    final currentMsg = messages[index];
    final nextMsg = messages[index + 1]; // reverse 列表中，index+1 是更早的消息
    
    final diff = currentMsg.createdAt.difference(nextMsg.createdAt);
    return diff.inMinutes.abs() > 5; // 超过 5 分钟显示时间
  }

  Widget _buildTimeDivider(DateTime time) {
    final now = DateTime.now();
    final isToday = time.year == now.year && 
                    time.month == now.month && 
                    time.day == now.day;
    
    String timeText;
    if (isToday) {
      timeText = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      timeText = '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        timeText,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
