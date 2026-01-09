// 评论页面组件
//
// 独立的评论页面，可在任何场景复用

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ui/effects/effects.dart';
import '../ui/theme/theme.dart';
import 'comment_handler.dart';
import 'models/comment_model.dart';
import 'widgets/widgets.dart';

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
  final CommentModel? rootComment;
  final String? targetCommentId; // 深层链接目标评论 ID
  final String? channelId; // 频道 ID（用于构建链接）
  final MessageHeaderData? messageHeader; // 消息头部数据（非线程视图时显示）
  final Widget Function(int commentCount)? headerBuilder; // 自定义头部构建器

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late final CommentHandler _handler;
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();

  // 高亮状态
  String? _highlightedCommentId;
  bool _hasScrolledToTarget = false;

  @override
  void initState() {
    super.initState();
    _handler = CommentHandler(widget.dataSource);
    _handler.addListener(_onStateChanged);
    _loadComments();
  }

  @override
  void dispose() {
    _handler.removeListener(_onStateChanged);
    _handler.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
      // 评论加载完成后，尝试滚动到目标评论
      _tryScrollToTargetComment();
    }
  }

  Future<void> _loadComments() async {
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

    // 查找目标评论的索引
    int? targetIndex;

    // 检查是否是根评论（线程视图）
    if (state.rootComment?.id == targetId) {
      targetIndex = 0;
    } else if (state.pinnedComment?.id == targetId) {
      // 置顶评论：如果有消息头部则索引为 1，否则为 0
      targetIndex = widget.messageHeader != null ? 1 : 0;
    } else {
      // 在评论列表中查找
      final index = state.comments.indexWhere((c) => c.id == targetId);
      if (index != -1) {
        if (state.isThreadView) {
          // 线程视图：根评论占据索引 0
          targetIndex = index + 1;
        } else {
          // 非线程视图：计算偏移量
          int offset = 0;
          if (widget.messageHeader != null) offset += 1; // 消息头部
          if (state.pinnedComment != null) offset += 1; // 置顶评论
          targetIndex = index + offset;
        }
      }
    }

    if (targetIndex != null) {
      _hasScrolledToTarget = true;
      // 延迟执行滚动，确保列表已渲染
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndexAndHighlight(targetIndex!, targetId);
      });
    }
  }

  /// 滚动到指定索引并高亮
  void _scrollToIndexAndHighlight(int index, String commentId) {
    // 估算每个评论项的高度（约 80-120 像素）
    const estimatedItemHeight = 100.0;
    final targetOffset = index * estimatedItemHeight;

    // 滚动到目标位置
    _scrollController
        .animateTo(
          targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) {
          // 滚动完成后设置高亮
          if (mounted) {
            setState(() {
              _highlightedCommentId = commentId;
            });
          }
        });
  }

  /// 高亮动画完成回调
  void _onHighlightComplete() {
    if (mounted) {
      setState(() {
        _highlightedCommentId = null;
      });
    }
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
        // TODO: 实现转发
        break;
      case CommentMenuAction.forwardNoQuote:
        // TODO: 实现无引用转发
        break;
      case CommentMenuAction.save:
        // TODO: 实现保存消息
        break;
      case CommentMenuAction.share:
        // TODO: 实现分享
        break;
      case CommentMenuAction.detail:
        // TODO: 实现详情
        break;
    }
  }

  /// 复制评论链接
  void _copyCommentLink(CommentModel comment) {
    // 构建评论链接
    String link;
    if (widget.targetType == 'channel_post' && widget.channelId != null) {
      link =
          'https://lesser.app/channel/${widget.channelId}/message/${widget.targetId}/comment/${comment.id}';
    } else if (widget.targetType == 'channel_post') {
      // 没有 channelId 时使用简化链接
      link =
          'https://lesser.app/message/${widget.targetId}/comment/${comment.id}';
    } else {
      link = 'https://lesser.app/post/${widget.targetId}/comment/${comment.id}';
    }
    Clipboard.setData(ClipboardData(text: link));
    _showSnackBar('链接已复制');
  }

  /// 显示 SnackBar 提示
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onViewReplies(CommentModel comment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'comment_thread'),
        builder: (context) => CommentPage(
          targetId: widget.targetId,
          targetType: widget.targetType,
          dataSource: widget.dataSource,
          rootComment: comment,
          channelId: widget.channelId,
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _handler.updateText(text);
    await _handler.submitComment(widget.targetId, widget.targetType);
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final state = _handler.listState;
    final inputState = _handler.inputState;

    // 评论页面主体（不使用 Hero 动画，采用标准页面过渡）
    final body = Column(
      children: [
        Expanded(
          child: CommentList(
            state: state,
            scrollController: _scrollController,
            getDescendantCount: _handler.getDescendantCount,
            highlightedCommentId: _highlightedCommentId,
            messageHeader: widget.messageHeader,
            headerBuilder: widget.headerBuilder,
            onMenuAction: _onMenuAction,
            onLikeTap: _handler.toggleLike,
            onViewReplies: _onViewReplies,
            onHighlightComplete: _onHighlightComplete,
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
    final isThread = widget.rootComment != null;
    final title =
        widget.title ??
        (isThread ? '${state.totalCount} 条回复' : '${state.totalCount} 条评论');

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
        // 返回帖子按钮 - 仅在子评论线程中显示
        if (isThread)
          TextButton(
            onPressed: _returnToPost,
            child: Text(
              '返回帖子',
              style: TextStyle(
                fontSize: 14,
                color: colors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          const SizedBox(width: 48),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 返回帖子 - 弹出所有评论线程页面，返回到第一级评论页
  void _returnToPost() {
    // 弹出所有 comment_thread 页面，直到回到第一级评论页或其他页面
    Navigator.popUntil(context, (route) {
      if (route.isFirst) return true;
      // 如果不是评论线程页面，停止弹出
      return route.settings.name != 'comment_thread';
    });
  }
}
