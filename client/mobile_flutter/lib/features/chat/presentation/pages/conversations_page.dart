import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/conversation.dart';
import '../providers/chat_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () => context.push(RouteConstants.newConversation),
          ),
        ],
      ),
      body: _buildBody(conversationsState),
    );
  }

  Widget _buildBody(ConversationsState conversationsState) {
    switch (conversationsState.status) {
      case ConversationsStatus.initial:
      case ConversationsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ConversationsStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(conversationsState.errorMessage ?? 'An error occurred'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(conversationsProvider.notifier)
                    .loadConversations(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case ConversationsStatus.loaded:
        if (conversationsState.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 16),
                const Text('No conversations yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push(RouteConstants.newConversation),
                  child: const Text('Start a conversation'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(conversationsProvider.notifier).loadConversations(),
          child: ListView.separated(
            itemCount: conversationsState.conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversationsState.conversations[index];
              final currentUserId = ref.read(authProvider).user?.id;
              return _ConversationItem(
                conversation: conversation,
                currentUserId: currentUserId,
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
    this.currentUserId,
    this.onTap,
  });

  final Conversation conversation;
  final String? currentUserId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 对于私聊，找到对方用户（排除当前用户）
    // 对于群聊，显示群名称
    User? otherMember;
    if (conversation.members.isNotEmpty) {
      // 尝试找到非当前用户的成员
      for (final member in conversation.members) {
        if (member.id != currentUserId) {
          otherMember = member;
          break;
        }
      }
      // 如果没找到（比如只有自己），就用第一个
      otherMember ??= conversation.members.first;
    }

    // 获取显示名称的首字母，处理空字符串情况
    String getInitial() {
      // 群聊优先显示群名称
      if (conversation.type == ConversationType.group &&
          conversation.name?.isNotEmpty == true) {
        return conversation.name![0].toUpperCase();
      }
      if (otherMember?.displayName?.isNotEmpty == true) {
        return otherMember!.displayName![0].toUpperCase();
      }
      if (otherMember != null && otherMember.username.isNotEmpty) {
        return otherMember.username[0].toUpperCase();
      }
      if (conversation.name?.isNotEmpty == true) {
        return conversation.name![0].toUpperCase();
      }
      return '?';
    }

    // 获取显示名称
    String getDisplayName() {
      // 群聊优先显示群名称
      if (conversation.type == ConversationType.group &&
          conversation.name?.isNotEmpty == true) {
        return conversation.name!;
      }
      // 私聊显示对方名称
      if (otherMember?.displayName?.isNotEmpty == true) {
        return otherMember!.displayName!;
      }
      if (otherMember != null && otherMember.username.isNotEmpty) {
        return otherMember.username;
      }
      if (conversation.name?.isNotEmpty == true) {
        return conversation.name!;
      }
      return 'Unknown';
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: otherMember?.avatarUrl != null
                  ? NetworkImage(otherMember!.avatarUrl!)
                  : null,
              child: otherMember?.avatarUrl == null
                  ? Text(
                      getInitial(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          getDisplayName(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessage != null)
                        Text(
                          conversation.lastMessage!.createdAt.timeAgo,
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage?.content ??
                              'No messages yet',
                          style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
    );
  }
}
