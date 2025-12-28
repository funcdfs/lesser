import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/features/chat/presentation/widgets/notify.dart';
import 'package:lesser/features/chat/presentation/widgets/chat_item.dart';
import 'package:lesser/features/chat/presentation/widgets/section_header.dart';
import 'package:lesser/features/chat/presentation/widgets/user_tab_section.dart';
import 'package:lesser/features/chat/presentation/widgets/user_avatar_row.dart';
import 'package:lesser/features/chat/presentation/widgets/unread_dot.dart';
import 'package:lesser/features/chat/presentation/widgets/clear_zone_overlay.dart';
import 'package:lesser/shared/widgets/app_button.dart';
import 'package:lesser/shared/widgets/app_cell.dart';
import '../../../../shared/theme/theme.dart';
import '../providers/chat_provider.dart';
import '../providers/connection_provider.dart';
import '../../domain/models/connection_state.dart';
import '../../domain/models/conversation.dart';
import '../../../../shared/utils/time_formatter.dart';

/// 会话组件的大框架
/// 
/// 页面结构：NotificationBar → SectionHeader → ChatList → UserTabSection → QuickActionCells
/// 使用 CustomScrollView 实现整体滚动
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  
  /// 清除区域覆盖层入口
  OverlayEntry? _clearZoneOverlay;
  
  /// 是否在清除区域
  bool _isInClearZone = false;

  // 模拟好友数据
  final List<UserItem> _friends = const [
    UserItem(
      id: '1',
      name: '小明',
      avatarUrl: 'https://picsum.photos/seed/user1/200',
      isOnline: true,
    ),
    UserItem(
      id: '2',
      name: '小红',
      avatarUrl: 'https://picsum.photos/seed/user2/200',
      isOnline: false,
    ),
    UserItem(
      id: '3',
      name: '小李',
      avatarUrl: 'https://picsum.photos/seed/user3/200',
      isOnline: true,
    ),
    UserItem(
      id: '4',
      name: '小王',
      avatarUrl: 'https://picsum.photos/seed/user4/200',
      isOnline: false,
    ),
    UserItem(
      id: '5',
      name: '小张',
      avatarUrl: 'https://picsum.photos/seed/user5/200',
      isOnline: true,
    ),
  ];

  // 模拟粉丝数据
  final List<UserItem> _followers = const [
    UserItem(
      id: '6',
      name: '粉丝1',
      avatarUrl: 'https://picsum.photos/seed/follower1/200',
      isOnline: false,
    ),
    UserItem(
      id: '7',
      name: '粉丝2',
      avatarUrl: 'https://picsum.photos/seed/follower2/200',
      isOnline: true,
    ),
    UserItem(
      id: '8',
      name: '粉丝3',
      avatarUrl: 'https://picsum.photos/seed/follower3/200',
      isOnline: false,
    ),
  ];

  // 模拟关注数据
  final List<UserItem> _following = const [
    UserItem(
      id: '9',
      name: '关注1',
      avatarUrl: 'https://picsum.photos/seed/following1/200',
      isOnline: true,
    ),
    UserItem(
      id: '10',
      name: '关注2',
      avatarUrl: 'https://picsum.photos/seed/following2/200',
      isOnline: false,
    ),
  ];

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
    _removeClearZoneOverlay();
    super.dispose();
  }
  
  /// 显示清除区域覆盖层
  void _showClearZoneOverlay() {
    _removeClearZoneOverlay();
    _clearZoneOverlay = OverlayEntry(
      builder: (context) => ClearZoneOverlay(isActive: _isInClearZone),
    );
    Overlay.of(context).insert(_clearZoneOverlay!);
  }
  
  /// 移除清除区域覆盖层
  void _removeClearZoneOverlay() {
    _clearZoneOverlay?.remove();
    _clearZoneOverlay = null;
  }
  
  /// 更新清除区域状态
  void _updateClearZoneState(bool isInClearZone) {
    if (_isInClearZone != isInClearZone) {
      _isInClearZone = isInClearZone;
      _clearZoneOverlay?.markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // 简化顶部设计：移除标题，只保留连接状态指示器
        title: Row(
          children: [
            _buildConnectionIndicator(connectionState),
          ],
        ),
        actions: [
          // 显示总未读数
          _buildUnreadBadge(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(conversationsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            // 1. NotificationBar - 通知分类栏
            const SliverToBoxAdapter(
              child: NotificationBar(),
            ),
            
            // 2. SectionHeader - "最近聊天"
            const SliverToBoxAdapter(
              child: SectionHeader(title: '最近聊天'),
            ),
            
            // 3. ChatList - 聊天列表
            SliverToBoxAdapter(
              child: _buildChatList(),
            ),
            
            // 4. UserTabSection - 好友/粉丝/关注切换
            SliverToBoxAdapter(
              child: _buildUserTabSection(),
            ),
            
            // 5. QuickActionCells - 快捷操作
            SliverToBoxAdapter(
              child: _buildQuickActionCells(),
            ),
            
            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
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

  /// 构建未读消息圆点
  Widget _buildUnreadBadge() {
    final unreadCount = ref.watch(totalUnreadCountProvider);
    final unreadConversationIds = ref.watch(unreadConversationIdsProvider);
    
    if (unreadCount == 0) {
      return const SizedBox.shrink();
    }
    
    return UnreadDot(
      unreadCount: unreadCount,
      unreadConversationIds: unreadConversationIds,
      onJumpToConversation: _handleJumpToConversation,
      onClearAllUnread: _handleClearAllUnread,
      onDragStart: _showClearZoneOverlay,
      onDragUpdate: _updateClearZoneState,
      onDragEnd: _removeClearZoneOverlay,
    );
  }
  
  /// 处理跳转到会话
  void _handleJumpToConversation(String conversationId) {
    // TODO: 实现跳转到具体会话的逻辑
    // 可以通过 ScrollController 滚动到对应位置，或者打开会话详情
    debugPrint('跳转到会话: $conversationId');
  }
  
  /// 处理清除所有未读
  void _handleClearAllUnread() {
    ref.read(conversationsProvider.notifier).clearAllUnreadCount();
  }

  /// 构建聊天列表
  Widget _buildChatList() {
    final conversationsAsync = ref.watch(conversationsProvider);
    
    return conversationsAsync.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return _buildEmptyState();
        }
        
        // 按 lastMessageTime 降序排序（最新的在前）
        final sortedConversations = List<Conversation>.from(conversations)
          ..sort((a, b) {
            final aTime = a.lastMessageTime ?? a.createdAt;
            final bTime = b.lastMessageTime ?? b.createdAt;
            return bTime.compareTo(aTime); // 降序排序
          });
        
        return Column(
          children: sortedConversations.map((conversation) {
            return _buildConversationItem(conversation);
          }).toList(),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error),
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

  /// 构建 UserTabSection 组件
  Widget _buildUserTabSection() {
    return UserTabSection(
      contentBuilder: (tabType) {
        final users = _getUsersForTab(tabType);
        return UserAvatarRow(
          users: users,
          onUserTap: (user) {
            // TODO: 跳转到用户聊天或个人页面
          },
          onViewAll: () {
            // TODO: 跳转到对应的全部列表页面
          },
        );
      },
      onTabChanged: (tabType) {
        // Tab 切换回调，可用于数据加载等
      },
    );
  }

  /// 根据 Tab 类型获取用户列表
  List<UserItem> _getUsersForTab(UserTabType tabType) {
    switch (tabType) {
      case UserTabType.friends:
        return _friends;
      case UserTabType.followers:
        return _followers;
      case UserTabType.following:
        return _following;
    }
  }

  /// 构建快捷操作单元格
  /// 
  /// 包含三个快捷操作：创建群聊、创建频道、添加好友
  Widget _buildQuickActionCells() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        AppCell(
          title: '创建群聊',
          description: '创建新的群组聊天',
          leftIcon: Icons.people_outline,
          showArrow: true,
          onTap: () {
            // TODO: 跳转到创建群聊页面
          },
        ),
        AppCell(
          title: '创建频道',
          description: '创建新的频道',
          leftIcon: Icons.tag,
          showArrow: true,
          onTap: () {
            // TODO: 跳转到创建频道页面
          },
        ),
        AppCell(
          title: '添加好友',
          description: '通过ID或二维码添加',
          leftIcon: Icons.person_add_alt_outlined,
          showArrow: true,
          onTap: () {
            // TODO: 跳转到添加好友页面
          },
        ),
      ],
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
