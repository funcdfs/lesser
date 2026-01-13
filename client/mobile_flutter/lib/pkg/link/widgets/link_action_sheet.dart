// 链接操作菜单
//
// 长按链接时显示的操作菜单，提供复制、分享等功能

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/effects/effects.dart';
import '../../ui/theme/theme.dart';
import '../link_parser.dart';
import '../link_utils.dart';
import '../models/link_model.dart';

/// 链接操作菜单
///
/// 以底部弹出菜单形式显示链接操作选项
class LinkActionSheet extends StatelessWidget {
  const LinkActionSheet({
    super.key,
    required this.url,
    this.onOpen,
    this.onCopy,
    this.onShare,
  });

  /// 链接 URL
  final String url;

  /// 打开链接回调
  final VoidCallback? onOpen;

  /// 复制链接回调
  final VoidCallback? onCopy;

  /// 分享链接回调
  final VoidCallback? onShare;

  /// 显示链接操作菜单
  static Future<LinkAction?> show(
    BuildContext context, {
    required String url,
    VoidCallback? onOpen,
    VoidCallback? onCopy,
    VoidCallback? onShare,
  }) {
    HapticFeedback.mediumImpact();

    return showModalBottomSheet<LinkAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LinkActionSheet(
        url: url,
        onOpen: onOpen,
        onCopy: onCopy,
        onShare: onShare,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final link = LinkParser.parse(url);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            _buildDragHandle(colors),
            // 链接预览
            _buildLinkPreview(colors, link),
            const SizedBox(height: 8),
            // 操作按钮
            _buildActions(context, colors),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 构建拖拽指示器
  Widget _buildDragHandle(AppColorScheme colors) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: colors.textDisabled,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 构建链接预览
  Widget _buildLinkPreview(AppColorScheme colors, LinkModel? link) {
    final icon = link != null
        ? LinkUtils.getIconForType(link.targetType)
        : Icons.link_rounded;
    final displayText = LinkUtils.getDisplayText(url);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActions(BuildContext context, AppColorScheme colors) {
    return Column(
      children: [
        // 打开链接
        _ActionItem(
          icon: Icons.open_in_new_rounded,
          label: '打开链接',
          colors: colors,
          onTap: () {
            Navigator.of(context).pop(LinkAction.open);
            onOpen?.call();
          },
        ),
        // 复制链接
        _ActionItem(
          icon: Icons.copy_rounded,
          label: '复制链接',
          colors: colors,
          onTap: () {
            Navigator.of(context).pop(LinkAction.copy);
            onCopy?.call();
          },
        ),
        // 分享链接
        if (onShare != null)
          _ActionItem(
            icon: Icons.share_rounded,
            label: '分享链接',
            colors: colors,
            onTap: () {
              Navigator.of(context).pop(LinkAction.share);
              onShare?.call();
            },
          ),
      ],
    );
  }
}

/// 操作项
class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.textSecondary),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 链接操作类型
enum LinkAction {
  /// 打开链接
  open,

  /// 复制链接
  copy,

  /// 分享链接
  share,
}
