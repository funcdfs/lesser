import 'package:flutter/material.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../../shared/theme/theme.dart';
import '../screens/story_view_screen.dart';

/// 故事栏组件 (Stories Bar)
///
/// 展示在“关注”动态流的顶部，包含横向滚动的用户头像列表。
/// 点击头像可进入全屏故事浏览模式。
class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // 增加高度以提供更好的间距防止溢出
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: mockFollowingUsers.length + 1, // +1 用于显示“我的状态”
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            // 第一个项目通常是当前用户的“发布状态”入口
            return const _MyStoryItem();
          }
          final user = mockFollowingUsers[index - 1];
          return GestureDetector(
            onTap: () {
              // 点击跳转至全屏故事视图
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false, // 设置为非不透明，以支持透明/磨砂背景效果
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      StoryViewScreen(
                        users: mockFollowingUsers,
                        initialUserIndex: index - 1,
                      ),
                ),
              );
            },
            child: _StoryItem(
              name: user.username,
              imageUrl: null, // User model currently doesn't have avatar
              hasUnseenStory: index % 3 != 0, // 模拟未读状态
            ),
          );
        },
      ),
    );
  }
}

/// 内部私有：当前用户的“发状态”项
class _MyStoryItem extends StatelessWidget {
  const _MyStoryItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 68,
          height: 68,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 28, color: AppColors.foreground),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '发状态',
          style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
        ),
      ],
    );
  }
}

/// 内部私有：单个普通用户的故事头像项
class _StoryItem extends StatelessWidget {
  final String name;
  final String? imageUrl;

  /// 是否有未查看的故事（决定是否显示彩色圆环）
  final bool hasUnseenStory;

  const _StoryItem({
    required this.name,
    this.imageUrl,
    this.hasUnseenStory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(3), // 圆环与头像之间的间距
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 如果有未读故事，显示渐变色圆环
            gradient: hasUnseenStory
                ? const LinearGradient(
                    colors: [
                      Color(0xFFFFD600), // 黄色
                      Color(0xFFFF0169), // 品红
                      Color(0xFFD300C5), // 紫色
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  )
                : const LinearGradient(colors: [Colors.grey, Colors.grey]),
          ),
          child: Container(
            padding: const EdgeInsets.all(2), // 渐变环内部的白色隔离圈
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: Avatar(
              avatarUrl: imageUrl,
              fallbackInitials: name,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64, // 限制文本宽度
          child: Text(
            name.split(' ')[0], // 仅显示用户名的第一部分
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: hasUnseenStory ? FontWeight.w500 : FontWeight.normal,
              color: AppColors.foreground,
            ),
          ),
        ),
      ],
    );
  }
}
