import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/shared/theme/theme.dart';
import 'package:lesser/features/settings/presentation/providers/settings_provider.dart';

/// 设置页面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 账户设置
              _buildAccountSection(context),
              const SizedBox(height: AppSpacing.lg),

              // 通知设置
              _buildNotificationSection(context, ref),
              const SizedBox(height: AppSpacing.lg),

              // 关于
              _buildAboutSection(context),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '账户'),
        Container(
          color: AppColors.card,
          child: Column(
            children: [
              _buildSettingTile(
                context,
                title: '编辑资料',
                icon: Icons.person_outline,
                onTap: () {
                  // TODO: Navigate to edit profile
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                title: '修改密码',
                icon: Icons.lock_outline,
                onTap: () {
                  // TODO: Navigate to change password
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                title: '隐私设置',
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  // TODO: Navigate to privacy settings
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '通知'),
        Container(
          color: AppColors.card,
          child: settingsAsync.when(
            data: (settings) => Column(
              children: [
                SwitchListTile(
                  title: Text(
                    '推送通知',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    '接收新消息和互动通知',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(userSettingsProvider.notifier)
                        .setNotificationsEnabled(value);
                  },
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('加载设置失败'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, '关于'),
        Container(
          color: AppColors.card,
          child: Column(
            children: [
              _buildSettingTile(
                context,
                title: '版本',
                icon: Icons.info_outline,
                trailing: Text(
                  '1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                title: '用户协议',
                icon: Icons.description_outlined,
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                title: '隐私政策',
                icon: Icons.policy_outlined,
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                title: '清除缓存',
                icon: Icons.cleaning_services_outlined,
                onTap: () {
                  _showClearCacheDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.destructive : AppColors.mutedForeground,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDestructive ? AppColors.destructive : AppColors.foreground,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right,
                  color: AppColors.mutedForeground,
                )
              : null),
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

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
