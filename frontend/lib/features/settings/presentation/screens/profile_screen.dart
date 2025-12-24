import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/shared/theme/theme.dart';
import 'package:lesser/features/auth/presentation/providers/user_provider.dart';

/// 个人资料和设置页面
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.zinc100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(),
              SizedBox(height: AppSpacing.md),
              _ServiceCard(
                icon: Icons.workspace_premium_outlined,
                title: '会员中心',
                subtitle: '开通会员，解锁更多功能',
                buttonText: '立即开通',
              ),
              SizedBox(height: AppSpacing.md),
              _ServiceCard(
                icon: Icons.palette_outlined,
                title: '个性化设置',
                subtitle: '自定义您的发布样式',
              ),
              SizedBox(height: AppSpacing.md),
              _MenuGroup(
                title: '我的发布',
                items: [
                  _MenuItem(
                    icon: Icons.article_outlined,
                    title: '我的文章',
                    subtitle: '查看和管理已发布的文章',
                  ),
                  _MenuItem(
                    icon: Icons.drafts_outlined,
                    title: '草稿箱',
                    subtitle: '8篇草稿',
                  ),
                  _MenuItem(
                    icon: Icons.favorite_border,
                    title: '我的收藏',
                    subtitle: '126个收藏',
                  ),
                  _MenuItem(
                    icon: Icons.bar_chart_outlined,
                    title: '数据统计',
                    subtitle: '查看发布数据和互动情况',
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              _MenuGroup(
                title: '通用',
                items: [
                  _MenuItem(
                    icon: Icons.feedback_outlined,
                    title: '意见反馈',
                    subtitle: '告诉我们您的建议',
                  ),
                  _MenuItem(
                    icon: Icons.support_agent_outlined,
                    title: '联系客服',
                    subtitle: '在线客服 09:00-21:00',
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// 头部：用户信息和统计
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

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
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username, style: textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'ID: ${user.id} | ${user.email}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.edit_outlined,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(context, '328', '关注'),
                _buildStatColumn(context, '1.2K', '粉丝'),
                _buildStatColumn(context, '86', '发布'),
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

/// 服务卡片，如“会员中心”
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      color: AppColors.background,
      child: Row(
        children: [
          Icon(icon, color: AppColors.foreground, size: 28),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (buttonText != null)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm - 2,
                ),
              ),
              child: Text(buttonText!),
            )
          else
            const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
        ],
      ),
    );
  }
}

/// 菜单项分组
class _MenuGroup extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
            separatorBuilder: (context, index) =>
                const Divider(height: AppSpacing.sm, color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}

/// 单个菜单项
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: AppColors.mutedForeground, size: 24),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: AppColors.mutedForeground,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
