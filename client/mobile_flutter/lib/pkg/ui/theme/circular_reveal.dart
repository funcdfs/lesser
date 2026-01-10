// Circular Reveal 主题切换动画
// 实现原理：双层截图法 + 柔边羽化 + 复合动画
// - 截取当前屏幕并应用模糊滤镜
// - 切换主题后，模糊截图覆盖在新主题上
// - 从触发点开始圆形收缩消失，露出新主题

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../animation/animation.dart';

// ============================================================================
// 动画控制器
// ============================================================================

/// Circular Reveal 动画控制器
class CircularRevealController extends ChangeNotifier {
  bool _isAnimating = false;
  double _progress = 0.0;
  Offset _origin = Offset.zero;
  bool _targetIsDark = false;
  ui.Image? _blurredImage;

  /// 是否正在动画中
  bool get isAnimating => _isAnimating;

  /// 动画进度 0.0 ~ 1.0
  double get progress => _progress;

  /// 动画起始位置
  Offset get origin => _origin;

  /// 目标主题是否为深色
  bool get targetIsDark => _targetIsDark;

  /// 模糊截图
  ui.Image? get blurredImage => _blurredImage;

  /// 开始动画
  void startAnimation({
    required Offset origin,
    required bool targetIsDark,
    required ui.Image blurredImage,
  }) {
    _origin = origin;
    _targetIsDark = targetIsDark;
    _blurredImage = blurredImage;
    _isAnimating = true;
    _progress = 0.0;
    notifyListeners();
  }

  /// 更新进度
  void updateProgress(double value) {
    _progress = value;
    notifyListeners();
  }

  /// 结束动画，释放资源
  void endAnimation() {
    _isAnimating = false;
    _progress = 0.0;
    _blurredImage?.dispose();
    _blurredImage = null;
    notifyListeners();
  }
}

// ============================================================================
// 动画覆盖层组件
// ============================================================================

/// Circular Reveal 覆盖层
/// 在动画期间显示模糊截图，并执行圆形收缩动画
class CircularRevealOverlay extends StatefulWidget {
  const CircularRevealOverlay({
    super.key,
    required this.controller,
    required this.child,
  });

  final CircularRevealController controller;
  final Widget child;

  @override
  State<CircularRevealOverlay> createState() => _CircularRevealOverlayState();
}

class _CircularRevealOverlayState extends State<CircularRevealOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    // 非动画状态，直接返回子组件
    if (!ctrl.isAnimating || ctrl.blurredImage == null) {
      return widget.child;
    }

    final size = MediaQuery.of(context).size;
    final maxRadius = _calcMaxRadius(ctrl.origin, size);
    final p = ctrl.progress;

    // 复合动画参数
    final opacity = (1.0 - p * CircularRevealAnim.opacityDecay).clamp(0.0, 1.0);
    final scale = 1.0 + p * CircularRevealAnim.scaleIncrement;
    final revealProgress = 1.0 - p;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (opacity > 0)
            Positioned.fill(
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: _SoftEdgeMask(
                    origin: ctrl.origin,
                    progress: revealProgress,
                    maxRadius: maxRadius,
                    child: RawImage(
                      image: ctrl.blurredImage,
                      fit: BoxFit.cover,
                      width: size.width,
                      height: size.height,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 计算从起点到屏幕四角的最大距离
  double _calcMaxRadius(Offset origin, Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    return corners
        .map((c) => (c - origin).distance)
        .reduce((a, b) => a > b ? a : b);
  }
}

// ============================================================================
// 柔边遮罩组件
// ============================================================================

/// 柔边圆形遮罩
/// 使用 ShaderMask + RadialGradient 实现羽化边缘效果
class _SoftEdgeMask extends StatelessWidget {
  const _SoftEdgeMask({
    required this.origin,
    required this.progress,
    required this.maxRadius,
    required this.child,
  });

  final Offset origin;
  final double progress;
  final double maxRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = maxRadius * progress;
    final featherWidth = maxRadius * CircularRevealAnim.featherRatio;
    final innerRadius = (radius - featherWidth).clamp(0.0, double.infinity);
    final innerStop = radius > 0 ? (innerRadius / radius).clamp(0.0, 1.0) : 0.0;

    return ShaderMask(
      shaderCallback: (bounds) {
        return RadialGradient(
          center: Alignment(
            (origin.dx / bounds.width) * 2 - 1,
            (origin.dy / bounds.height) * 2 - 1,
          ),
          radius: radius / bounds.shortestSide,
          colors: const [Colors.white, Colors.white, Colors.transparent],
          stops: [0.0, innerStop, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

// ============================================================================
// 工具函数
// ============================================================================

/// 同步生成模糊截图
/// 使用 Canvas + ImageFilter 在内存中一次性完成，避免异步延迟
ui.Image? createBlurredScreenshot(
  RenderRepaintBoundary boundary, {
  double? blurSigma,
  double pixelRatio = 1.0,
}) {
  final sigma = blurSigma ?? CircularRevealAnim.blurSigma;
  try {
    final original = boundary.toImageSync(pixelRatio: pixelRatio);
    final w = original.width;
    final h = original.height;

    // 绘制模糊图片
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..imageFilter = ui.ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: TileMode.clamp,
      );
    canvas.drawImage(original, Offset.zero, paint);

    // 生成并返回
    final picture = recorder.endRecording();
    final blurred = picture.toImageSync(w, h);

    // 释放临时资源
    original.dispose();
    picture.dispose();

    return blurred;
  } catch (e) {
    debugPrint('生成模糊截图失败: $e');
    return null;
  }
}
