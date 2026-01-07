// 频道底部操作栏组件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../pkg/ui/theme/theme.dart';

/// 频道底部操作栏
class ChannelBottomBar extends StatelessWidget {
  const ChannelBottomBar({
    super.key,
    required this.isMuted,
    this.onSearchTap,
    this.onMuteTap,
    this.onCommentTap,
    this.onSettingsTap,
  });

  final bool isMuted;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMuteTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      height: 52 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: colors.surfaceNav,
        border: Border(top: BorderSide(color: colors.navBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          // 搜索按钮
          _BarButton(icon: Icons.search_rounded, onTap: onSearchTap),

          // 静音切换
          Expanded(
            child: _MuteButton(isMuted: isMuted, onTap: onMuteTap),
          ),

          // 评论按钮
          _BarButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: onCommentTap,
          ),

          // 设置按钮
          _BarButton(icon: Icons.tune_rounded, onTap: onSettingsTap),
        ],
      ),
    );
  }
}

/// 底部栏按钮
class _BarButton extends StatefulWidget {
  const _BarButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_BarButton> createState() => _BarButtonState();
}

class _BarButtonState extends State<_BarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final scale = 1.0 - 0.1 * _ctrl.value;
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(widget.icon, size: 24, color: colors.textTertiary),
            ),
          );
        },
      ),
    );
  }
}

/// 静音切换按钮
class _MuteButton extends StatefulWidget {
  const _MuteButton({required this.isMuted, this.onTap});

  final bool isMuted;
  final VoidCallback? onTap;

  @override
  State<_MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<_MuteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final scale = 1.0 - 0.05 * _ctrl.value;
          return Transform.scale(
            scale: scale,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceBase,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.divider, width: 0.5),
                ),
                child: Text(
                  widget.isMuted ? '取消静音' : '静音',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
