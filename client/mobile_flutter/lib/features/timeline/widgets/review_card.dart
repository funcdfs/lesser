import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';

/// 影评卡片数据模型
class ReviewCardData {
  const ReviewCardData({
    required this.id,
    required this.movieTitle,
    required this.moviePoster,
    required this.movieRating,
    required this.userRating,
    required this.user,
    required this.publishTime,
    required this.publishDate,
    required this.reviewText,
    this.shareCount = 0,
    this.repostCount = 0,
    this.badges = const [],
  });

  final String id;
  final String movieTitle;
  final String moviePoster;
  final double movieRating; // 平台评分
  final double userRating; // 用户评分
  final UserInfo user;
  final String publishTime;
  final String publishDate;
  final String reviewText;
  final int shareCount;
  final int repostCount;
  final List<String> badges;
}

/// 用户信息
class UserInfo {
  const UserInfo({
    required this.name,
    required this.avatar,
    this.badges = const [],
  });

  final String name;
  final String avatar;
  final List<String> badges;
}

/// 精致影评卡片 - 1:1 复刻 UIdemo
class ReviewCard extends StatefulWidget {
  const ReviewCard({
    super.key,
    required this.data,
    this.onExpand,
    this.onLike,
    this.onShare,
    this.onRepost,
    this.onBookmark,
  });

  final ReviewCardData data;
  final VoidCallback? onExpand;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onRepost;
  final VoidCallback? onBookmark;

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _liked = false;
  bool _bookmarked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    // 模拟点赞数
    _likeCount = 50 + (widget.data.id.hashCode.abs() % 450);
  }

  void _handleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount = _liked ? _likeCount + 1 : _likeCount - 1;
    });
    widget.onLike?.call();
  }

  void _handleBookmark() {
    setState(() {
      _bookmarked = !_bookmarked;
    });
    widget.onBookmark?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      // 移除原有的 TapScale，改为普通点击手势，降低视觉干扰
      onTap: widget.onExpand,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                // 背景：电影海报 + 渐变遮罩
                _buildBackground(colors),
                // 内容层
                _buildContent(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 背景层：电影海报 + 渐变遮罩
  Widget _buildBackground(AppColorScheme colors) {
    return Positioned.fill(
      child: Stack(
        children: [
          // 电影海报背景
          // 采用 fitWidth 模式确保宽度铺满，对齐顶部
          Image.network(
            widget.data.moviePoster,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            opacity: const AlwaysStoppedAnimation(0.6),
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFF3F4F6),
                child: const Icon(
                  Icons.movie,
                  size: 64,
                  color: Color(0xFFD1D5DB),
                ),
              );
            },
          ),
          // 渐变遮罩：顶部保留背景，越往下白色越浓
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.4), // 顶部
                  Colors.white.withValues(alpha: 0.85), // 中部
                  Colors.white.withValues(alpha: 0.95), // 底部
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // 紫罗兰色调叠加 - 使用专属紫色 accentText 模拟精致的遮罩层
          Container(
            decoration: BoxDecoration(
              color: colors.accentText.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }

  /// 内容层
  Widget _buildContent(AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 顶部：头像、用户名、时间、标签
          _buildUserInfo(colors),
          const SizedBox(height: 16),
          // 2. 电影标题 & 评分
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMovieTitle()),
              const SizedBox(width: 12),
              _buildRatings(colors),
            ],
          ),
          const SizedBox(height: 12),
          // 3. 影评内容
          _buildReviewText(),
          const SizedBox(height: 16),
          // 4. 底部交互按钮
          _buildActions(colors),
        ],
      ),
    );
  }

  /// 用户信息区
  Widget _buildUserInfo(AppColorScheme colors) {
    return Row(
      children: [
        // 头像
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              widget.data.user.avatar,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF8B5CF6),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 用户名、时间、标签
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户名、时间、日期
              Row(
                children: [
                  Text(
                    widget.data.user.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.data.publishTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.data.publishDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              // 用户标签
              if (widget.data.user.badges.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: widget.data.user.badges
                      .map((badge) => _buildBadge(badge, colors))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 用户标签
  Widget _buildBadge(String badge, AppColorScheme colors) {
    final badgeStyle = _getBadgeStyle(badge, colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeStyle.bgColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeStyle.icon, size: 10, color: badgeStyle.textColor),
          const SizedBox(width: 2),
          Text(
            badge,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: badgeStyle.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeStyle _getBadgeStyle(String badge, AppColorScheme colors) {
    switch (badge) {
      case 'VIP':
        return const _BadgeStyle(
          icon: Icons.workspace_premium,
          bgColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFB45309),
        );
      case '影评人':
        return _BadgeStyle(
          icon: Icons.emoji_events,
          bgColor: colors.accentSoft,
          textColor: colors.accent,
        );
      case '活跃':
        return const _BadgeStyle(
          icon: Icons.bolt,
          bgColor: Color(0xFFDBEAFE),
          textColor: Color(0xFF1E40AF),
        );
      default:
        return const _BadgeStyle(
          icon: Icons.star,
          bgColor: Color(0xFFF3F4F6),
          textColor: Color(0xFF6B7280),
        );
    }
  }

  /// 电影标题
  Widget _buildMovieTitle() {
    return Text(
      widget.data.movieTitle,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
        height: 1.3,
        shadows: [
          Shadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 影评内容
  Widget _buildReviewText() {
    return Text(
      widget.data.reviewText,
      style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
      maxLines: 10,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 评分区
  Widget _buildRatings(AppColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactRating(
          rating: widget.data.movieRating,
          starColor: colors.accent,
        ),
        const SizedBox(width: 8),
        _buildCompactRating(
          rating: widget.data.userRating,
          starColor: const Color(0xFFFBBF24),
        ),
      ],
    );
  }

  Widget _buildCompactRating({
    required double rating,
    required Color starColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: starColor),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部交互按钮
  Widget _buildActions(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.accent.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 交互按钮均使用主题专属紫色 (accent) 或强调色 (interactiveHover)
          // 点赞
          _ActionButton(
            icon: _liked ? Icons.favorite : Icons.favorite_border,
            label: _likeCount.toString(),
            color: _liked ? colors.interactiveHover : colors.accent,
            filled: _liked,
            onTap: _handleLike,
          ),
          const SizedBox(width: 4),
          // 转发
          _ActionButton(
            icon: Icons.repeat,
            label: widget.data.repostCount.toString(),
            color: colors.accent,
            onTap: () => widget.onRepost?.call(),
          ),
          const SizedBox(width: 4),
          // 分享
          _ActionButton(
            icon: Icons.share_outlined,
            label: widget.data.shareCount.toString(),
            color: colors.accent,
            onTap: () => widget.onShare?.call(),
          ),
          const Spacer(),
          // 收藏
          _ActionButton(
            icon: _bookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _bookmarked ? colors.interactiveHover : colors.accent,
            filled: _bookmarked,
            onTap: _handleBookmark,
          ),
        ],
      ),
    );
  }
}

/// 交互按钮
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.label,
    required this.color,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final String? label;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: filled
              ? colors.accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 标签样式
class _BadgeStyle {
  const _BadgeStyle({
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });

  final IconData icon;
  final Color bgColor;
  final Color textColor;
}
