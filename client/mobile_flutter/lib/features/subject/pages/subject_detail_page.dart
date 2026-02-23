// =============================================================================
// 剧集详情页 - Series Detail Page
// =============================================================================
//
// ## 设计目的
// 展示单个剧集的动态列表，支持动态浏览、评论入口、置顶动态等功能。
// 支持深层链接导航，可直接跳转到指定动态并高亮显示。
//
// ## 页面结构
// - AppBar: 毛玻璃效果，显示剧集信息和操作按钮
// - PinnedBanner: 置顶动态横幅（可关闭）
// - PostList: 动态列表（支持日期分隔、高亮定位）
//
// ## 状态管理
// 使用 _DetailPageState 类封装页面状态，通过 copyWith 实现不可变更新。
// 状态包括：剧集数据、动态列表、加载状态、UI 状态等。
//
// ## 深层链接支持
// - highlightPostId: 需要高亮的动态 ID
// - 页面加载完成后自动滚动到目标动态并高亮显示
// - 高亮动画完成后自动清除高亮状态
//
// ## 生命周期处理
// - 异步操作后检查 mounted，防止 setState 调用已销毁的 State
// - Future.delayed 回调中也需要检查 mounted
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../data_access/subject_mock_data_source.dart';
import '../handler/subject_handler.dart';
import '../models/subject_models.dart';
import '../widgets/subject_constants.dart';
import '../widgets/subject_post.dart' show SubjectPostMenuAction;
import '../widgets/detail_app_bar.dart';
import '../widgets/post_list_controller.dart';
import '../widgets/post_list_view.dart';
import '../widgets/pinned_post_banner.dart';
import '../../../pkg/utils/copy_with_utils.dart';
import 'subject_comment_page.dart';

/// 剧集详情页状态
///
/// 使用不可变数据类封装页面状态，通过 copyWith 实现状态更新。
/// 这种模式便于状态追踪和调试，也更符合 Flutter 的声明式 UI 理念。
class _DetailPageState {
  _DetailPageState({
    this.subject,
    this.posts = const [],
    this.isLoading = true,
    this.showPinnedBanner = true,
    this.isMuted = false,
    this.showPosts = false,
    this.highlightedPostId,
  });

  final SubjectModel? subject;
  final List<SubjectPostModel> posts;
  final bool isLoading;
  final bool showPinnedBanner;
  final bool isMuted;
  final bool showPosts;
  final String? highlightedPostId;

  /// 复制并修改指定字段
  _DetailPageState copyWith({
    SubjectModel? subject,
    List<SubjectPostModel>? posts,
    bool? isLoading,
    bool? showPinnedBanner,
    bool? isMuted,
    bool? showPosts,
    Object? highlightedPostId = sentinel,
  }) {
    return _DetailPageState(
      subject: subject ?? this.subject,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      showPinnedBanner: showPinnedBanner ?? this.showPinnedBanner,
      isMuted: isMuted ?? this.isMuted,
      showPosts: showPosts ?? this.showPosts,
      highlightedPostId: highlightedPostId == sentinel
          ? this.highlightedPostId
          : castOrNull<String>(highlightedPostId),
    );
  }
}

/// 剧集详情页
///
/// ## 参数说明
/// - [subjectId]: 剧集 ID（必需）
/// - [initialSubject]: 初始剧集数据（可选，用于 Hero 动画过渡）
/// - [highlightPostId]: 需要高亮的动态 ID（可选，深层链接导航）
class SubjectDetailPage extends StatefulWidget {
  const SubjectDetailPage({
    super.key,
    required this.subjectId,
    this.initialSubject,
    this.highlightPostId,
  });

  final String subjectId;
  final SubjectModel? initialSubject;
  final String? highlightPostId; // 需要高亮的动态 ID（深层链接导航）

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  late final SubjectHandler _handler;
  late final PostListController _listController;
  late final HighlightController _highlightController;
  final _scrollController = ScrollController();
  final _moreButtonKey = GlobalKey();

  late _DetailPageState _state;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _handler = SubjectHandler(SubjectMockDataSource());
    _listController = PostListController();
    _highlightController = HighlightController(
      scrollController: _scrollController,
      onHighlightChanged: (id) {
        if (!_isDisposed && mounted) {
          setState(() {
            _state = _state.copyWith(highlightedPostId: id);
          });
        }
      },
    );

    // 初始化状态（isMuted 从 handler 的 UI 状态获取）
    _state = _DetailPageState(
      subject: widget.initialSubject,
      isMuted: false, // 将在 _loadData 中更新
      isLoading: widget.initialSubject == null,
    );

