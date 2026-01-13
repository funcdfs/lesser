// 滚动按钮组件
//
// 评论页内的置顶/置底按钮 UI 组件
// 控制器逻辑在 logic/scroll_controller.dart
//
// 设计原则：
// - 纯 UI 组件，不包含业务逻辑
// - 通过 CommentScrollController 获取状态和执行操作

import 'package:flutter/material.dart';
import '../../ui/effects/tap_scale.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/unread_badge.dart';
import '../logic/scroll_controller.dart';

// ============================================================================
// 常量定义
// ============================================================================

/// 按钮视觉参数
const _kButtonSize = 36.0;
const _kButtonRadius = 18.0;
const _kIconSize = 20.0;
const _kButtonSpacing = 8.0;
const _kDisabledOpacity = 0.35;
const _kShadowBlur = 8.0;
const _kShadowOpacity = 0.08;
const _kBadgeOffset = -6.0;

// ============================================================================
// ScrollButtons - 滚动按钮组件
// ============================================================================

/// 滚动按钮组
class ScrollButtons extends StatelessWidget {
  const ScrollButtons({
    super.key,
    required this.controller,
    this.showTop = true,
    this.showBottom = true,
  });

  final CommentScrollController controller;
  final bool showTop;
  final bool showBottom;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isVisible) return const SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上按钮 - 跳转到顶部
            if (showTop && controller.canJumpToTop)
              _ScrollButton(
                icon: Icons.keyboard_arrow_up_rounded,
                disabled: false,
                onTap: () => controller.jumpToTop(context),
                colors: colors,
              ),
            if (showTop &&
                showBottom &&
                controller.canJumpToTop &&
                controller.canJumpToBottom)
              const SizedBox(height: _kButtonSpacing),
            // 下按钮 - 跳转到底部
            if (showBottom && controller.canJumpToBottom)
              _ScrollButton(
                icon: Icons.keyboard_arrow_down_rounded,
                disabled: false,
                badgeCount: controller.unreadCount,
                onTap: () => controller.jumpToBottom(context),
                colors: colors,
              ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// 私有组件
// ============================================================================

/// 单个滚动按钮
class _ScrollButton extends StatelessWidget {
  const _ScrollButton({
    required this.icon,
    required this.disabled,
    required this.onTap,
    required this.colors,
    this.badgeCount = 0,
  });

  final IconData icon;
  final bool disabled;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final hasBadge = badgeCount > 0;
    final clickable = !disabled || hasBadge;

    // 使用 DecoratedBox 替代 Container，性能更优
    final buttonContent = Opacity(
      opacity: disabled && !hasBadge ? _kDisabledOpacity : 1.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(_kButtonRadius),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: _kShadowOpacity),
                  blurRadius: _kShadowBlur,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: _kButtonSize,
              height: _kButtonSize,
              child: Icon(
                icon,
                size: _kIconSize,
                color: disabled ? colors.textDisabled : colors.textSecondary,
              ),
            ),
          ),
          if (hasBadge)
            Positioned(
              top: _kBadgeOffset,
              right: _kBadgeOffset,
              child: UnreadBadge(count: badgeCount),
            ),
        ],
      ),
    );

    if (clickable) {
      return TapScale(onTap: onTap, child: buttonContent);
    }
    return buttonContent;
  }
}
