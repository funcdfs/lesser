// Hero 精选影评卡片 - 推荐流顶部大卡片

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import 'review_card.dart';

/// Hero 精选影评卡片
///
/// 用于推荐流顶部，展示编辑精选的高质量影评
/// 设计特点：
/// - 1:1 复刻 UIdemo 精致设计，响应式大尺寸布局
/// - 编辑精选标签 (Editor's Choice)
/// - 电影类型标签展示
/// - 移除点击缩放效果，保持交互稳重感
/// - 背景图采用 fitWidth 模式，确保宽度铺满并对齐顶部
class HeroReviewCard extends StatelessWidget {
  const HeroReviewCard({
    super.key,
    required this.data,
    this.genre = 'Sci-Fi',
    this.onTap,
  });

  final ReviewCardData data;
  final String genre;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      // 移除原有的 TapScale，改为普通点击手势，避免过度动画
      onTap: onTap,
      child: Container(
        height: 400,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // 背景：电影海报
              _buildPosterBackground(colors),
              // 渐变遮罩
              _buildGradientOverlay(colors),
              // 内容层
              _buildContent(colors),
            ],
          ),
        ),
      ),
    );
  }

  /// 电影海报背景
  Widget _buildPosterBackground(AppColorScheme colors) {
    return Positioned.fill(
      child: Image.network(
        data.moviePoster,
        // 采用 fitWidth 模式确保图片在容器中宽度铺满
        // alignment 设置为 topCenter 以展示海报上方内容（通常是标题或关键画面）
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: colors.accent.withValues(alpha: 0.1),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF2e0052).withValues(alpha: 0.2),
            child: const Icon(Icons.movie, size: 80, color: Colors.white30),
          );
        },
      ),
    );
  }

  /// 渐变遮罩
  Widget _buildGradientOverlay(AppColorScheme colors) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // 使用主题中的专属紫色 (accentText) 配合不同透明度构建层次感
            colors: [
              colors.accentText.withValues(alpha: 0.8),
              colors.accentText.withValues(alpha: 0.3),
              colors.accentText.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.3, 1.0], // 控制渐变平滑度
          ),
        ),
      ),
    );
  }

  /// 内容层
  Widget _buildContent(AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签行
          _buildTags(colors),
          const Spacer(),
          // 电影标题
          Text(
            data.movieTitle,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // 用户信息和评分
          _buildUserAndRating(colors),
        ],
      ),
    );
  }

  /// 标签行
  Widget _buildTags(AppColorScheme colors) {
    return Row(
      children: [
        // 编辑精选标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'EDITORS CHOICE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 类型标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            genre.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  /// 用户信息和评分
  Widget _buildUserAndRating(AppColorScheme colors) {
    return Row(
      children: [
        // 用户头像
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              data.user.avatar,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFF6c49b2),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 16,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF6c49b2),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 16,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 用户名
        Text(
          data.user.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 16),
        // 分隔线
        Container(
          width: 1,
          height: 16,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        const SizedBox(width: 16),
        // 评分
        Row(
          children: [
            Icon(Icons.star, size: 14, color: colors.accent),
            const SizedBox(width: 4),
            Text(
              data.movieRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
