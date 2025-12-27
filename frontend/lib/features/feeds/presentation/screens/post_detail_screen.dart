import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../../shared/utils/time_formatter.dart';
import '../../domain/models/post.dart';
import '../widgets/feeds_actions_bar.dart';
import '../widgets/feed_images_widget.dart';
import '../widgets/feeds_comment_section.dart';

/// 帖子详情屏幕
class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  double _dragOffset = 0.0;
  late AnimationController _snapController;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likesCount = widget.post.likes;

    _snapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          setState(() {
            _dragOffset = _snapController.value;
          });
        });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _handleLikeToggle() {
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postTime = DateTime.parse(widget.post.createdAt);

    return PopScope(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 半透明遮罩
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                const double wideScreenThreshold = 700;
                final bool isWideScreen =
                    constraints.maxWidth > wideScreenThreshold;

                if (isWideScreen) {
                  // 宽屏布局：浮动卡片
                  return Center(
                    child: Container(
                      width: wideScreenThreshold - 40,
                      height: constraints.maxHeight * 0.85,
                      margin: const EdgeInsets.symmetric(vertical: 40),
                      child: Transform.translate(
                        offset: Offset(0, _dragOffset),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.xl2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 30,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.xl2),
                            child: Scaffold(
                              backgroundColor: AppColors.background,
                              body: Stack(
                                children: [
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.only(top: 64),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.lg,
                                          ),
                                          child: Row(
                                            children: [
                                              Avatar(
                                                avatarUrl: '',
                                                fallbackInitials:
                                                    widget
                                                        .post
                                                        .username
                                                        .isNotEmpty
                                                    ? widget.post.username[0]
                                                    : 'U',
                                                size: 44,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.post.username,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      '@${widget.post.username.toLowerCase().replaceAll(' ', '_')}',
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .mutedForeground,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              OutlinedButton(
                                                onPressed: () {},
                                                style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppRadius.full,
                                                        ),
                                                  ),
                                                  side: BorderSide(
                                                    color: AppColors.border,
                                                  ),
                                                ),
                                                child: Text(
                                                  '关注',
                                                  style: TextStyle(
                                                    color: AppColors.foreground,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.lg,
                                          ),
                                          child: Text(
                                            widget.post.content,
                                            style: TextStyle(
                                              fontSize: 17,
                                              height: 1.5,
                                              color: AppColors.foreground,
                                            ),
                                          ),
                                        ),
                                        if (widget
                                            .post
                                            .imageUrls
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.lg,
                                            ),
                                            child: FeedImagesWidget(
                                              imageUrls: widget.post.imageUrls,
                                            ),
                                          ),
                                        ],
                                        Padding(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.lg,
                                          ),
                                          child: Text(
                                            '${TimeFormatter.formatAbsoluteTime(postTime)} · ${TimeFormatter.formatRelativeTime(postTime)}',
                                            style: TextStyle(
                                              color: AppColors.mutedForeground,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          height: 1,
                                          color: AppColors.border,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.lg,
                                            vertical: AppSpacing.xs,
                                          ),
                                          child: FeedsActionsBar(
                                            likesCount: _likesCount,
                                            commentsCount:
                                                widget.post.commentsCount,
                                            repostsCount:
                                                widget.post.repostsCount,
                                            bookmarksCount:
                                                widget.post.bookmarksCount,
                                            sharesCount:
                                                widget.post.sharesCount,
                                            initiallyLiked: _isLiked,
                                            onLikeToggle: _handleLikeToggle,
                                            responsive: false,
                                          ),
                                        ),
                                        Divider(
                                          height: 1,
                                          color: AppColors.border,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.all(
                                            AppSpacing.lg,
                                          ),
                                          child: Text(
                                            '评论',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const FeedsCommentSection(),
                                        const SizedBox(height: 100),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 64,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColors.background,
                                            AppColors.background,
                                            AppColors.background,
                                            AppColors.background,
                                            AppColors.background,
                                            AppColors.background,
                                            AppColors.background,
                                            AppColors.background,
                                            AppColors.background,
                                            AppColors.background,
                                          ],
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // 优化的拖动条
                                          Positioned(
                                            top: 20,
                                            left: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onVerticalDragUpdate: (details) {
                                                setState(() {
                                                  _dragOffset =
                                                      (_dragOffset +
                                                              details
                                                                  .primaryDelta!)
                                                          .clamp(
                                                            0.0,
                                                            double.infinity,
                                                          );
                                                });
                                              },
                                              onVerticalDragEnd: (details) {
                                                if (_dragOffset > 164 ||
                                                    details.primaryVelocity! >
                                                        500) {
                                                  Navigator.pop(context);
                                                } else {
                                                  _snapController.value =
                                                      _dragOffset;
                                                  _snapController.animateTo(
                                                    0.0,
                                                    curve: Curves.easeOutQuint,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: 28,
                                                color: Colors.transparent,
                                                alignment: Alignment.topCenter,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  height: 28,
                                                  child: SvgPicture.string(
                                                    '<svg viewBox="0 0 400 24" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg"><path d="M0 0 L200 14 L400 0 V24 H0 Z" fill="currentColor" fill-opacity="0.2"/><path d="M0 0 L200 14 L400 0" fill="none" stroke="currentColor" stroke-width="2.5" stroke-opacity="0.35" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                          AppColors.gray200,
                                                          BlendMode.srcIn,
                                                        ),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
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
                        ),
                      ),
                    ),
                  );
                } else {
                  // 窄屏布局：全屏底部滑出
                  return Transform.translate(
                    offset: Offset(0, 36.0 + _dragOffset),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15 * 255),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, -5),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08 * 255),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.xl2),
                        ),
                        child: Scaffold(
                          backgroundColor: AppColors.background,
                          body: Stack(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 64),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      child: Row(
                                        children: [
                                          Avatar(
                                            avatarUrl: '',
                                            fallbackInitials:
                                                widget.post.username.isNotEmpty
                                                ? widget.post.username[0]
                                                : 'U',
                                            size: 44,
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.post.username,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  '@${widget.post.username.toLowerCase().replaceAll(' ', '_')}',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .mutedForeground,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () {},
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.full,
                                                    ),
                                              ),
                                              side: BorderSide(
                                                color: AppColors.border,
                                              ),
                                            ),
                                            child: Text(
                                              '关注',
                                              style: TextStyle(
                                                color: AppColors.foreground,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                      ),
                                      child: Text(
                                        widget.post.content,
                                        style: TextStyle(
                                          fontSize: 17,
                                          height: 1.5,
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                    ),
                                    if (widget.post.imageUrls.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.lg,
                                        ),
                                        child: FeedImagesWidget(
                                          imageUrls: widget.post.imageUrls,
                                        ),
                                      ),
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      child: Text(
                                        '${TimeFormatter.formatAbsoluteTime(postTime)} · ${TimeFormatter.formatRelativeTime(postTime)}',
                                        style: TextStyle(
                                          color: AppColors.mutedForeground,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      color: AppColors.border,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                        vertical: AppSpacing.xs,
                                      ),
                                      child: FeedsActionsBar(
                                        likesCount: _likesCount,
                                        commentsCount:
                                            widget.post.commentsCount,
                                        repostsCount: widget.post.repostsCount,
                                        bookmarksCount:
                                            widget.post.bookmarksCount,
                                        sharesCount: widget.post.sharesCount,
                                        initiallyLiked: _isLiked,
                                        onLikeToggle: _handleLikeToggle,
                                        responsive: false,
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      color: AppColors.border,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(AppSpacing.lg),
                                      child: Text(
                                        '评论',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const FeedsCommentSection(),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.background,
                                        AppColors.background,
                                        AppColors.background,
                                        AppColors.background,
                                        AppColors.background,
                                        AppColors.background,
                                        AppColors.background,
                                        AppColors.background,
                                        AppColors.background,
                                        AppColors.background,
                                      ],
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    behavior: HitTestBehavior.opaque,
                                    onVerticalDragUpdate: (details) {
                                      setState(() {
                                        _dragOffset =
                                            (_dragOffset +
                                                    details.primaryDelta!)
                                                .clamp(0.0, double.infinity);
                                      });
                                    },
                                    onVerticalDragEnd: (details) {
                                      if (_dragOffset > 164 ||
                                          details.primaryVelocity! > 500) {
                                        Navigator.pop(context);
                                      } else {
                                        _snapController.value = _dragOffset;
                                        _snapController.animateTo(
                                          0.0,
                                          curve: Curves.easeOutQuint,
                                        );
                                      }
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 64,
                                      child: Center(
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 28,
                                          child: SvgPicture.string(
                                            '<svg viewBox="0 0 400 24" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg"><path d="M0 0 L200 14 L400 0 V24 H0 Z" fill="currentColor" fill-opacity="0.2"/><path d="M0 0 L200 14 L400 0" fill="none" stroke="currentColor" stroke-width="2.5" stroke-opacity="0.35" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                                            colorFilter: ColorFilter.mode(
                                              AppColors.gray200,
                                              BlendMode.srcIn,
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
