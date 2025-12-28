import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/shared/theme/theme.dart';
import 'package:lesser/shared/widgets/app_dialog.dart';
import 'package:lesser/features/auth/presentation/providers/user_provider.dart';
import 'package:lesser/features/auth/presentation/providers/auth_provider.dart';
import 'package:lesser/features/settings/presentation/providers/theme_provider.dart';

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.accentPurpleLight,
                              AppColors.primary,
                            ],
                          ),
                          boxShadow: AppShadows.md,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundImage: NetworkImage(
                                'https://picsum.photos/id/1005/200/200',
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.accentPurple,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.star,
                                  size: 14,
                                  color: AppColors.primaryForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.username,
                                  style: textTheme.headlineMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPurpleLight,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    'Plus会员',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: AppColors.accentPurple,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'ID: ${user.id}',
                              style: textTheme.bodySmall!.copyWith(
                                color: AppColors.mutedForeground,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '这个人很懒，什么都没写',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined),
                        color: AppColors.mutedForeground,
                        iconSize: 22,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(context, '328', '关注'),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _buildStatColumn(context, '127', '好友'),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _buildStatColumn(context, '1.2K', '粉丝'),
                  ],
                ),
              ),
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
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
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

          // 记录切换标签栏
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildRecordTab(
                context,
                'Reels记录',
                Icons.video_collection_outlined,
                true,
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildRecordTab(context, '文章发布记录', Icons.article_outlined, false),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // GitHub风格的热力图
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '发布热力图',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      DropdownButton(
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
                        style: Theme.of(context).textTheme.bodySmall,
                        iconSize: 16,
                        underline: const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 热力图网格
                  SizedBox(
                    height: 120,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 53, // 53周
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ),
                      itemCount: 365, // 365天
                      itemBuilder: (context, index) {
                        // 随机生成强度值
                        final intensity = (index % 5) + 1;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: intensity == 1
                                ? AppColors.muted
                                : intensity == 2
                                ? AppColors.primary.withAlpha(80)
                                : intensity == 3
                                ? AppColors.primary.withAlpha(160)
                                : intensity == 4
                                ? AppColors.primary.withAlpha(220)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: intensity > 1 ? AppShadows.subtle : [],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      },
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

  Widget _buildRecordTab(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: isActive ? null : Border.all(color: AppColors.border, width: 1),
        boxShadow: isActive ? AppShadows.md : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive
                ? AppColors.primaryForeground
                : AppColors.foreground,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: isActive
                  ? AppColors.primaryForeground
                  : AppColors.foreground,
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

          // 第一行：内容管理
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.0,
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
          ),
          const SizedBox(height: AppSpacing.lg),

          // 第二行：互动记录
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.3,
              children: [
                _buildTextManagementItem(
                  context,
                  '点赞记录',
                  Icons.favorite_border_outlined,
                  '128',
                ),
                _buildTextManagementItem(
                  context,
                  '收藏记录',
                  Icons.bookmark_border_outlined,
                  '36',
                ),
                _buildTextManagementItem(
                  context,
                  '浏览历史',
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.subtle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (count.isNotEmpty)
                Text(
                  count,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Part 4: 设置
class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Icon(
            icon,
            color: isDestructive
                ? AppColors.destructive
                : AppColors.mutedForeground,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDestructive
                  ? AppColors.destructive
                  : AppColors.foreground,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: AppColors.mutedForeground),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: AppColors.border,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // 主题切换
          ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppColors.mutedForeground,
            ),
            title: Text(
              '深色模式',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.foreground),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              activeTrackColor: AppColors.primary,
            ),
          ),
          _buildDivider(),
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
              final shouldLogout = await AppDialog.danger(
                context: context,
                title: '确认退出登录',
                content: '确定要退出登录吗？',
                confirmText: '确认',
                cancelText: '取消',
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
}
