import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';
import '../widgets/shadcn/shadcn_list_tile.dart';
import '../widgets/shadcn/shadcn_icon_container.dart';
import '../widgets/shadcn/shadcn_chip.dart';

/// 消息列表/聊天中心屏幕
///
/// 该组件实现了即时通讯的核心入口：
/// 1. 顶部提供分类导航（收到的喜欢、评论回复、收藏@、新增粉丝）。
/// 2. 中间部分展示活跃聊天列表（群组、频道、私聊）。
/// 3. 底部展示特殊功能入口（发现周围的朋友）以及快捷操作按钮（我的互关、创建群聊/频道）。
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// 弹出创建菜单（支持创建群组或频道）
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
              title: '创建群组 (Group)',
              onTap: () {
                Navigator.pop(context);
                // TODO: 执行创建群组逻辑
              },
            ),
            ShadcnListTile(
              leading: const Icon(
                Icons.podcasts,
                color: ShadcnColors.foreground,
              ),
              title: '创建频道 (Channel)',
              onTap: () {
                Navigator.pop(context);
                // TODO: 执行创建频道逻辑
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
          '消息中心',
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
                // 顶部四大功能入口：喜欢、评论、收藏、粉丝
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

                // 活跃聊天会话部分
                const _SectionHeader(title: '聊天'),
                _ChatItem(
                  icon: Icons.group,
                  iconColor: Colors.blue,
                  title: '公共群聊',
                  subtitle: '最新消息预览...',
                  time: '10:30',
                  unreadCount: 5,
                ),
                _ChatItem(
                  icon: Icons.podcasts,
                  iconColor: Colors.purple,
                  title: '订阅频道',
                  subtitle: '频道消息更新',
                  time: '昨天',
                  unreadCount: 2,
                ),
                _ChatItem(
                  icon: Icons.person,
                  iconColor: Colors.green,
                  title: '私人对话',
                  subtitle: '你好啊',
                  time: '12:00',
                  unreadCount: 0,
                ),

                const SizedBox(height: ShadcnSpacing.lg),

                // 特殊分类：网络邻居/发现
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

          // 底部悬浮操作栏
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
                  // “我的互关”按钮
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
                  // “创建”主按钮
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showCreateMenu,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('发起对话'),
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

/// 顶部四大分类图标项
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
          width: 64, // 限制宽度使文字折行
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

/// 列表区块标题（如：聊天、网络邻居）
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
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ShadcnColors.mutedForeground,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 单个聊天会话/功能项样式
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
      leading: ShadcnIconContainer(
        icon: icon,
        iconColor: ShadcnColors.mutedForeground,
        size: 48,
      ),
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
        // TODO: 跳转至聊天详情页
      },
    );
  }
}
