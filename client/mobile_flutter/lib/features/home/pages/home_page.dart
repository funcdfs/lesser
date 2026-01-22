// 主页面 - 底部导航栏 + 四个 Tab 页面

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../../discovery/pages/discovery_page.dart';
import '../../subject/pages/subject_page.dart';
import '../../tracker/pages/tracker_page.dart';
import '../../profile/pages/profile_page.dart';

// 导航图标 SVG 路径（24x24 viewBox）
const _iconInfo = 'M4 4H16 M4 9H20 M4 14H20 M4 19H14';
const _iconSeries = 'M10 3L8 21 M16 3L14 21 M4 8H20 M3 16H19';
const _iconWatchlist = 'M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z'; // Eye icon
const _iconProfile =
    'M12 12C14.21 12 16 10.21 16 8C16 5.79 14.21 4 12 4C9.79 4 8 5.79 8 8C8 10.21 9.79 12 12 12Z M4 20C4 17 8 15 12 15C16 15 20 17 20 20';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  // 懒加载：记录已访问过的 Tab，避免 IndexedStack 同时保持所有页面状态
  final Set<int> _loadedTabs = {0}; // 默认加载第一个 Tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 让内容延伸到底部导航栏后面
      extendBody: true,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          // 只构建已访问过的页面，未访问的用空容器占位
          _loadedTabs.contains(0) ? const DiscoveryPage() : const SizedBox.shrink(),
          _loadedTabs.contains(1)
              ? const SubjectPage()
              : const SizedBox.shrink(),
          _loadedTabs.contains(2) ? const TrackerPage() : const SizedBox.shrink(),
          _loadedTabs.contains(3)
              ? const ProfilePage()
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: _FrostedBottomNavBar(
        currentIndex: _tabIndex,
        onTap: (i) {
          if (!_loadedTabs.contains(i)) {
            _loadedTabs.add(i);
          }
          setState(() => _tabIndex = i);
        },
      ),
    );
  }
}

// ============================================================================
// 毛玻璃底部导航栏
// ============================================================================

class _FrostedBottomNavBar extends StatelessWidget {
  const _FrostedBottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (label: '首页', icon: _iconInfo),
    (label: '剧集', icon: _iconSeries),
    (label: '追踪', icon: _iconWatchlist),
    (label: '我的', icon: _iconProfile),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 56 + bottomPadding,
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: colors.surfaceNav.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: colors.navBorder.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              return Expanded(
                child: _NavItem(
                  icon: _items[i].icon,
                  isSelected: currentIndex == i,
                  activeColor: colors.textPrimary,
                  inactiveColor: colors.textTertiary,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final String icon;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _opacity = Tween(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) {
    _ctrl.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected ? widget.activeColor : widget.inactiveColor;
    final strokeWidth = widget.isSelected ? 2.4 : 1.6;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Transform.scale(
            scale: _scale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: _opacity.value),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                if (widget.isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.12),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CustomPaint(
                    painter: IconPainter(widget.icon, color, strokeWidth),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
