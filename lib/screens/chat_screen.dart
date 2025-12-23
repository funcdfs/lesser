import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';
import '../widgets/shadcn/shadcn_list_tile.dart';
import '../widgets/shadcn/shadcn_icon_container.dart';
// Assuming this exists or will use standard buttons styled
import '../widgets/shadcn/shadcn_chip.dart'; // For badges

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ShadcnColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ShadcnRadius.xl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: ShadcnSpacing.sm),
            ShadcnListTile(
              leading: const Icon(
                Icons.group_add,
                color: ShadcnColors.foreground,
              ),
              title: '创建 Group',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to create group
              },
            ),
            ShadcnListTile(
              leading: const Icon(
                Icons.podcasts,
                color: ShadcnColors.foreground,
              ),
              title: '创建 Channel',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to create channel
              },
            ),
            const SizedBox(height: ShadcnSpacing.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadcnColors.background,
      appBar: AppBar(
        title: const Text(
          'Message',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ShadcnColors.foreground,
          ),
        ),
        centerTitle: false,
        backgroundColor: ShadcnColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: ShadcnSpacing.md),
              children: [
                // Top Navigation Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShadcnSpacing.md,
                    vertical: ShadcnSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopIconItem(
                        icon: Icons.favorite,
                        color: ShadcnColors.mutedForeground,
                        label: '收到的喜欢',
                      ),
                      _TopIconItem(
                        icon: Icons.comment,
                        color: ShadcnColors.mutedForeground,
                        label: '评论和回复',
                      ),
                      _TopIconItem(
                        icon: Icons.bookmark,
                        color: ShadcnColors.mutedForeground,
                        label: '收藏和@',
                      ),
                      _TopIconItem(
                        icon: Icons.person_add,
                        color: ShadcnColors.mutedForeground,
                        label: '新增粉丝',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: ShadcnSpacing.md),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: ShadcnColors.border,
                ),

                // Chat items section
                const _SectionHeader(title: '聊天'),
                _ChatItem(
                  icon: Icons.group,
                  iconColor: Colors.blue,
                  title: 'Group Chat',
                  subtitle: '最新消息预览...',
                  time: '10:30',
                  unreadCount: 5,
                ),
                _ChatItem(
                  icon: Icons.podcasts,
                  iconColor: Colors.purple,
                  title: 'Channel',
                  subtitle: '频道消息更新',
                  time: '昨天',
                  unreadCount: 2,
                ),
                _ChatItem(
                  icon: Icons.person,
                  iconColor: Colors.green,
                  title: 'Private Chat',
                  subtitle: '你好啊',
                  time: '12:00',
                  unreadCount: 0,
                ),

                const SizedBox(height: ShadcnSpacing.lg),

                // Network neighbors section
                const _SectionHeader(title: '网络邻居'),
                _ChatItem(
                  icon: Icons.people_outline,
                  iconColor: Colors.orange,
                  title: '附近的人',
                  subtitle: '发现周围的朋友',
                  time: '',
                  unreadCount: 0,
                  showArrow: true,
                ),
              ],
            ),
          ),

          // Bottom action bar
          Container(
            decoration: const BoxDecoration(
              color: ShadcnColors.background,
              border: Border(
                top: BorderSide(color: ShadcnColors.border, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: ShadcnSpacing.lg,
              vertical: ShadcnSpacing.md,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.people, size: 18),
                      label: const Text('我的互关'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ShadcnColors.foreground,
                        side: const BorderSide(color: ShadcnColors.border),
                        padding: const EdgeInsets.symmetric(
                          vertical: ShadcnSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ShadcnRadius.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ShadcnSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showCreateMenu,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('创建'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ShadcnColors.primary,
                        foregroundColor: ShadcnColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(
                          vertical: ShadcnSpacing.md,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ShadcnRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopIconItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _TopIconItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ShadcnColors.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 64, // Constrain width to wrap text if necessary
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ShadcnColors.foreground,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShadcnSpacing.xl,
        ShadcnSpacing.sm,
        ShadcnSpacing.xl,
        ShadcnSpacing.sm,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.mutedForeground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final bool showArrow;

  const _ChatItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unreadCount,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShadcnListTile(
      padding: const EdgeInsets.symmetric(
        horizontal: ShadcnSpacing.lg,
        vertical: ShadcnSpacing.md,
      ),
      leading: ShadcnIconContainer(icon: icon, iconColor: ShadcnColors.mutedForeground, size: 48),
      title: title,
      subtitle: subtitle,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (time.isNotEmpty)
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: ShadcnColors.mutedForeground,
              ),
            ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            ShadcnBadge(
              text: unreadCount > 99 ? '99+' : unreadCount.toString(),
            ),
          ] else if (showArrow)
            const Icon(
              Icons.chevron_right,
              color: ShadcnColors.mutedForeground,
              size: 18,
            ),
        ],
      ),
      onTap: () {
        // TODO: Navigate to chat detail
      },
    );
  }
}
