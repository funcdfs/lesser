// 频道评论页 - 仿 Telegram 风格（支持嵌套回复）

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/avatar_button.dart';
import '../handler/channel_comment_handler.dart';
import '../models/channel_models.dart';

/// 用户名颜色池（TG 风格）
const _nameColors = [
  Color(0xFFD4726A), // 柔红
  Color(0xFF6B9E78), // 柔绿
  Color(0xFF5B8EC9), // 柔蓝
  Color(0xFFD4A056), // 柔橙
  Color(0xFF9B7BB8), // 柔紫
  Color(0xFF4AAFB8), // 柔青
  Color(0xFFCB7A9E), // 柔粉
  Color(0xFF8BAD6E), // 柔黄绿
];

Color _getNameColor(String id) {
  return _nameColors[id.hashCode.abs() % _nameColors.length];
}

/// 频道评论页
class ChannelCommentPage extends StatefulWidget {
  const ChannelCommentPage({
    super.key,
    required this.postId,
    required this.channelId,
    this.postPreview,
    this.rootComment,
  });

  final String postId;
  final String channelId;
  final String? postPreview;
  final ChannelCommentModel? rootComment;

  @override
  State<ChannelCommentPage> createState() => _ChannelCommentPageState();
}

class _ChannelCommentPageState extends State<ChannelCommentPage> {
  final _handler = ChannelCommentHandler();
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _handler.addListener(_onStateChanged);
    _loadComments();
  }

  @override
  void dispose() {
    _handler.removeListener(_onStateChanged);
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadComments() async {
    if (widget.rootComment != null) {
      await _handler.loadThread(widget.rootComment!);
    } else {
      await _handler.loadComments(widget.postId);
    }
  }

  void _onReply(ChannelCommentModel comment) {
    _handler.setReplyTo(comment);
    _inputFocusNode.requestFocus();
  }

  void _onCancelReply() {
    _handler.cancelReply();
  }

  Future<void> _onSubmit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _handler.updateText(text);
    await _handler.submitComment(widget.postId);
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final state = _handler.listState;
    final inputState = _handler.inputState;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: _buildAppBar(colors),
      body: Column(
        children: [
          Expanded(child: _buildCommentList(colors, state)),
          _buildInputBar(colors, inputState),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColorScheme colors) {
    final state = _handler.listState;
    return AppBar(
      backgroundColor: colors.surfaceElevated,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.rootComment != null ? '回复详情' : '评论',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          if (state.totalCount > 0)
            Text(
              '${state.totalCount} 条评论',
              style: TextStyle(fontSize: 13, color: colors.textTertiary),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentList(AppColorScheme colors, CommentListState state) {
    if (state.loadState.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.textTertiary,
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: colors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无评论',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '成为第一个评论的人',
              style: TextStyle(fontSize: 14, color: colors.textTertiary),
            ),
          ],
        ),
      );
    }

    // 线程视图：Root 评论作为顶部上下文（不显示“查看回复”按钮）
    // 子项为交互式 _CommentThread 组件
    final isThreadView = state.rootComment != null;

    // 非线程视图：构建显示的评论列表
    final allComments = <ChannelCommentModel>[];
    if (!isThreadView) {
      if (state.pinnedComment != null) {
        allComments.add(state.pinnedComment!);
      }
      allComments.addAll(state.comments);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: isThreadView
          ? state.comments.length + 1 // +1 for root context header
          : allComments.length,
      itemBuilder: (context, index) {
        if (isThreadView) {
          if (index == 0) {
            // Root：显示为上下文标题
            return _RootCommentHeader(
              comment: state.rootComment!,
              onReply: _onReply,
              handler: _handler,
            );
          }
          // 子评论：如果存在子回复，显示“查看回复”按钮
          final childIndex = index - 1;
          final comment = state.comments[childIndex];
          return _CommentThread(
            comment: comment,
            isPinned: false,
            handler: _handler,
            onReply: _onReply,
          );
        } else {
          // 普通评论列表
          final comment = allComments[index];
          final isPinned = state.pinnedComment != null && index == 0;
          return _CommentThread(
            comment: comment,
            isPinned: isPinned,
            handler: _handler,
            onReply: _onReply,
          );
        }
      },
    );
  }

  Widget _buildInputBar(AppColorScheme colors, CommentInputState inputState) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (inputState.isReplying) _buildReplyBar(colors, inputState),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: colors.surfaceBase,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _inputController,
                        focusNode: _inputFocusNode,
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '发送评论...',
                          hintStyle: TextStyle(color: colors.textTertiary),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: 5,
                        minLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TapScale(
                    onTap: inputState.isSubmitting ? null : _onSubmit,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.comment,
                        shape: BoxShape.circle,
                      ),
                      child: inputState.isSubmitting
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBar(AppColorScheme colors, CommentInputState inputState) {
    final target = inputState.replyTo!;
    final barColor = _getNameColor(target.commentId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceBase,
        border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 32,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '回复 ${target.authorName}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  target.contentPreview,
                  style: TextStyle(fontSize: 13, color: colors.textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TapScale(
            onTap: _onCancelReply,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 根评论头部（线程视图上下文，不含“查看回复”按钮）
// ============================================================================

class _RootCommentHeader extends StatelessWidget {
  const _RootCommentHeader({
    required this.comment,
    required this.onReply,
    required this.handler,
  });

  final ChannelCommentModel comment;
  final void Function(ChannelCommentModel) onReply;
  final ChannelCommentHandler handler;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment bubble (same as normal)
        _CommentBubble(
          comment: comment,
          isPinned: false,
          onReply: () => onReply(comment),
          onReaction: (emoji) => handler.addReaction(comment.id, emoji),
        ),
        // Divider to separate root from children
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 1,
            color: colors.divider,
          ),
        ),
        // Label for replies section
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            '${handler.getDescendantCount(comment.id)} 条回复',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 评论线程（交互式，包含“查看回复”按钮）
// ============================================================================

class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.comment,
    this.isPinned = false,
    required this.handler,
    required this.onReply,
  });

  final ChannelCommentModel comment;
  final bool isPinned;
  final ChannelCommentHandler handler;
  final void Function(ChannelCommentModel) onReply;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主评论
        _CommentBubble(
          comment: comment,
          isPinned: isPinned,
          onReply: () => onReply(comment),
          onReaction: (emoji) => handler.addReaction(comment.id, emoji),
        ),
        // 查看回复按钮 / 子评论列表
        if (comment.hasReplies) ...[
             _buildViewRepliesButton(context, colors),
        ],
      ],
    );
  }

  Widget _buildViewRepliesButton(BuildContext context, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, top: 4, bottom: 8),
      child: TapScale(
        onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChannelCommentPage(
                  postId: comment.postId,
                  channelId: comment.channelId,
                  rootComment: comment,
                ),
              ),
            );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
               Icon(
                Icons.turn_right_rounded,
                size: 14,
                color: colors.textTertiary,
              ),
            const SizedBox(width: 6),
            Text(
              '查看 ${handler.getDescendantCount(comment.id)} 条回复',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 评论气泡
// ============================================================================

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({
    required this.comment,
    this.isPinned = false,
    this.isReply = false,
    required this.onReply,
    required this.onReaction,
    this.onQuoteTap,
  });

  final ChannelCommentModel comment;
  final bool isPinned;
  final bool isReply;
  final VoidCallback onReply;
  final void Function(String emoji) onReaction;
  final VoidCallback? onQuoteTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final nameColor = _getNameColor(comment.author.id);
    final avatarSize = isReply ? 32.0 : 40.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AvatarButton(
              imageUrl: comment.author.avatarUrl,
              size: avatarSize,
              placeholder: comment.author.displayName.isNotEmpty
                  ? comment.author.displayName[0]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          // 气泡
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: _buildNameRow(colors, nameColor),
                        ),
                        if (comment.replyTo != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                            child: TapScale(
                              onTap: onQuoteTap,
                              scale: 0.98,
                              child: _buildQuote(colors),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: _buildContent(colors),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                          child: _buildFooter(colors),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isPinned)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin_rounded,
                          size: 12,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '置顶',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameRow(AppColorScheme colors, Color nameColor) {
    final author = comment.author;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          author.displayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: nameColor,
          ),
        ),
        if (author.roleLabel != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: nameColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              author.roleLabel!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: nameColor,
              ),
            ),
          ),
        ],
        if (author.isVerified) ...[
          const SizedBox(width: 4),
          Icon(Icons.verified_rounded, size: 14, color: colors.comment),
        ],
      ],
    );
  }

  Widget _buildQuote(AppColorScheme colors) {
    final target = comment.replyTo!;
    final quoteColor = _getNameColor(target.commentId);

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: quoteColor, width: 2)),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            target.authorName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: quoteColor,
            ),
          ),
          Text(
            target.isDeleted ? '消息已删除' : target.contentPreview,
            style: TextStyle(fontSize: 12, color: colors.textTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppColorScheme colors) {
    if (comment.isDeleted) {
      return Text(
        '该评论已删除',
        style: TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          color: colors.textDisabled,
        ),
      );
    }
    return Text(
      comment.content,
      style: TextStyle(fontSize: 15, height: 1.35, color: colors.textPrimary),
    );
  }

  /// 底部栏：时间 + 表情回应
  Widget _buildFooter(AppColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 时间
        Text(
          _formatTime(comment.createdAt),
          style: TextStyle(fontSize: 11, color: colors.textTertiary),
        ),
        // 反应（表情芯片）
        if (!comment.isDeleted && comment.reactionStats.hasReactions) ...[
          const SizedBox(width: 10),
          ...comment.reactionStats.toSummaryList(comment.myReaction).take(3).map(
            (r) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TapScale(
                onTap: () => onReaction(r.emoji),
                scale: 0.92,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: r.isSelected
                        ? colors.interactive.withValues(alpha: 0.12)
                        : colors.surfaceBase,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(r.emoji, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 2),
                      Text(
                        r.formattedCount,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: r.isSelected ? colors.interactive : colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    // 今天：显示具体时间 (HH:mm)
    if (diff.inHours < 24 && time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    // 昨天
    if (diff.inDays == 1 || (diff.inHours < 48 && time.day == now.day - 1)) {
      return '昨天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    // 本周
    if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    }
    // 今年
    if (time.year == now.year) {
      return '${time.month}/${time.day}';
    }
    return '${time.year}/${time.month}/${time.day}';
  }
}
