// 自定义弹出菜单组件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

/// 弹出菜单项数据
class PopupMenuItemData {
  const PopupMenuItemData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// 显示自定义弹出菜单
///
/// [context] 上下文
/// [anchorKey] 锚点组件的 GlobalKey，用于定位
/// [items] 菜单项列表
/// [onSelected] 选中回调
Future<void> showPopupMenu({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<PopupMenuItemData> items,
  required ValueChanged<String> onSelected,
}) async {
  final renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final overlay = Overlay.of(context);
  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _PopupMenuOverlay(
      anchorPosition: position,
      anchorSize: size,
      items: items,
      onSelected: (value) {
        entry.remove();
        onSelected(value);
      },
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

/// 弹出菜单覆盖层
class _PopupMenuOverlay extends StatefulWidget {
  const _PopupMenuOverlay({
    required this.anchorPosition,
    required this.anchorSize,
    required this.items,
    required this.onSelected,
    required this.onDismiss,
  });

  final Offset anchorPosition;
  final Size anchorSize;
  final List<PopupMenuItemData> items;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;

  @override
  State<_PopupMenuOverlay> createState() => _PopupMenuOverlayState();
}

class _PopupMenuOverlayState extends State<_PopupMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  void _onItemTap(String value) {
    HapticFeedback.lightImpact();
    _ctrl.reverse().then((_) {
      widget.onSelected(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenSize = MediaQuery.sizeOf(context);

    // 计算菜单位置（从锚点右下角弹出，向左展开）
    const menuWidth = 150.0;
    final menuX =
        widget.anchorPosition.dx + widget.anchorSize.width - menuWidth;
    final menuY = widget.anchorPosition.dy + widget.anchorSize.height + 4;

    // 确保菜单不超出屏幕
    final clampedX = menuX.clamp(8.0, screenSize.width - menuWidth - 8);
    final clampedY = menuY.clamp(8.0, screenSize.height - 200);

    return Stack(
      children: [
        // 背景遮罩（点击关闭）
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _fadeAnim,
              builder: (context, _) => Container(color: Colors.transparent),
            ),
          ),
        ),

        // 菜单内容
        Positioned(
          left: clampedX,
          top: clampedY,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnim.value,
                alignment: Alignment.topRight,
                child: Opacity(opacity: _fadeAnim.value, child: child),
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
                      color: colors.surfaceOverlay,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.items.map((item) {
                    return _PopupMenuItem(
                      icon: item.icon,
                      label: item.label,
                      onTap: () => _onItemTap(item.value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 弹出菜单项
class _PopupMenuItem extends StatefulWidget {
  const _PopupMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_PopupMenuItem> createState() => _PopupMenuItemState();
}

class _PopupMenuItemState extends State<_PopupMenuItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: _isPressed
            ? colors.textPrimary.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(widget.icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(fontSize: 15, color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
