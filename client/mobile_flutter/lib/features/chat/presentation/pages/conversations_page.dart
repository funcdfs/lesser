import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/conversation.dart';
import '../providers/chat_provider.dart';
import '../../domain/entities/message.dart';

class ConversationsPage extends ConsumerStatefulWidget {
  const ConversationsPage({super.key});

  @override
  ConsumerState<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ConsumerState<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsState = ref.watch(conversationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () => context.push(RouteConstants.newConversation),
          ),
        ],
      ),
      body: _buildBody(conversationsState, isDark),
    );
  }

  Widget _buildBody(ConversationsState conversationsState, bool isDark) {
    switch (conversationsState.status) {
      case ConversationsStatus.initial:
      case ConversationsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ConversationsStatus.error:
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
                  conversationsState.errorMessage ?? '加载失败',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => ref
                      .read(conversationsProvider.notifier)
                      .loadConversations(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        );
      case ConversationsStatus.loaded:
        if (conversationsState.conversations.isEmpty) {
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  '开始一段新对话吧',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push(RouteConstants.newConversation),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('发起对话'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(conversationsProvider.notifier).loadConversations(),
          child: ListView.builder(
            itemCount: conversationsState.conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversationsState.conversations[index];
              final currentUserId = ref.read(authProvider).user?.id;
              return _ConversationItem(
                conversation: conversation,
                currentUserId: currentUserId,
                isDark: isDark,
                onTap: () {
                  context.push(
                    RouteConstants.chatRoom.replaceFirst(
                      ':id',
                      conversation.id,
                    ),
                  );
                },
              );
            },
          ),
        );
    }
  }
}

class _ConversationItem extends StatelessWidget {
  const _ConversationItem({
    required this.conversation,
    required this.isDark,
    this.currentUserId,
    this.onTap,
  });

  final Conversation conversation;
  final String? currentUserId;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 尝试找到非当前用户的成员 (Private Chat Partner)
    User? otherMember;
    if (conversation.type == ConversationType.private) {
      if (conversation.members.isNotEmpty) {
        final others = conversation.members.where((m) => m.id != currentUserId).toList();
        if (others.isNotEmpty) {
          otherMember = others.first;
        } else {
          otherMember = conversation.members.first;
        }
      }
    }

    final displayName = _getDisplayName(otherMember);
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // 头像
              _buildAvatar(otherMember),
              const SizedBox(width: 12),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名称和时间
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.lastMessage != null)
                          Text(
                            conversation.lastMessage!.createdAt.timeAgo,
                            style: TextStyle(
                              color: hasUnread
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 最后消息和未读数
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getLastMessagePreview(),
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontSize: 14,
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              conversation.unreadCount > 99
                                  ? '99+'
                                  : conversation.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取最后消息预览
  String _getLastMessagePreview() {
    final msg = conversation.lastMessage;
    if (msg == null) return '暂无消息';

    // 如果是自己发的，加个 "我: " 前缀
    if (msg.senderId == currentUserId) {
      switch (msg.messageType) {
        case MessageType.text:
          return '我: ${msg.content}';
        case MessageType.image:
          return '我: [图片]';
        case MessageType.video:
          return '我: [视频]';
        case MessageType.file:
          return '我: [文件]';
        case MessageType.link:
          return '我: [链接]';
        case MessageType.system:
          return msg.content;
      }
    }

    switch (msg.messageType) {
      case MessageType.text:
        return msg.content;
      case MessageType.image:
        return '[图片]';
      case MessageType.video:
        return '[视频]';
      case MessageType.file:
        return '[文件]';
      case MessageType.link:
        return '[链接]';
      case MessageType.system:
        return msg.content;
    }
  }

  /// 构建头像
  Widget _buildAvatar(User? otherMember) {
    // 群聊显示群头像
    if (conversation.type == ConversationType.group) {
      return _buildGroupAvatar();
    }

    // 私聊显示对方头像
    return UserAvatar(
      imageUrl: otherMember?.avatarUrl,
      // 确保 name 不为空，否则显示问号
      name:
          otherMember?.displayName ??
          otherMember?.username ??
          _getDisplayName(otherMember),
      size: 52,
    );
  }

  /// 构建群聊头像（显示多个成员头像的组合）
  Widget _buildGroupAvatar() {
    final members = conversation.members.take(4).toList();

    if (members.isEmpty) {
      return UserAvatar(name: conversation.name ?? '群组', size: 52);
    }

    if (members.length == 1) {
      return UserAvatar(
        imageUrl: members[0].avatarUrl,
        name: members[0].displayName ?? members[0].username,
        size: 52,
      );
    }

    // 2-4 人的组合头像
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        children: [
          _buildGroupMemberAvatar(members[0], 0, members.length),
          _buildGroupMemberAvatar(members[1], 1, members.length),
          if (members.length >= 3)
            _buildGroupMemberAvatar(members[2], 2, members.length),
          if (members.length >= 4)
            _buildGroupMemberAvatar(members[3], 3, members.length),
        ],
      ),
    );
  }

  Widget _buildGroupMemberAvatar(User member, int index, int total) {
    // 根据数量和索引计算位置和大小
    // 简化版实现
    final double size = total == 2 ? 32 : 24;
    double? top, bottom, left, right;

    if (total == 2) {
      if (index == 0) {
        top = 0;
        left = 0;
      } else {
        bottom = 0;
        right = 0;
      }
    } else if (total == 3) {
      if (index == 0) {
        top = 0;
        left = 14;
      } // Top center-ish
      else if (index == 1) {
        bottom = 0;
        left = 0;
      } else {
        bottom = 0;
        right = 0;
      }
    } else {
      if (index == 0) {
        top = 0;
        left = 0;
      } else if (index == 1) {
        top = 0;
        right = 0;
      } else if (index == 2) {
        bottom = 0;
        left = 0;
      } else {
        bottom = 0;
        right = 0;
      }
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: UserAvatar(
          imageUrl: member.avatarUrl,
          name: member.displayName ?? member.username,
          size: size,
        ),
      ),
    );
  }

  /// 获取显示名称
  String _getDisplayName(User? otherMember) {
    // 群聊优先显示群名称
    if (conversation.type == ConversationType.group) {
      if (conversation.name?.isNotEmpty == true) {
        return conversation.name!;
      }
      return '群组 (${conversation.members.length})';
    }

    // 私聊显示对方名称
    if (otherMember != null) {
      if (otherMember.displayName?.isNotEmpty == true) {
        return otherMember.displayName!;
      }
      if (otherMember.username.isNotEmpty) {
        return otherMember.username;
      }
    }

    // 如果没有找到对方，尝试显示 Conversation Name
    if (conversation.name?.isNotEmpty == true) {
      return conversation.name!;
    }

    return '未知用户';
  }
}
