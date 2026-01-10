// =============================================================================
// 频道标签抽屉组件 - Channel Tag Drawer Widget
// =============================================================================
//
// ## 设计目的
// 提供底部可拖拽展开/收起的标签选择器，用于频道列表页的标签筛选功能。
// 参考 iOS 原生的底部抽屉交互模式，支持手势拖拽和点击切换两种操作方式。
//
// ## 交互设计
// - 收起状态：仅显示拖拽指示条，占用最小空间
// - 展开状态：显示完整标签列表，占屏幕高度 50%
// - 拖拽手势：支持平滑拖拽，松手后根据位置和速度决定最终状态
// - 点击切换：点击头部区域可快速切换展开/收起状态
//
// ## 性能优化
// - 高度计算缓存：避免每次 build 重复计算屏幕尺寸相关的高度值
// - 屏幕尺寸监听：仅在屏幕尺寸变化时重新计算缓存值
// - 动画优化：拖拽时禁用动画，松手后才启用过渡动画
//
// ## 使用示例
// ```dart
// ChannelTagDrawer(
//   tags: mockChannelTags,
//   selectedTags: _selectedTags,
//   onTagTap: (tag) {
//     setState(() {
//       if (_selectedTags.contains(tag.id)) {
//         _selectedTags.remove(tag.id);
//       } else {
//         _selectedTags.add(tag.id);
//       }
//     });
//   },
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../models/channel_tag.dart';
import 'channel_constants.dart';

/// 频道标签抽屉
///
/// 底部可拖拽展开/收起的标签选择器，用于频道列表页的标签筛选。
///
/// ## 参数说明
/// - [tags]: 可选标签列表
/// - [selectedTags]: 当前选中的标签 ID 集合
/// - [onTagTap]: 标签点击回调，由父组件处理选中状态切换
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
  // -------------------------------------------------------------------------
  // 状态变量
  // -------------------------------------------------------------------------
  bool _isExpanded = false; // 是否展开
  bool _isDragging = false; // 是否正在拖拽
  double _dragOffset = 0; // 拖拽偏移量（向上为负，向下为正）

  // -------------------------------------------------------------------------
  // 高度缓存（性能优化）
  // -------------------------------------------------------------------------
  // 缓存高度计算结果，避免每次 build 重复计算
  // 仅在屏幕尺寸变化或拖拽状态变化时更新
  double _cachedCollapsedHeight = 0;
  double _cachedExpandedHeight = 0;
  double _cachedCurrentHeight = 0;
  Size? _lastScreenSize;

  /// 更新缓存的高度值（仅在屏幕尺寸变化或拖拽/展开状态变化时调用）
  void _updateCachedHeights(MediaQueryData mediaQuery) {
    final screenSize = mediaQuery.size;
    final bottomPadding = mediaQuery.padding.bottom;

    // 检查屏幕尺寸是否变化
    final sizeChanged = _lastScreenSize != screenSize;
    if (sizeChanged) {
      _lastScreenSize = screenSize;
      _cachedCollapsedHeight = TagDrawerLayout.headerHeight + bottomPadding;
      _cachedExpandedHeight = screenSize.height * TagDrawerLayout.expandedRatio;
    }

    // 计算当前高度
    if (_isDragging) {
      final baseHeight = _isExpanded
          ? _cachedExpandedHeight
          : _cachedCollapsedHeight;
      _cachedCurrentHeight = (baseHeight - _dragOffset).clamp(
        _cachedCollapsedHeight,
        _cachedExpandedHeight,
      );
    } else {
      _cachedCurrentHeight = _isExpanded
          ? _cachedExpandedHeight
          : _cachedCollapsedHeight;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset += details.delta.dy;
    });
  }

  /// 拖拽结束处理
  ///
  /// 根据拖拽速度和当前位置决定最终状态：
  /// - 快速向上滑动（速度 < -阈值）：展开
  /// - 快速向下滑动（速度 > 阈值）：收起
  /// - 慢速滑动：根据当前高度是否超过中点决定
  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final midPoint = (_cachedCollapsedHeight + _cachedExpandedHeight) / 2;

    setState(() {
      _isDragging = false;
      _dragOffset = 0;

      // 速度阈值判断
      if (velocity < -TagDrawerLayout.velocityThreshold) {
        _isExpanded = true;
      } else if (velocity > TagDrawerLayout.velocityThreshold) {
        _isExpanded = false;
      } else {
        // 慢速滑动时，根据位置决定
        _isExpanded = _cachedCurrentHeight > midPoint;
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
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    // 更新缓存的高度值
    _updateCachedHeights(mediaQuery);
    final currentHeight = _cachedCurrentHeight;

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
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TagDrawerLayout.drawerBorderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(
                alpha: TagDrawerLayout.shadowOpacity,
              ),
              blurRadius: TagDrawerLayout.shadowBlurRadius,
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
                padding: const EdgeInsets.symmetric(
                  vertical: TagDrawerLayout.headerVerticalPadding,
                ),
                child: Center(child: _buildDragHandle(colors)),
              ),
            ),
            // 标签滚动区域
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  TagDrawerLayout.contentHorizontalPadding,
                  0,
                  TagDrawerLayout.contentHorizontalPadding,
                  bottomPadding + TagDrawerLayout.contentBottomPadding,
                ),
                child: Wrap(
                  spacing: TagChipLayout.chipSpacing,
                  runSpacing: TagChipLayout.chipRunSpacing,
                  children: [
                    for (final tag in widget.tags)
                      _TagChip(
                        tag: tag,
                        isSelected: widget.selectedTags.contains(tag.id),
                        onTap: () => widget.onTagTap(tag),
                      ),
                  ],
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
      width: TagDrawerLayout.handleWidth,
      height: TagDrawerLayout.handleHeight,
      decoration: BoxDecoration(
        color: colors.textDisabled,
        borderRadius: BorderRadius.circular(TagDrawerLayout.handleBorderRadius),
      ),
    );
  }
}

/// 标签芯片组件
///
/// 单个可选中的标签，支持图标、名称和频道数量显示。
/// 选中状态通过边框颜色和背景色区分。
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
    final borderWidth = isSelected
        ? TagChipLayout.selectedBorderWidth
        : TagChipLayout.normalBorderWidth;

    return TapScale(
      onTap: onTap,
      scale: TapScales.medium,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TagChipLayout.horizontalPadding,
          vertical: TagChipLayout.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(TagChipLayout.borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tag.icon != null) ...[
              Text(
                tag.icon!,
                style: const TextStyle(fontSize: TagChipLayout.iconFontSize),
              ),
              const SizedBox(width: TagChipLayout.iconSpacing),
            ],
            Text(
              tag.name,
              style: TextStyle(
                fontSize: TagChipLayout.nameFontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
            if (tag.channelCount > 0) ...[
              const SizedBox(width: TagChipLayout.countSpacing),
              Text(
                '${tag.channelCount}',
                style: TextStyle(
                  fontSize: TagChipLayout.countFontSize,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
