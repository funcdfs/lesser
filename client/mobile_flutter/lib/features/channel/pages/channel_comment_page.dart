// 频道评论页 - 使用公共评论组件

import 'package:flutter/material.dart';
import '../../../pkg/comment/comment.dart';
import '../../../pkg/ui/theme/app_theme.dart';
import '../data_access/channel_comment_data_source.dart';
import '../models/channel_comment_model.dart' as channel;
import '../models/channel_message_model.dart';
import '../widgets/channel_message.dart' show ChannelMessageBubble;

/// 频道评论页
///
/// 封装公共评论页面，提供频道特定的数据源
class ChannelCommentPage extends StatefulWidget {
  const ChannelCommentPage({
    super.key,
    required this.messageId,
    required this.channelId,
    this.message,
    this.rootComment,
    this.rootCommentId,
    this.targetCommentId,
  });

  final String messageId;
  final String channelId;
  final ChannelMessageModel? message; // 原始消息（用于显示消息头部）
  final CommentModel? rootComment;
  final String? rootCommentId; // 根评论 ID（用于深层链接，需要加载根评论）
  final String? targetCommentId; // 深层链接目标评论 ID

  /// 从频道评论模型创建
  static ChannelCommentPage fromChannelComment({
    required String messageId,
    required String channelId,
    required channel.ChannelCommentModel comment,
    String? targetCommentId,
  }) {
    return ChannelCommentPage(
      messageId: messageId,
      channelId: channelId,
      rootComment: _toCommentModel(comment),
      targetCommentId: targetCommentId,
    );
  }

  @override
  State<ChannelCommentPage> createState() => _ChannelCommentPageState();

  /// 转换频道评论模型为通用模型
  static CommentModel _toCommentModel(channel.ChannelCommentModel c) {
    return CommentModel(
      id: c.id,
      targetId: c.messageId,
      targetType: 'channel_message',
      author: CommentAuthor(
        id: c.author.id,
        username: c.author.username,
        displayName: c.author.displayName,
        avatarUrl: c.author.avatarUrl,
        isVerified: c.author.isVerified,
        roleLabel: c.author.roleLabel,
      ),
      content: c.content,
      replyTo: c.replyTo != null
          ? ReplyTarget(
              commentId: c.replyTo!.commentId,
              authorName: c.replyTo!.authorName,
              contentPreview: c.replyTo!.contentPreview,
              isDeleted: c.replyTo!.isDeleted,
            )
          : null,
      replyCount: c.replyCount,
      likeCount: c.likeCount,
      isLiked: c.isLiked,
      createdAtMs: c.createdAtMs,
      isDeleted: c.isDeleted,
      isPinned: c.isPinned,
      isOwn: c.isOwn,
    );
  }
}

class _ChannelCommentPageState extends State<ChannelCommentPage> {
  late final ChannelCommentDataSource _dataSource;
  CommentModel? _rootComment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataSource = ChannelCommentDataSource(channelId: widget.channelId);
    _rootComment = widget.rootComment;

    // 如果提供了 rootCommentId 但没有 rootComment，需要加载
    if (_rootComment == null && widget.rootCommentId != null) {
      _loadRootComment();
    }
  }

  /// 加载根评论
  Future<void> _loadRootComment() async {
    setState(() => _isLoading = true);

    final rootComment = await _dataSource.getRootCommentById(
      widget.rootCommentId!,
    );

    if (mounted) {
      setState(() {
        _rootComment = rootComment;
        _isLoading = false;
      });
    }
  }

  /// 构建消息头部（复用 ChannelMessageBubble）
  Widget _buildMessageHeader(int commentCount) {
    if (widget.message == null) return const SizedBox.shrink();

    final maxWidth = MediaQuery.of(context).size.width * 0.87;

    return Column(
      children: [
        // Part1: 消息气泡（带完整 interactions）
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: IntrinsicWidth(
                child: ChannelMessageBubble(
                  message: widget.message!,
                  onReactionTap: (emoji) {
                    // TODO: 处理反应
                  },
                ),
              ),
            ),
          ),
        ),
        // 评论分隔符
        CountDivider(count: commentCount, label: '条评论'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // 如果正在加载根评论，显示加载状态
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.surfaceBase,
        appBar: AppBar(
          backgroundColor: colors.surfaceBase,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.textTertiary,
          ),
        ),
      );
    }

    // 非线程视图且有消息时，使用自定义 headerBuilder
    final useCustomHeader = _rootComment == null && widget.message != null;

    return CommentPage(
      targetId: widget.messageId,
      targetType: 'channel_message',
      dataSource: _dataSource,
      rootComment: _rootComment,
      channelId: widget.channelId,
      targetCommentId: widget.targetCommentId,
      headerBuilder: useCustomHeader ? _buildMessageHeader : null,
    );
  }
}
