// 评论页面组件
//
// 路由层级：
// - 根总览层：第一个打开的评论页面，显示帖子 header + 所有评论
// - 子层：显示某条评论作为 root + 其回复（有 rootComment）
// - 新总览层：引用点击产生，显示帖子 header + 所有评论 + 滚动到目标
//
// 滚动行为：
// - 总览层：置顶 = header（瞬移），置底 = 列表最底部（瞬移）
// - 子层：置顶 = root comment（瞬移），置底 = 列表最底部（瞬移）
//
// 引用跳转：
// - 根总览层：replace 模式，页面内瞬移到对应评论并高亮
// - 子层/新总览层：push 模式，新开总览层，滚动到对应评论并高亮
//
// 返回帖子：
// - pop 所有评论相关页面直到根总览层，并执行置顶（瞬移）

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../link/link_parser.dart';
import '../link/link_service.dart';
import '../ui/effects/effects.dart';
import '../ui/theme/theme.dart';
import 'logic/comment_handler.dart';
import 'logic/comment_navigator.dart';
import 'logic/scroll_controller.dart';
import 'models/comment_model.dart';
import 'widgets/widgets.dart';

// ============================================================================
// 常量定义
// ============================================================================

/// 评论输入框高度 + 安全边距（用于底部对齐时避免遮挡）
const _kInputBarOffset = 70.0;

/// 滚动定位时目标在视口中的位置比例（0.3 = 偏上 30%）
const _kScrollAlignmentRatio = 0.3;

// ============================================================================
// 页面栈管理 - 委托给 CommentNavigator
// ============================================================================

/// 评论页面
class CommentPage extends StatefulWidget {
  const CommentPage({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.dataSource,
    this.title,
    this.rootComment,
    this.targetCommentId,
    this.channelId,
    this.messageHeader,
    this.headerBuilder,
  });

  final String targetId;
  final String targetType;
  final CommentDataSource dataSource;
  final String? title;
  final CommentModel? rootComment; // 子层的 root comment
  final String? targetCommentId; // 深层链接目标评论 ID（用于高亮）
  final String? channelId; // 频道 ID（用于构建链接）
  final MessageHeaderData? messageHeader;
  final Widget Function(int commentCount)? headerBuilder;

