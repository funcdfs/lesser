// 滚动按钮组件
//
// 智能显示/隐藏的置顶置底按钮
// 参考 Telegram/WhatsApp 的交互设计
//
// 特性：
// - 根据滚动位置智能显示/隐藏
// - 平滑的淡入淡出 + 缩放动画
// - 新消息指示器（可选）
// - 防抖优化，避免频繁重建

import 'package:flutter/material.dart';
import '../../ui/effects/effects.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/unread_badge.dart';

/// 滚动按钮显示阈值
const _showButtonThreshold = 300.0; // 滚动超过 300px 显示按钮
const _atEdgeThreshold = 50.0; // 距离边缘 50px 内视为到达

/// 滚动按钮控制器
///
/// 管理滚动按钮的显示状态和新消息计数
class ScrollButtonController extends ChangeNotifier {
  ScrollButtonController({
    required ScrollController scrollController,
    this.showThreshold = _showButtonThreshold,
    this.edgeThreshold = _atEdgeThreshold,
  }) : _scrollController = scrollController {
    _scrollController.addListener(_onScroll);
    // 初始化时检查一次
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkInitialState());
  }

  final ScrollController _scrollController;
  final double showThreshold;
  final double edgeThreshold;

  // 状态
  bool _isVisible = false;
  bool _isAtTop = true;
  bool _isAtBottom = true;
  int _newMessageCount = 0;
  bool _hasEnoughContent = false;
  bool _isDisposed = false;

  // Getters
  bool get isVisible => _isVisible && _hasEnoughContent;
  bool get isAtTop => _isAtTop;
  bool get isAtBottom => _isAtBottom;
  int get newMessageCount => _newMessageCount;
  bool get hasNewMessages => _newMessageCount > 0;

  /// 检查初始状态
  void _checkInitialState() {
    if (_isDisposed || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    _hasEnoughContent = position.maxScrollExtent > showThreshold;
    _updateState();
  }

  /// 滚动监听
  void _onScroll() {
    if (_isDisposed || !_scrollController.hasClients) return;
    _updateState();
  }

  /// 更新状态
  void _updateState() {
    if (_isDisposed) return;

    final position = _scrollController.position;
    final pixels = position.pixels;
    final maxExtent = position.maxScrollExtent;

    // 更新内容是否足够
    final hasEnough = maxExtent > showThreshold;
    if (hasEnough != _hasEnoughContent) {
      _hasEnoughContent = hasEnough;
    }

    // 更新边缘状态
    final atTop = pixels <= edgeThreshold;
    final atBottom = pixels >= maxExtent - edgeThreshold;

    // 更新可见性：滚动超过阈值时显示
    final visible = pixels > showThreshold || !atBottom;

    // 到达底部时清除新消息计数
    if (atBottom && _newMessageCount > 0) {
      _newMessageCount = 0;
    }

    // 仅在状态变化时通知
    if (atTop != _isAtTop || atBottom != _isAtBottom || visible != _isVisible) {
      _isAtTop = atTop;
      _isAtBottom = atBottom;
      _isVisible = visible;
      notifyListeners();
    }
  }

  /// 内容更新时调用（如加载更多评论）
  void onContentUpdated() {
    if (_isDisposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      _hasEnoughContent = position.maxScrollExtent > showThreshold;
      _updateState();
    });
  }

  /// 新消息到达时调用
  void onNewMessage() {
    if (_isDisposed) return;
    if (!_isAtBottom) {
      _newMessageCount++;
      notifyListeners();
    }
  }

  /// 滚动到顶部
  void scrollToTop() {
    if (_isDisposed || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: AnimDurations.slow,
      curve: AnimCurves.standard,
    );
  }

  /// 滚动到底部
  void scrollToBottom() {
    if (_isDisposed || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: AnimDurations.slow,
      curve: AnimCurves.standard,
    );
    // 清除新消息计数
    if (_newMessageCount > 0) {
      _newMessageCount = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // 安全移除监听器，防止 ScrollController 已被 dispose
    try {
      _scrollController.removeListener(_onScroll);
    } catch (_) {
      // ScrollController 可能已被外部 dispose，忽略异常
    }
    super.dispose();
  }
}

/// 滚动按钮组
///
/// 包含置顶和置底两个按钮，支持新消息指示器
/// 注意：此组件需要放在 Stack 中，并由调用方使用 Positioned 定位
class ScrollButtons extends StatelessWidget {
  const ScrollButtons({
    super.key,
    required this.controller,
    this.showTopButton = true,
    this.showBottomButton = true,
  });

