import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
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
            onPressed: () {
              // Create new conversation
            },
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
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(conversationsState.errorMessage ?? 'An error occurred'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(conversationsProvider.notifier).loadConversations(),
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
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 16),
                const Text('No conversations yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Start new conversation
                  },
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
              return _ConversationItem(
                conversation: conversation,
                onTap: () {
                  context.push(
                    RouteConstants.chatRoom.replaceFirst(':id', conversation.id),
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
    this.onTap,
  });

  final Conversation conversation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final otherMember = conversation.members.isNotEmpty
        ? conversation.members.first
        : null;

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
                      conversation.name?.isNotEmpty == true
                          ? conversation.name![0].toUpperCase()
                          : otherMember?.username[0].toUpperCase() ?? '?',
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
                          conversation.name ??
                              otherMember?.displayName ??
                              otherMember?.username ??
                              'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessage != null)
                        Text(
                          conversation.lastMessage!.createdAt.timeAgo,
                          style: TextStyle(
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
                          conversation.lastMessage?.content ?? 'No messages yet',
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
                            color: AppColors.primary,
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