    _loadData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    _listController.dispose();
    _highlightController.dispose(); // 清理高亮控制器
    _handler.dispose();
    super.dispose();
  }

  /// 加载剧集数据和动态列表
  Future<void> _loadData() async {
    if (_isDisposed) return;

    try {
      final subject =
          _state.subject ?? await _handler.getSubjectDetail(widget.subjectId);

      // 异步操作后检查是否已销毁
      if (_isDisposed) return;

      final posts = await _handler.getPosts(widget.subjectId);

      // 再次检查，防止竞态条件
      if (_isDisposed) return;

      // 合并状态更新
      setState(() {
        _state = _state.copyWith(
          subject: subject,
          posts: posts,
          isMuted: _handler.getUIState(widget.subjectId)?.isMuted ?? false,
          isLoading: false,
        );
      });

      // 更新缓存
      _listController.updateCache(posts);

      // 延迟显示动态
      Future.delayed(AnimDurations.medium, () {
        // Future.delayed 回调中必须检查是否已销毁
        if (_isDisposed) return;
        setState(() => _state = _state.copyWith(showPosts: true));
        // 动态显示后，尝试滚动到目标动态
        _highlightController.scrollToPostAndHighlight(
          targetPostId: widget.highlightPostId,
          listController: _listController,
        );
      });
    } catch (e) {
      if (_isDisposed) return;
      setState(() {
        _state = _state.copyWith(isLoading: false);
      });
      _showSnackBar('加载失败，请稍后重试');
    }
  }

  void _onClosePinnedBanner() {
    setState(() => _state = _state.copyWith(showPinnedBanner: false));
  }

  void _openCommentPage(SubjectPostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectCommentPage(
          postId: post.id,
          subjectId: widget.subjectId,
          post: post,
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showPopupMenu(
      context: context,
      anchorKey: _moreButtonKey,
      items: [
        const PopupMenuItemData(
          icon: Icons.search_rounded,
          label: '搜索',
          value: 'search',
        ),
        PopupMenuItemData(
          icon: _state.isMuted
              ? Icons.notifications_rounded
              : Icons.notifications_off_rounded,
          label: _state.isMuted ? '取消静音' : '静音',
          value: 'mute',
        ),
        const PopupMenuItemData(
          icon: Icons.settings_rounded,
          label: '设置',
          value: 'settings',
        ),
      ],
      onSelected: (value) {
        if (value == 'mute') {
          setState(() => _state = _state.copyWith(isMuted: !_state.isMuted));
        }
      },
    );
  }

  void _handlePostMenuAction(
    SubjectPostMenuAction action,
    SubjectPostModel post,
  ) {
    switch (action) {
      case SubjectPostMenuAction.save:
        _showSnackBar('动态已保存');
        break;
      case SubjectPostMenuAction.forward:
        _showSnackBar('转发功能开发中');
        break;
      case SubjectPostMenuAction.detail:
        _showSnackBar('详情功能开发中');
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToDate(DateTime date) {
    final targetIndex = _state.posts.indexWhere((p) {
      final postDate = DateTime(
        p.createdAt.year,
        p.createdAt.month,
        p.createdAt.day,
      );
      return postDate == date;
    });

    if (targetIndex == -1) return;

    if (!_scrollController.hasClients) return;
    final targetOffset =
        targetIndex * SubjectLayoutConstants.estimatedItemHeight;
    final maxExtent = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, maxExtent),
      duration: SubjectLayoutConstants.scrollDuration,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasPinnedPost = _state.subject?.pinnedPost != null;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      extendBodyBehindAppBar: true,
      appBar: DetailAppBar(
        series: _state.subject,
        seriesId: widget.subjectId,
        moreButtonKey: _moreButtonKey,
        onBack: () => Navigator.of(context).pop(),
        onMoreTap: _showMoreMenu,
      ),
      body: _state.isLoading
          ? const _LoadingView()
          : Stack(
              children: [
                Positioned.fill(
                  child: _buildPostList(colors, hasPinnedPost),
                ),
                if (_state.showPinnedBanner && hasPinnedPost)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                    left: 0,
                    right: 0,
                    child: PinnedPostBanner(
                      content: _state.subject?.pinnedPost?.content ?? '',
                      onClose: _onClosePinnedBanner,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPostList(AppColorScheme colors, bool hasPinnedPost) {
    if (!_state.showPosts) {
      return const SizedBox.shrink();
    }

    final topPadding =
        MediaQuery.paddingOf(context).top +
        kToolbarHeight +
        (_state.showPinnedBanner && hasPinnedPost
            ? SubjectLayoutConstants.pinnedBannerHeight
            : SubjectLayoutConstants.defaultTopPadding);

    return PostListView(
      listController: _listController,
      scrollController: _scrollController,
      highlightController: _highlightController,
      highlightedPostId: _state.highlightedPostId,
      topPadding: topPadding,
      onHighlightComplete: _highlightController.onHighlightComplete,
      onCommentTap: _openCommentPage,
      onMenuAction: _handlePostMenuAction,
      onReactionTap: (emoji) {},
      onDateSelected: _scrollToDate,
    );
  }
}

/// 加载中视图
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: colors.textTertiary,
      ),
    );
  }
}