  final ScrollButtonController controller;
  final bool showTopButton;
  final bool showBottomButton;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // 整体淡入淡出
        return AnimatedOpacity(
          opacity: controller.isVisible ? 1.0 : 0.0,
          duration: AnimDurations.slow,
          child: AnimatedScale(
            scale: controller.isVisible ? 1.0 : 0.8,
            duration: AnimDurations.slow,
            curve: AnimCurves.standard,
            child: IgnorePointer(
              ignoring: !controller.isVisible,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 置顶按钮
                  if (showTopButton)
                    _ScrollButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      isDisabled: controller.isAtTop,
                      onTap: controller.scrollToTop,
                      colors: colors,
                    ),
                  if (showTopButton && showBottomButton)
                    const SizedBox(height: 8),
                  // 置底按钮（带新消息指示器）
                  if (showBottomButton)
                    _ScrollButtonWithBadge(
                      icon: Icons.keyboard_arrow_down_rounded,
                      isDisabled: controller.isAtBottom,
                      badgeCount: controller.newMessageCount,
                      onTap: controller.scrollToBottom,
                      colors: colors,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 单个滚动按钮
class _ScrollButton extends StatelessWidget {
  const _ScrollButton({
    required this.icon,
    required this.isDisabled,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final bool isDisabled;
  final VoidCallback onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final button = AnimatedOpacity(
      opacity: isDisabled ? 0.35 : 1.0,
      duration: AnimDurations.medium,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: isDisabled ? colors.textDisabled : colors.textSecondary,
        ),
      ),
    );

    if (isDisabled) return button;
    return TapScale(onTap: onTap, scale: TapScales.small, child: button);
  }
}

/// 带徽章的滚动按钮（用于新消息指示）
class _ScrollButtonWithBadge extends StatelessWidget {
  const _ScrollButtonWithBadge({
    required this.icon,
    required this.isDisabled,
    required this.badgeCount,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final bool isDisabled;
  final int badgeCount;
  final VoidCallback onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final hasBadge = badgeCount > 0;

    final button = AnimatedOpacity(
      opacity: isDisabled && !hasBadge ? 0.35 : 1.0,
      duration: AnimDurations.medium,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 按钮主体
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              // 有新消息时使用强调色背景
              color: hasBadge ? colors.accent : colors.surfaceElevated,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (hasBadge ? colors.accent : colors.textPrimary)
                      .withValues(alpha: hasBadge ? 0.3 : 0.08),
                  blurRadius: hasBadge ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: hasBadge
                  ? colors.surfaceElevated
                  : (isDisabled ? colors.textDisabled : colors.textSecondary),
            ),
          ),
          // 新消息徽章 - 复用公共组件
          if (hasBadge)
            Positioned(
              top: -6,
              right: -6,
              child: UnreadBadge(count: badgeCount),
            ),
        ],
      ),
    );

    // 有新消息时始终可点击
    if (isDisabled && !hasBadge) return button;
    return TapScale(onTap: onTap, scale: TapScales.small, child: button);
  }
}

/// 简化版滚动按钮组（直接使用，无需控制器）
///
/// 适用于简单场景，自动管理状态
class SimpleScrollButtons extends StatefulWidget {
  const SimpleScrollButtons({
    super.key,
    required this.scrollController,
    this.showTopButton = true,
    this.showBottomButton = true,
    this.showThreshold = _showButtonThreshold,
  });

  final ScrollController scrollController;
  final bool showTopButton;
  final bool showBottomButton;
  final double showThreshold;

  @override
  State<SimpleScrollButtons> createState() => _SimpleScrollButtonsState();
}

class _SimpleScrollButtonsState extends State<SimpleScrollButtons> {
  late final ScrollButtonController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollButtonController(
      scrollController: widget.scrollController,
      showThreshold: widget.showThreshold,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // 使用动画过渡，保持 UI 流畅性
        return AnimatedOpacity(
          opacity: _controller.isVisible ? 1.0 : 0.0,
          duration: AnimDurations.slow,
          child: AnimatedScale(
            scale: _controller.isVisible ? 1.0 : 0.8,
            duration: AnimDurations.slow,
            curve: AnimCurves.standard,
            child: IgnorePointer(
              ignoring: !_controller.isVisible,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showTopButton)
                    _ScrollButton(
                      icon: Icons.keyboard_arrow_up_rounded,
                      isDisabled: _controller.isAtTop,
                      onTap: _controller.scrollToTop,
                      colors: colors,
                    ),
                  if (widget.showTopButton && widget.showBottomButton)
                    const SizedBox(height: 8),
                  if (widget.showBottomButton)
                    _ScrollButton(
                      icon: Icons.keyboard_arrow_down_rounded,
                      isDisabled: _controller.isAtBottom,
                      onTap: _controller.scrollToBottom,
                      colors: colors,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