  /// 在当前页面内跳转到指定评论（replace 模式）
  ///
  /// 由 LinkService 调用，用于页面内瞬移
  /// 返回 true 表示成功，false 表示没有可用的评论页面
  static bool navigateInPlace(String targetCommentId) {
    return CommentNavigator.instance.navigateInPlace(
      LinkParser.isHeaderAnchor(targetCommentId)
          ? LinkParser.anchorToken(LinkParser.headerAnchor)
          : LinkParser.isBottomAnchor(targetCommentId)
          ? LinkParser.anchorToken(LinkParser.bottomAnchor)
          : targetCommentId,
      alignToBottom: LinkParser.isBottomAnchor(targetCommentId),
    );
  }

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage>
    with WidgetsBindingObserver
    implements CommentPageDelegate {
  late final CommentHandler _handler;
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();

  // 滚动按钮控制器
  CommentScrollController? _scrollButtonController;

  // 高亮状态
  String? _highlightedCommentId;
  bool _highlightHeader = false; // Header 高亮状态
  bool _hasScrolledToTarget = false;

  // 键盘滚动追踪
  bool _isScrollingWithKeyboard = false;

  // 评论 ID 到 GlobalKey 的映射（用于滚动定位）
  final Map<String, GlobalKey> _commentKeys = {};

  // Header 的 GlobalKey
  final _headerKey = GlobalKey();

  /// 是否是子层（线程视图，有 rootComment）
  bool get _isThreadView => widget.rootComment != null;

  /// 是否是总览层（根总览层或新总览层，没有 rootComment）
  bool get _isOverviewLayer => !_isThreadView;

  /// 是否是根总览层（页面栈中的第一个）
  bool get _isRootLayer => CommentNavigator.instance.isRootPage(this);

  /// 是否应该显示"返回帖子"按钮
  bool get _shouldShowReturnButton =>
      CommentNavigator.instance.shouldShowReturnButton(this);

  // ---------------------------------------------------------------------------
  // CommentPageDelegate 实现
  // ---------------------------------------------------------------------------

  /// 通过 Link 系统跳转到指定评论（replace 模式）
  @override
  void navigateToComment(String targetCommentId, {bool alignToBottom = false}) {
    // 特殊锚点直接处理
    if (LinkParser.isHeaderAnchor(targetCommentId)) {
      _jumpToHeaderWithHighlight();
      return;
    }

    if (LinkParser.isBottomAnchor(targetCommentId)) {
      _jumpToBottomWithHighlight();
      return;
    }

    // 普通评论：设置高亮并跳转
    setState(() {
      _highlightedCommentId = targetCommentId;
    });

    // 如果是置底场景且评论 key 不存在，直接跳转到底部
    final key = _commentKeys[targetCommentId];
    if (key?.currentContext == null && alignToBottom) {
      _jumpToBottom();
      return;
    }

    _jumpToComment(targetCommentId, alignToBottom: alignToBottom);
  }

  /// 瞬移到 header
  @override
  void jumpToHeader() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  /// 瞬移到 header 并高亮
  void _jumpToHeaderWithHighlight() {
    // 设置 header 高亮
    setState(() {
      _highlightHeader = true;
    });
    jumpToHeader();
  }

  /// 瞬移到底部
  void _jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// 瞬移到底部并高亮最后一条评论
  void _jumpToBottomWithHighlight() {
    final state = _handler.listState;
    // 获取最后一条评论的 ID
    final lastCommentId = state.comments.isNotEmpty
        ? state.comments.last.id
        : null;

    if (lastCommentId != null) {
      setState(() {
        _highlightedCommentId = lastCommentId;
      });

      // 先跳转到底部，然后在下一帧调整位置
      _jumpToBottom();

      // 等待渲染完成后再微调位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final key = _commentKeys[lastCommentId];
        if (key?.currentContext != null) {
          _jumpToComment(lastCommentId, alignToBottom: true);
        }
      });
    } else {
      _jumpToBottom();
    }
  }

  /// 瞬移到指定评论
  void _jumpToComment(String commentId, {bool alignToBottom = false}) {
    final key = _commentKeys[commentId];
    if (key?.currentContext != null) {
      // 使用 jumpTo 而不是 animateTo，实现瞬移
      final renderObject = key!.currentContext!.findRenderObject();
      if (renderObject is RenderBox) {
        final scrollable = Scrollable.of(key.currentContext!);
        final position = scrollable.position;
        final viewport = position.viewportDimension;

        // 计算目标位置
        final objectOffset = renderObject.localToGlobal(
          Offset.zero,
          ancestor: scrollable.context.findRenderObject(),
        );

        double targetOffset;
        if (alignToBottom) {
          // 底部对齐：目标底部与视口底部对齐，留出空间避免被评论框遮挡
          targetOffset =
              position.pixels +
              objectOffset.dy +
              renderObject.size.height -
              viewport +
              _kInputBarOffset;
        } else {
          // 偏上位置对齐
          targetOffset =
              position.pixels +
              objectOffset.dy -
              viewport * _kScrollAlignmentRatio;
        }

        // 限制在有效范围内
        targetOffset = targetOffset.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );

        _scrollController.jumpTo(targetOffset);
      }
    } else {
      // 评论还没渲染，跳转到底部
      _jumpToBottom();
    }
  }

  @override
  void initState() {
    super.initState();
    _handler = CommentHandler(widget.dataSource);
    _handler.addListener(_onStateChanged);

    WidgetsBinding.instance.addObserver(this);
    _inputFocusNode.addListener(_onFocusChange);

    // 注册到页面栈
    CommentNavigator.instance.registerPage(this);

    // 初始化滚动按钮控制器
    if (widget.channelId != null) {
      _scrollButtonController = CommentScrollController(
        channelId: widget.channelId!,
        messageId: widget.targetId,
      );
    }

    _loadComments();
  }

  @override
  void dispose() {
    // 从页面栈移除
    CommentNavigator.instance.unregisterPage(this);

    WidgetsBinding.instance.removeObserver(this);
    _inputFocusNode.removeListener(_onFocusChange);
    _handler.removeListener(_onStateChanged);
    _handler.dispose();
    _scrollButtonController?.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    _isScrollingWithKeyboard =
        _inputFocusNode.hasFocus && _scrollController.hasClients;
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!_isScrollingWithKeyboard) return;
    _syncScrollWithKeyboard();
  }

  void _syncScrollWithKeyboard() {
    if (!mounted || !_scrollController.hasClients) return;

    final view = View.of(context);
    final bottomInset = view.viewInsets.bottom / view.devicePixelRatio;

    if (bottomInset > 0) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (currentScroll < maxScroll) {
        _scrollController.jumpTo(maxScroll);
      }
    }
  }

  void _onStateChanged() {
    if (!mounted) return;

    final state = _handler.listState;
    _updateScrollAnchors(state);
    _tryScrollToTargetComment();

    setState(() {});
  }

  /// 更新滚动锚点
  void _updateScrollAnchors(CommentListState state) {
    if (_scrollButtonController == null || state.isLoading) return;

    final bottomId = state.comments.isNotEmpty ? state.comments.last.id : null;

    if (_isOverviewLayer) {
      // 总览层：顶部 = header，底部 = 最后一条评论
      _scrollButtonController!.updateAnchorsForOverview(
        bottomCommentId: bottomId,
      );
    } else {
      // 子层：顶部 = root comment，底部 = 最后一条回复
      _scrollButtonController!.updateAnchorsForThread(
        rootCommentId: widget.rootComment!.id,
        bottomCommentId: bottomId,
      );
    }
  }

  Future<void> _loadComments() async {
    // 清理旧的评论 keys，防止内存泄漏
    _commentKeys.clear();

    if (widget.rootComment != null) {
      await _handler.loadThread(widget.rootComment!);
    } else {
      await _handler.loadComments(widget.targetId, widget.targetType);
    }
  }

  /// 尝试滚动到目标评论
  void _tryScrollToTargetComment() {
    if (_hasScrolledToTarget) return;
    if (widget.targetCommentId == null) return;
    if (_handler.listState.isLoading) return;

    final targetId = widget.targetCommentId!;
    final state = _handler.listState;

    if (LinkParser.isHeaderAnchor(targetId) || LinkParser.isBottomAnchor(targetId)) {
      _hasScrolledToTarget = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToTarget(targetId);
        }
      });
      return;
    }

    // 检查目标评论是否在当前列表中
    bool found = false;
    if (state.rootComment?.id == targetId) {
      found = true;
    } else if (state.pinnedComment?.id == targetId) {
      found = true;
    } else if (state.comments.any((c) => c.id == targetId)) {
      found = true;
    }

    if (found) {
      _hasScrolledToTarget = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToTarget(targetId);
        }
      });
    }
  }

  /// 滚动到指定目标
  ///
  /// [targetId] 目标 ID，可以是：
  /// - [LinkParser.headerAnchor]：滚动到 header（置顶）
  /// - [LinkParser.bottomAnchor]：滚动到底部
  /// - 评论 ID：滚动到对应评论
  ///
  /// [alignToBottom] 是否将目标对齐到视口底部（置底场景）
  void _scrollToTarget(String targetId, {bool alignToBottom = false}) {
    // 特殊处理：header（总览层置顶）
    if (LinkParser.isHeaderAnchor(targetId)) {
      // 设置 header 高亮
      setState(() {
        _highlightHeader = true;
      });

      if (_headerKey.currentContext != null) {
        Scrollable.ensureVisible(
          _headerKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      } else {
        // header 还没渲染，滚动到顶部
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
      return;
    }

    // 特殊处理：bottom（置底）
    if (LinkParser.isBottomAnchor(targetId)) {
      // 高亮最后一条评论
      final state = _handler.listState;
      final lastCommentId = state.comments.isNotEmpty
          ? state.comments.last.id
          : null;

      if (lastCommentId != null) {
        setState(() {
          _highlightedCommentId = lastCommentId;
        });
        // 滚动到最后一条评论，定位在视口底部靠上位置（避免被评论框遮挡）
        final key = _commentKeys[lastCommentId];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.85, // 底部靠上位置，避免被评论框遮挡
          );
          return;
        }
      }

      // 没有评论或 key 未渲染，直接滚动到底部
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    // 设置高亮
    setState(() {
      _highlightedCommentId = targetId;
    });

    // 滚动到评论
    final key = _commentKeys[targetId];
    if (key?.currentContext != null) {
      // alignment: 0.0 = 顶部对齐，1.0 = 底部对齐，0.3 = 偏上位置
      final alignment = alignToBottom ? 1.0 : 0.3;
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: alignment,
      );
    } else {
      // 评论的 key 还没渲染，尝试滚动到底部（置底场景）
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// 高亮动画完成回调
  void _onHighlightComplete() {
    if (mounted) {
      setState(() {
        _highlightedCommentId = null;
      });
    }
  }

  /// Header 高亮动画完成回调
  void _onHeaderHighlightComplete() {
    if (mounted) {
      setState(() {
        _highlightHeader = false;
      });
    }
  }

  /// 注册评论的 GlobalKey
  GlobalKey _getCommentKey(String commentId) {
    return _commentKeys.putIfAbsent(commentId, () => GlobalKey());
  }

  /// 处理菜单操作
  void _onMenuAction(CommentModel comment, CommentMenuAction action) {
    switch (action) {
      case CommentMenuAction.reply:
        _handler.setReplyTo(comment);
        _inputFocusNode.requestFocus();
        break;
      case CommentMenuAction.copy:
        Clipboard.setData(ClipboardData(text: comment.content));
        _showSnackBar('已复制到剪贴板');
        break;
      case CommentMenuAction.copyLink:
        _copyCommentLink(comment);
        break;
      case CommentMenuAction.forward:
      case CommentMenuAction.forwardNoQuote:
      case CommentMenuAction.save:
      case CommentMenuAction.share:
      case CommentMenuAction.detail:
        // TODO: 实现其他操作
        break;
    }
  }

  void _copyCommentLink(CommentModel comment) {
    final channelId = widget.channelId;
    if (channelId == null) {
      _showSnackBar('当前场景不支持复制评论链接');
      return;
    }

    final link = LinkParser.buildCommentUrl(
      channelId,
      widget.targetId,
      comment.id,
    );
    Clipboard.setData(ClipboardData(text: link));
    _showSnackBar('链接已复制');
  }

  void _showSnackBar(String message) {
    final colors = AppColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: colors.textPrimary)),
        backgroundColor: colors.surfaceElevated,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onLikeTap(String commentId) async {
    final result = await _handler.toggleLike(commentId);
    if (result.isFailure && mounted) {
      _showSnackBar('点赞失败: ${result.error}');
    }
  }

  /// 查看回复 - 打开新的子层页面
  void _onViewReplies(CommentModel comment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentPage(
          targetId: widget.targetId,
          targetType: widget.targetType,
          dataSource: widget.dataSource,
          rootComment: comment,
          channelId: widget.channelId,
          messageHeader: widget.messageHeader,
          headerBuilder: widget.headerBuilder,
        ),
      ),
    );
  }

  /// 引用点击 - 通过 Link 系统跳转到总览层的对应评论位置
  ///
  /// - 根总览层：replace 模式，页面内瞬移到对应评论
  /// - 子层/新总览层：push 模式，新开总览层并定位到对应评论
  void _onQuoteTap(String commentId) {
    if (widget.channelId == null) return;

    final url = LinkParser.buildCommentUrl(
      widget.channelId!,
      widget.targetId,
      commentId,
    );

    if (_isRootLayer) {
      // 根总览层：replace 模式，页面内瞬移
      LinkService.instance.navigate(
        context,
        url,
        mode: LinkNavigateMode.replace,
      );
    } else {
      // 子层/新总览层：push 模式，新开总览层
      LinkService.instance.navigate(context, url, mode: LinkNavigateMode.push);
    }
  }

  Future<void> _onSubmit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _handler.updateText(text);
    await _handler.submitComment(widget.targetId, widget.targetType);
    _inputController.clear();

    final state = _handler.listState;
    if (state.comments.isNotEmpty) {
      _scrollButtonController?.onNewMessage(state.comments.last.id);
    }
  }

  /// 返回帖子 - 委托给 CommentNavigator
  void _returnToPost() {
    CommentNavigator.instance.returnToPost(context, this);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final state = _handler.listState;
    final inputState = _handler.inputState;

    final commentList = CommentList(
      state: state,
      scrollController: _scrollController,
      getDescendantCount: _handler.getDescendantCount,
      highlightedCommentId: _highlightedCommentId,
      highlightHeader: _highlightHeader,
      channelId: widget.channelId,
      messageId: widget.targetId,
      messageHeader: widget.messageHeader,
      headerBuilder: widget.headerBuilder != null
          ? (count) => KeyedSubtree(
              key: _headerKey,
              child: HighlightEffect(
                isHighlighted: _highlightHeader,
                onHighlightComplete: _onHeaderHighlightComplete,
                child: widget.headerBuilder!(count),
              ),
            )
          : null,
      headerKey: widget.headerBuilder == null ? _headerKey : null,
      onMenuAction: _onMenuAction,
      onLikeTap: _onLikeTap,
      onViewReplies: _onViewReplies,
      onHighlightComplete: _onHighlightComplete,
      onHeaderHighlightComplete: _onHeaderHighlightComplete,
      getCommentKey: _getCommentKey,
      onQuoteTap: _onQuoteTap,
    );

    final body = Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              commentList,
              if (_scrollButtonController != null)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: ScrollButtons(controller: _scrollButtonController!),
                ),
            ],
          ),
        ),
        CommentInputBar(
          controller: _inputController,
          focusNode: _inputFocusNode,
          replyTo: inputState.replyTo,
          isSubmitting: inputState.isSubmitting,
          onSubmit: _onSubmit,
          onCancelReply: _handler.cancelReply,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: _buildAppBar(colors, state),
      body: body,
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppColorScheme colors,
    CommentListState state,
  ) {
    final title =
        widget.title ??
        (_isThreadView ? '${state.totalCount} 条回复' : '${state.totalCount} 条评论');

    return FrostedAppBar(
      blur: 20,
      opacity: 0.8,
      border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: colors.textPrimary,
          size: 22,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
      actions: [
        // 返回帖子按钮 - 只在非根总览层且页面栈有多个页面时显示
        if (_shouldShowReturnButton)
          TapScale(
            onTap: _returnToPost,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '返回帖子',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          const SizedBox(width: 48),
        const SizedBox(width: 8),
      ],
    );
  }
}
