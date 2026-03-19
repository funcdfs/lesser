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
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../data_access/subject_mock_data_source.dart';
import '../handler/subject_handler.dart';
import '../models/subject_models.dart';
import '../widgets/subject_constants.dart';
import '../widgets/message_item.dart';
import '../widgets/detail_app_bar.dart';
import '../widgets/post_list_controller.dart';
import '../widgets/post_list_view.dart';
import '../widgets/pinned_post_banner.dart';
import '../../../pkg/utils/copy_with_utils.dart';
import 'subject_comment_page.dart';

/// 剧集详情页状态
class _DetailPageState {
  _DetailPageState({
    this.subject,
    this.posts = const [],
    this.topics = const [],
    this.isLoading = true,
    this.showPinnedBanner = true,
    this.isMuted = false,
    this.showPosts = false,
    this.highlightedPostId,
  });

  final SubjectModel? subject;
  final List<MessageModel> posts;
  final List<SubjectTopicModel> topics;
  final bool isLoading;
  final bool showPinnedBanner;
  final bool isMuted;
  final bool showPosts;
  final String? highlightedPostId;

  _DetailPageState copyWith({
    SubjectModel? subject,
    List<MessageModel>? posts,
    List<SubjectTopicModel>? topics,
    bool? isLoading,
    bool? showPinnedBanner,
    bool? isMuted,
    bool? showPosts,
    Object? highlightedPostId = sentinel,
  }) {
    return _DetailPageState(
      subject: subject ?? this.subject,
      posts: posts ?? this.posts,
      topics: topics ?? this.topics,
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

class SubjectDetailPage extends StatefulWidget {
  const SubjectDetailPage({
    super.key,
    required this.subjectId,
    this.initialSubject,
    this.highlightPostId,
  });

  final String subjectId;
  final SubjectModel? initialSubject;
  final String? highlightPostId;

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

    _state = _DetailPageState(
      subject: widget.initialSubject,
      isMuted: false,
      isLoading: widget.initialSubject == null,
    );

    _loadData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    _listController.dispose();
    _highlightController.dispose();
    _handler.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isDisposed) return;

    try {
      final subject =
          _state.subject ?? await _handler.getSubjectDetail(widget.subjectId);

      if (_isDisposed) return;

      final uiState = _handler.getUIState(widget.subjectId);
      final posts = await _handler.getPosts(widget.subjectId);

      if (_isDisposed) return;

      setState(() {
        _state = _state.copyWith(
          subject: subject,
          posts: posts,
          isMuted: uiState?.isMuted ?? false,
          isLoading: false,
        );
      });

      _listController.updateCache(posts);

      Future.delayed(AnimDurations.medium, () {
        if (_isDisposed) return;
        setState(() => _state = _state.copyWith(showPosts: true));
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

  void _openCommentPage(MessageModel post) {
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
    MessageMenuAction action,
    MessageModel post,
  ) {
    switch (action) {
      case MessageMenuAction.save:
        _showSnackBar('动态已保存');
        break;
      case MessageMenuAction.forward:
        _showSnackBar('转发功能开发中');
        break;
      case MessageMenuAction.detail:
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
      body: Stack(
        children: [
          Positioned.fill(
            child: _state.isLoading && !_state.showPosts
                ? const _LoadingView()
                : _buildContent(colors, hasPinnedPost),
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

  Widget _buildContent(AppColorScheme colors, bool hasPinnedPost) {
    if (!_state.showPosts && !_state.isLoading) {
      return const SizedBox.shrink();
    }

    final topPadding =
        MediaQuery.paddingOf(context).top +
        kToolbarHeight +
        (_state.showPinnedBanner && hasPinnedPost
            ? SubjectLayoutConstants.pinnedBannerHeight
            : SubjectLayoutConstants.defaultTopPadding);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (_state.isLoading)
          const SliverFillRemaining(child: _LoadingView())
        else
          SliverPadding(
            padding: EdgeInsets.only(top: topPadding, bottom: 8),
            sliver: PostListViewSliver(
              listController: _listController,
              highlightController: _highlightController,
              highlightedPostId: _state.highlightedPostId,
              onHighlightComplete: _highlightController.onHighlightComplete,
              onCommentTap: _openCommentPage,
              onMenuAction: _handlePostMenuAction,
              onReactionTap: (emoji) {},
              onDateSelected: _scrollToDate,
              posts: _state.posts,
            ),
          ),
      ],
    );
  }
}

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
