// 主页面 - 底部导航栏 + 四个 Tab 页面

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../feed/pages/feed_page.dart';
import '../../channel/pages/channel_page.dart';
import '../../chat/pages/chat_page.dart';
import '../../profile/pages/profile_page.dart';

// 导航图标 SVG 路径（24x24 viewBox）
const _iconFeed = 'M4 4H16 M4 9H20 M4 14H20 M4 19H14';
const _iconChannel = 'M10 3L8 21 M16 3L14 21 M4 8H20 M3 16H19';
const _iconChat =
    'M21 11.5C21 16.1944 16.9706 20 12 20C10.8053 20 9.66406 19.8047 8.61551 19.4474L3 21L4.5 16.5C3.55399 15.0994 3 13.3681 3 11.5C3 6.80558 7.02944 3 12 3C16.9706 3 21 6.80558 21 11.5Z';
const _iconProfile =
    'M12 12C14.21 12 16 10.21 16 8C16 5.79 14.21 4 12 4C9.79 4 8 5.79 8 8C8 10.21 9.79 12 12 12Z M4 20C4 17 8 15 12 15C16 15 20 17 20 20';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _tabIndex = 0;
  bool _isDarkMode = false;

  void toggleDarkMode() => setState(() => _isDarkMode = !_isDarkMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: const [FeedPage(), ChannelPage(), ChatPage(), ProfilePage()],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _tabIndex,
        isDarkMode: _isDarkMode,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

// ============================================================================
// 底部导航栏
// ============================================================================

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.isDarkMode,
    required this.onTap,
  });

  final int currentIndex;
  final bool isDarkMode;
  final ValueChanged<int> onTap;

  static const _items = [
    (label: '动态', icon: _iconFeed),
    (label: '频道', icon: _iconChannel),
    (label: '聊天', icon: _iconChat),
    (label: '我的', icon: _iconProfile),
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    final activeColor = isDarkMode
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
    final inactiveColor = isDarkMode
        ? const Color(0xFF666666)
        : const Color(0xFFAAAAAA);
    final borderColor = isDarkMode
        ? const Color(0xFF222222)
        : const Color(0xFFEEEEEE);

    return Container(
      height: 56 + MediaQuery.paddingOf(context).bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          return Expanded(
            child: _NavItem(
              icon: _items[i].icon,
              isSelected: currentIndex == i,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              onTap: () => onTap(i),
            ),
          );
        }),
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
                    painter: _IconPainter(widget.icon, color, strokeWidth),
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

// ============================================================================
// SVG Path 绘制器
// ============================================================================

class _IconPainter extends CustomPainter {
  _IconPainter(this.path, this.color, this.strokeWidth);
  final String path;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_parse(path, size), paint);
  }

  Path _parse(String data, Size size) {
    final p = Path();
    final tokens = _tokenize(data);
    final sx = size.width / 24, sy = size.height / 24;
    double cx = 0, cy = 0;
    int i = 0;

    while (i < tokens.length) {
      switch (tokens[i]) {
        case 'M':
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          p.moveTo(cx, cy);
        case 'L':
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          p.lineTo(cx, cy);
        case 'H':
          cx = double.parse(tokens[++i]) * sx;
          p.lineTo(cx, cy);
        case 'V':
          cy = double.parse(tokens[++i]) * sy;
          p.lineTo(cx, cy);
        case 'C':
          final x1 = double.parse(tokens[++i]) * sx;
          final y1 = double.parse(tokens[++i]) * sy;
          final x2 = double.parse(tokens[++i]) * sx;
          final y2 = double.parse(tokens[++i]) * sy;
          cx = double.parse(tokens[++i]) * sx;
          cy = double.parse(tokens[++i]) * sy;
          p.cubicTo(x1, y1, x2, y2, cx, cy);
        case 'Z':
          p.close();
      }
      i++;
    }
    return p;
  }

  List<String> _tokenize(String data) {
    final r = <String>[];
    for (final m in RegExp(r'([MLHVCZ])|(-?\d+\.?\d*)').allMatches(data)) {
      final v = m.group(0);
      if (v != null && v.isNotEmpty) r.add(v);
    }
    return r;
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.path != path || old.color != color || old.strokeWidth != strokeWidth;
}
