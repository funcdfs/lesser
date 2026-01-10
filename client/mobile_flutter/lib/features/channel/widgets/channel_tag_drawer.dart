// 频道标签抽屉组件

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../models/channel_tag.dart';

/// 频道标签抽屉
///
/// 底部可拖拽展开/收起的标签选择器。
class ChannelTagDrawer extends StatefulWidget {
  const ChannelTagDrawer({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.onTagTap,
  });

  final List<ChannelTag> tags;
  final Set<String> selectedTags;
  final void Function(ChannelTag tag) onTagTap;

  @override
  State<ChannelTagDrawer> createState() => _ChannelTagDrawerState();
}

class _ChannelTagDrawerState extends State<ChannelTagDrawer> {
  // 使用比例而非固定值，支持屏幕尺寸动态变化
  static const double _expandedRatio = 0.5; // 展开时占屏幕 50%
  static const double _headerHeight = 56.0; // 头部固定高度

  bool _isExpanded = false;
  bool _isDragging = false;
  double _dragOffset = 0;

  double _getCollapsedHeight(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return _headerHeight + bottomPadding;
  }

  double _getExpandedHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * _expandedRatio;
  }

  double _getCurrentHeight(BuildContext context) {
    final collapsed = _getCollapsedHeight(context);
    final expanded = _getExpandedHeight(context);

    if (_isDragging) {
      final baseHeight = _isExpanded ? expanded : collapsed;
      return (baseHeight - _dragOffset).clamp(collapsed, expanded);
    }

    return _isExpanded ? expanded : collapsed;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset += details.delta.dy;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final collapsed = _getCollapsedHeight(context);
    final expanded = _getExpandedHeight(context);
    final currentHeight = _getCurrentHeight(context);
    final midPoint = (collapsed + expanded) / 2;

    setState(() {
      _isDragging = false;
      _dragOffset = 0;

      if (velocity < -500) {
        _isExpanded = true;
      } else if (velocity > 500) {
        _isExpanded = false;
      } else {
        _isExpanded = currentHeight > midPoint;
      }
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final currentHeight = _getCurrentHeight(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: _isDragging ? Duration.zero : DrawerAnim.duration,
        curve: DrawerAnim.curve,
        height: currentHeight,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 拖拽区域（整个头部都可点击/拖拽）
            GestureDetector(
              onVerticalDragUpdate: _onDragUpdate,
              onVerticalDragEnd: _onDragEnd,
              onTap: _toggleExpand,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: _buildDragHandle(colors)),
              ),
            ),
            // 标签滚动区域
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPadding + 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.tags.map((tag) {
                    final isSelected = widget.selectedTags.contains(tag.id);
                    return _TagChip(
                      tag: tag,
                      isSelected: isSelected,
                      onTap: () => widget.onTagTap(tag),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 拖拽指示条
  Widget _buildDragHandle(AppColorScheme colors) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: colors.textDisabled,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// 标签芯片
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  final ChannelTag tag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // 选中时：强调色边框 + 柔和强调色背景
    final bgColor = isSelected ? colors.accentSoft : colors.surfaceBase;
    final borderColor = isSelected ? colors.accent : colors.divider;
    final textColor = isSelected ? colors.accent : colors.textPrimary;

    return TapScale(
      onTap: onTap,
      scale: TapScales.medium,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tag.icon != null) ...[
              Text(tag.icon!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
            if (tag.channelCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '${tag.channelCount}',
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
