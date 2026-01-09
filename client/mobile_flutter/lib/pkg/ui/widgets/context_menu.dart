// 通用浮动上下文菜单组件
//
// 设计原则：
// - 长按触发，在点击位置附近弹出
// - 支持快捷 emoji 反应行（可选）
// - 支持自定义菜单项
// - 自动适应屏幕边界

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../animation/animation.dart';
import '../theme/theme.dart';
import '../effects/tap_scale.dart';

/// 上下文菜单项数据
class ContextMenuItem {
  const ContextMenuItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDestructive; // 是否为危险操作（红色显示）
}

/// 显示浮动上下文菜单
///
/// [context] 上下文
/// [position] 触发位置（通常是长按位置）
/// [items] 菜单项列表
/// [quickEmojis] 快捷 emoji 列表（可选，显示在菜单顶部）
/// [onSelected] 菜单项选中回调
/// [onEmojiSelected] emoji 选中回调
/// [menuWidth] 菜单宽度
Future<void> showContextMenu({
  required BuildContext context,
  required Offset position,
  required List<ContextMenuItem> items,
  List<String>? quickEmojis,
  required ValueChanged<String> onSelected,
  ValueChanged<String>? onEmojiSelected,
  double menuWidth = 200.0,
}) async {
  HapticFeedback.mediumImpact();

  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;
  final padding = MediaQuery.of(context).padding;

  // 估算菜单高度
  final hasEmojis = quickEmojis != null && quickEmojis.isNotEmpty;
  const emojiRowHeight = 48.0;
  const dividerHeight = 0.5;
  const itemHeight = 44.0;
  final menuHeight =
      (hasEmojis ? emojiRowHeight + dividerHeight : 0.0) +
      (items.length * itemHeight);

  // 计算菜单位置
  double left = position.dx;
  if (left + menuWidth > screenSize.width - 12) {
    left = screenSize.width - menuWidth - 12;
  }
  if (left < 12) left = 12;

  double top = position.dy;
  if (top + menuHeight > screenSize.height - padding.bottom - 12) {
    top = position.dy - menuHeight;
  }
  if (top < padding.top + 12) {
    top = padding.top + 12;
  }

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _ContextMenuOverlay(
      left: left,
      top: top,
      menuWidth: menuWidth,
      items: items,
      quickEmojis: quickEmojis,
      onDismiss: () => entry.remove(),
      onSelected: (value) {
        entry.remove();
        onSelected(value);
      },
      onEmojiSelected: onEmojiSelected != null
          ? (emoji) {
              entry.remove();
              onEmojiSelected(emoji);
            }
          : null,
    ),
  );

  overlay.insert(entry);
}

/// 上下文菜单覆盖层
class _ContextMenuOverlay extends StatelessWidget {
  const _ContextMenuOverlay({
    required this.left,
    required this.top,
    required this.menuWidth,
    required this.items,
    required this.onDismiss,
    required this.onSelected,
    this.quickEmojis,
    this.onEmojiSelected,
  });

  final double left;
  final double top;
  final double menuWidth;
  final List<ContextMenuItem> items;
  final List<String>? quickEmojis;
  final VoidCallback onDismiss;
  final ValueChanged<String> onSelected;
  final ValueChanged<String>? onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasEmojis = quickEmojis != null && quickEmojis!.isNotEmpty;

    return Stack(
      children: [
        // 背景遮罩
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(color: colors.surfaceOverlay),
          ),
        ),
        // 菜单内容
        Positioned(
          left: left,
          top: top,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: PopupAnim.startScale, end: PopupAnim.endScale),
            duration: PopupAnim.duration,
            curve: PopupAnim.curve,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: value,
                  alignment: Alignment.topLeft,
                  child: child,
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: menuWidth,
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 快捷 emoji 行
                    if (hasEmojis) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: quickEmojis!
                              .map(
                                (emoji) => _EmojiButton(
                                  emoji: emoji,
                                  onTap: () => onEmojiSelected?.call(emoji),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Container(height: 0.5, color: colors.divider),
                    ],
                    // 菜单项
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isLast = index == items.length - 1;
                      return _MenuItem(
                        icon: item.icon,
                        label: item.label,
                        isDestructive: item.isDestructive,
                        isLast: isLast,
                        onTap: () => onSelected(item.value),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Emoji 按钮
class _EmojiButton extends StatelessWidget {
  const _EmojiButton({required this.emoji, this.onTap});

  final String emoji;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: onTap,
      scale: TapScales.small,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

/// 菜单项（带按压高亮效果）
class _MenuItem extends StatefulWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLast;

  @override
  State<_MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<_MenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = widget.isDestructive ? colors.error : colors.textPrimary;
    final iconColor = widget.isDestructive
        ? colors.error
        : colors.textSecondary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AnimDurations.fast,
        padding: EdgeInsets.fromLTRB(14, 11, 14, widget.isLast ? 13 : 11),
        color: _isPressed
            ? colors.textPrimary.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(widget.icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Text(widget.label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}
