import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/features/chat/presentation/widgets/notify.dart';
import 'package:lesser/features/chat/presentation/widgets/network_neighbors.dart';
import 'package:lesser/features/chat/presentation/widgets/chat_item.dart';
import 'package:lesser/features/chat/presentation/widgets/section_header.dart';
import 'package:lesser/shared/widgets/app_button.dart';
import '../../../../shared/theme/theme.dart';
import '../providers/chat_provider.dart';
import '../providers/connection_provider.dart';
import '../../domain/models/connection_state.dart';
import '../../domain/models/conversation.dart';
import '../../../../shared/utils/time_formatter.dart';

/// 会话组件的大框架
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 连接 WebSocket
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(connectionStateProvider.notifier).connect();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Message',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 8),
            _buildConnectionIndicator(connectionState),
          ],
        ),
        actions: [
          // 显示总未读数
          _buildUnreadBadge(),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[const SliverToBoxAdapter(child: NotifyWidget())];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(conversationsProvider.notifier).refresh();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(child: _buildChatList()),
              const SliverToBoxAdapter(child: NetworkNeighborsWidget()),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建连接状态指示器
  Widget _buildConnectionIndicator(ChatConnectionState state) {
    Color color;
    String tooltip;
    
    switch (state) {
      case ChatConnectionState.connected:
        color = AppColors.success;
        tooltip = '已连接';
      case ChatConnectionState.connecting:
        color = AppColors.warning;
        tooltip = '连接中...';
      case ChatConnectionState.reconnecting:
        color = AppColors.warning;
        tooltip = '重新连接中...';
      case ChatConnectionState.disconnected:
        color = AppColors.error;
        tooltip = '未连接';
    }
    
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// 构建未读消息徽章
  Widget _buildUnreadBadge() {
    final unreadCount = ref.watch(totalUnreadCountProvider);
    
    if (unreadCount == 0) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.destructive,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            unreadCount > 99 ? '99+' : unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    final conversationsAsync = ref.watch(conversationsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '聊天'),
        conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return _buildEmptyState();
            }
            return Column(
              children: conversations.map((conversation) {
                return _buildConversationItem(conversation);
              }).toList(),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error),
        ),
      ],
    );
  }

  /// 构建会话项
  Widget _buildConversationItem(Conversation conversation) {
    final participant = conversation.participants.isNotEmpty
        ? conversation.participants.first
        : null;
    
    final timeString = conversation.lastMessageTime != null
        ? TimeFormatter.formatRelativeTime(conversation.lastMessageTime!)
        : '';
    
    return ChatItem(
      chatType: ChatType.private,
      icon: Icons.person_outline,
      iconColor: AppColors.success,
      title: participant?.username ?? '未知用户',
      subtitle: conversation.lastMessage ?? '暂无消息',
      time: timeString,
      unreadCount: conversation.unreadCount,
      hasAvatar: participant?.avatarUrl != null,
      avatarUrl: participant?.avatarUrl,
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.mutedForeground.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无聊天',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.mutedForeground.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '开始一段新的对话吧',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.destructive.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.mutedForeground.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            AppButton.text(
              text: '重试',
              onPressed: () {
                ref.read(conversationsProvider.notifier).refresh();
              },
            ),
          ],
        ),
      ),
    );
  }
}
