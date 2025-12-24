import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../common/widgets/shadcn/shadcn_list_tile.dart';
import '../widgets/top_icon_item.dart';
import '../widgets/section_header.dart';
import '../widgets/chat_item.dart';

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
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            ShadcnListTile(
              leading: const Icon(
                Icons.group_add,
                color: AppColors.foreground,
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
                color: AppColors.foreground,
              ),
              title: '创建频道 (Channel)',
              onTap: () {
                Navigator.pop(context);
                // TODO: 执行创建频道逻辑
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '消息中心',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.foreground,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                // 顶部四大功能入口：喜欢、评论、收藏、粉丝
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopIconItem(
                        icon: Icons.favorite,
                        color: AppColors.mutedForeground,
                        label: '收到的喜欢',
                      ),
                      TopIconItem(
                        icon: Icons.comment,
                        color: AppColors.mutedForeground,
                        label: '评论和回复',
                      ),
                      TopIconItem(
                        icon: Icons.bookmark,
                        color: AppColors.mutedForeground,
                        label: '收藏和@',
                      ),
                      TopIconItem(
                        icon: Icons.person_add,
                        color: AppColors.mutedForeground,
                        label: '新增粉丝',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),

                // 活跃聊天会话部分
                const SectionHeader(title: '聊天'),
                ChatItem(
                  icon: Icons.group,
                  iconColor: Colors.blue,
                  title: '公共群聊',
                  subtitle: '最新消息预览...',
                  time: '10:30',
                  unreadCount: 5,
                ),
                ChatItem(
                  icon: Icons.podcasts,
                  iconColor: Colors.purple,
                  title: '订阅频道',
                  subtitle: '频道消息更新',
                  time: '昨天',
                  unreadCount: 2,
                ),
                ChatItem(
                  icon: Icons.person,
                  iconColor: Colors.green,
                  title: '私人对话',
                  subtitle: '你好啊',
                  time: '12:00',
                  unreadCount: 0,
                ),

                const SizedBox(height: AppSpacing.lg),

                // 特殊分类：网络邻居/发现
                const SectionHeader(title: '网络邻居'),
                ChatItem(
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
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
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
                        foregroundColor: AppColors.foreground,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // “创建”主按钮
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showCreateMenu,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('发起对话'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
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
