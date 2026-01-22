import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

/// 影视卡片组件 - 用于 Discovery 页面的水平列表
class DiscoveryMediaCard extends StatelessWidget {
  const DiscoveryMediaCard({
    super.key,
    required this.title,
    required this.rating,
    this.posterUrl = 'https://picsum.photos/300/450',
    this.placeholderColor,
    this.onTapWatchlist,
    this.onTapWantToWatch,
    this.onTapTrailer,
    this.onTapInfo,
  });

  final String title;
  final double rating;
  final String posterUrl;
  final Color? placeholderColor;
  final VoidCallback? onTapWatchlist;
  final VoidCallback? onTapWantToWatch;
  final VoidCallback? onTapTrailer;
  final VoidCallback? onTapInfo;

  // 更淡雅的颜色
  static const _overlayColor = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    final surfaceColor = AppColors.of(context).surfaceElevated;
    final textSecondary = AppColors.of(context).textSecondary;
    
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面区域
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  // 封面图片
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: placeholderColor ?? Colors.grey.withValues(alpha: 0.2),
                        image: DecorationImage(
                          image: NetworkImage(posterUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // 左上角 - 书签形状的收藏到片单按钮
                  Positioned(
                    top: 0, left: 0,
                    child: GestureDetector(
                      onTap: onTapWatchlist,
                      child: ClipPath(
                        clipper: _BookmarkClipper(),
                        child: Container(
                          width: 26,
                          height: 34,
                          color: _overlayColor,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 5),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 左下角 - +想看 按钮（紧贴左边缘）
                  Positioned(
                    bottom: 0, left: 0,
                    child: GestureDetector(
                      onTap: onTapWantToWatch,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        color: _overlayColor,
                        child: const Text(
                          '+想看',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 右下角 - 评分（紧贴右边缘）
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      color: _overlayColor,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          
          // 标题
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          
          // 预告 (3/4) & 详情 (1/4) 按钮 - 更淡雅的设计
          const SizedBox(height: 4),
          Row(
            children: [
              // 预告按钮 - 占 3/4
              Expanded(
                flex: 3,
                child: Material(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: onTapTrailer,
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(12, 12),
                            painter: _PlayIconPainter(color: textSecondary),
                          ),
                          const SizedBox(width: 4),
                          Text('预告', style: TextStyle(fontSize: 10, color: textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // 详情按钮 - 占 1/4，只显示图标
              Expanded(
                flex: 1,
                child: Material(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    onTap: onTapInfo,
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 28,
                      child: Center(
                        child: CustomPaint(
                          size: const Size(14, 14),
                          painter: _InfoIconPainter(color: textSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/// 书签形状的 CustomClipper
class _BookmarkClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height - 8);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// 圆润线条的播放图标
class _PlayIconPainter extends CustomPainter {
  _PlayIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // 圆润的三角形播放按钮
    path.moveTo(size.width * 0.2, size.height * 0.15);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.lineTo(size.width * 0.2, size.height * 0.85);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 圆润线条的信息图标
class _InfoIconPainter extends CustomPainter {
  _InfoIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    
    // 圆形外框
    canvas.drawCircle(center, radius, paint);
    
    // 小圆点 (i 的点)
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.4), 1.2, dotPaint);
    
    // 竖线 (i 的身体)
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.1),
      Offset(center.dx, center.dy + radius * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
