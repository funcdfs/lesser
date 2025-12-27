import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/shared/theme/theme.dart';
import 'package:lesser/shared/widgets/app_button.dart';
import 'package:lesser/features/auth/presentation/providers/user_provider.dart';
import 'package:lesser/features/auth/presentation/providers/auth_provider.dart';

/// 个人资料和设置页面
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Part 1: 用户卡片
              _UserCard(),
              SizedBox(height: AppSpacing.lg),

              // Part 2: 记录与热力图
              _RecordsSection(),
              SizedBox(height: AppSpacing.lg),

              // Part 3: 文字管理
              _TextManagementSection(),
              SizedBox(height: AppSpacing.lg),

              // Part 4: 设置
              _SettingsSection(),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Part 1: 用户卡片
class _UserCard extends ConsumerWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final textTheme = Theme.of(context).textTheme;

    return userAsync.when(
      data: (user) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        color: AppColors.background,
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.secondary,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/id/1005/200/200',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: AppColors.background,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(user.username, style: textTheme.headlineSmall),
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentPurpleLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Plus会员',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.accentPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'ID: ${user.id}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '这个人很懒，什么都没写',
                        style: textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(context, '328', '关注'),
                _buildStatColumn(context, '127', '好友'),
                _buildStatColumn(context, '1.2K', '粉丝'),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text('Error loading profile: $err'),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String count, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          count,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Part 2: 记录与热力图
class _RecordsSection extends StatelessWidget {
  const _RecordsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的记录',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),

          // 记录切换
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRecordTab(
                  context,
                  'Reels记录',
                  Icons.video_collection_outlined,
                  true,
                ),
                const SizedBox(width: AppSpacing.md),
                _buildRecordTab(
                  context,
                  '文章发布记录',
                  Icons.article_outlined,
                  false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // GitHub风格热力图
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '发布热力图',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: '2023',
                      items: ['2023', '2022', '2021']
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {},
                      underline: Container(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 简化版热力图
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 53,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: 365,
                  itemBuilder: (context, index) {
                    // 随机生成热力图颜色
                    final intensity = (index % 5) + 1;
                    Color color;
                    switch (intensity) {
                      case 1:
                        return const SizedBox.shrink();
                      case 2:
                        color = AppColors.primary.withValues(alpha: 0.2 * 255);
                        break;
                      case 3:
                        color = AppColors.primary.withValues(alpha: 0.4 * 255);
                        break;
                      case 4:
                        color = AppColors.primary.withValues(alpha: 0.6 * 255);
                        break;
                      case 5:
                        color = AppColors.primary.withValues(alpha: 0.8 * 255);
                        break;
                      default:
                        color = AppColors.primary.withValues(alpha: 0.2 * 255);
                    }
                    return GestureDetector(
                      onTap: () {
                        // 显示当天的碎碎念
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: Text(
                              '2023-12-25',
                              style: TextStyle(color: AppColors.foreground),
                            ),
                            content: Text(
                              '今天发布了3条内容：\n1. 新年快乐！\n2. 学习Flutter\n3. 完成项目',
                              style: TextStyle(color: AppColors.onSurfaceVariant),
                            ),
                            actions: [
                              AppButton.text(
                                text: '关闭',
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTab(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive
                ? AppColors.primaryForeground
                : AppColors.foreground,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isActive
                  ? AppColors.primaryForeground
                  : AppColors.foreground,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Part 3: 文字管理
class _TextManagementSection extends StatelessWidget {
  const _TextManagementSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '文字管理',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),

          // 第一行：文字格式管理
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
            children: [
              _buildTextManagementItem(
                context,
                '草稿箱',
                Icons.drafts_outlined,
                '12',
              ),
              _buildTextManagementItem(
                context,
                '状态管理',
                Icons.update_outlined,
                '8',
              ),
              _buildTextManagementItem(
                context,
                '帖子管理',
                Icons.feed_outlined,
                '24',
              ),
              _buildTextManagementItem(
                context,
                '专栏管理',
                Icons.book_outlined,
                '5',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 第二行：互动记录
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
            children: [
              _buildTextManagementItem(
                context,
                '点赞记录',
                Icons.favorite_outline,
                '128',
              ),
              _buildTextManagementItem(
                context,
                '收藏夹',
                Icons.bookmark_outline,
                '36',
              ),
              _buildTextManagementItem(
                context,
                '最近浏览',
                Icons.history_outlined,
                '42',
              ),
              _buildTextManagementItem(
                context,
                '数据统计',
                Icons.bar_chart_outlined,
                '',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextManagementItem(
    BuildContext context,
    String title,
    IconData icon,
    String count,
  ) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(icon, color: AppColors.foreground),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        if (count.isNotEmpty)
          Text(
            count,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
      ],
    );
  }
}

/// Part 4: 设置
class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildSettingItem(
            context,
            '通用设置',
            Icons.settings_outlined,
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          _buildDivider(),
          _buildSettingItem(context, '切换账号', Icons.switch_account_outlined),
          _buildDivider(),
          _buildSettingItem(
            context,
            '退出登录',
            Icons.logout_outlined,
            isDestructive: true,
            onTap: () async {
              // 显示确认对话框
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text(
                    '确认退出登录',
                    style: TextStyle(color: AppColors.foreground),
                  ),
                  content: Text(
                    '确定要退出登录吗？',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  actions: [
                    AppButton.text(
                      text: '取消',
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    AppButton.danger(
                      text: '确认',
                      onPressed: () => Navigator.of(context).pop(true),
                      size: AppButtonSize.small,
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                // 调用登出
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? AppColors.destructive
            : AppColors.mutedForeground,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDestructive ? AppColors.destructive : AppColors.foreground,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.mutedForeground,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: AppColors.border,
    );
  }
}
