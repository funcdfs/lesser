// Hero 精选影评卡片 - 推荐流顶部大卡片

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import 'review_card.dart';

/// Hero 精选影评卡片
///
/// 用于推荐流顶部，展示编辑精选的高质量影评
/// 设计特点：
/// - 更大的尺寸和更突出的视觉效果
/// - 编辑精选标签
/// - 电影类型标签
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
    return TapScale(
      onTap: onTap,
      child: Container(
        height: 400,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2e0052).withValues(alpha: 0.08),
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
              _buildPosterBackground(),
              // 渐变遮罩
              _buildGradientOverlay(),
              // 内容层
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// 电影海报背景
  Widget _buildPosterBackground() {
    return Positioned.fill(
      child: Image.network(
        data.filmPoster,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFF2e0052).withValues(alpha: 0.2),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6c49b2),
                ),
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
  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2e0052).withValues(alpha: 0.9),
              const Color(0xFF2e0052).withValues(alpha: 0.3),
              const Color(0xFF2e0052).withValues(alpha: 0.9),
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }

  /// 内容层
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签行
          _buildTags(),
          const Spacer(),
          // 电影标题
          Text(
            data.filmTitle,
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
          _buildUserAndRating(),
        ],
      ),
    );
  }

  /// 标签行
  Widget _buildTags() {
    return Row(
      children: [
        // 编辑精选标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFb390fe),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'EDITORS CHOICE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF461f8a),
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
  Widget _buildUserAndRating() {
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
              data.userAvatar,
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
          data.userName,
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
            const Icon(Icons.star, size: 14, color: Color(0xFFd2bbff)),
            const SizedBox(width: 4),
            Text(
              data.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFd2bbff),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
