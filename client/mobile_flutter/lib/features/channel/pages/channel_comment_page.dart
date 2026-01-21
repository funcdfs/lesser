// =============================================================================
// 频道评论页 - Channel Comment Page
// =============================================================================
//
// ## 设计目的
// 封装公共评论组件（pkg/comment），提供频道特定的数据源和消息头部。
// 支持两种入口模式：
// 1. 消息评论：显示原始消息 + 评论列表
// 2. 线程视图：显示根评论 + 子评论列表（深层链接导航）
//
// ## 数据源
// 使用 ChannelCommentDataSource 作为评论数据源，实现 CommentDataSource 接口。
// 当前使用 Mock 数据，后续可替换为 gRPC 数据源。
//
// ## 深层链接支持
// - rootCommentId: 根评论 ID，用于加载根评论数据
// - targetCommentId: 目标评论 ID，用于滚动定位和高亮
//
// ## 消息头部
// 非线程视图时，使用 ChannelMessageBubble 显示原始消息。
// 消息气泡下方显示评论数量分隔符。
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/comment/comment.dart';
import '../data_access/channel_mock_data_source.dart';
import '../data_access/channel_comment_data_source.dart';
import '../data_access/mock/channel_mock_data.dart';
import '../models/channel_comment_model.dart' as channel;
import '../models/channel_message_model.dart';
import '../widgets/channel_constants.dart';
import '../widgets/channel_message.dart' show ChannelMessageBubble;
import '../widgets/comment_page_scaffold.dart';

/// 频道评论页
///
/// 封装公共评论组件，提供频道特定的数据源和消息头部。
///
/// ## 参数说明
/// - [messageId]: 消息 ID（必需）
/// - [channelId]: 频道 ID（必需）
/// - [message]: 原始消息（可选，用于显示消息头部）
/// - [rootComment]: 根评论（可选，线程视图模式）
/// - [rootCommentId]: 根评论 ID（可选，深层链接需要加载根评论）
/// - [targetCommentId]: 目标评论 ID（可选，深层链接滚动定位）
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
  ///
  /// 便捷工厂方法，将 ChannelCommentModel 转换为通用 CommentModel。
  /// 用于从评论列表点击进入线程视图。
  static ChannelCommentPage fromChannelComment({
    required String messageId,
    required String channelId,
    required channel.ChannelCommentModel comment,
    String? targetCommentId,
  }) {
    return ChannelCommentPage(
      messageId: messageId,
      channelId: channelId,
      rootComment: comment.toCommentModel(),
      targetCommentId: targetCommentId,
    );
  }

  @override
  State<ChannelCommentPage> createState() => _ChannelCommentPageState();
}

class _ChannelCommentPageState extends State<ChannelCommentPage> {
  late final ChannelCommentDataSource _dataSource;
  CommentModel? _rootComment;
  ChannelMessageModel? _message;
  late final ChannelMockDataSource _channelDataSource;
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _channelDataSource = ChannelMockDataSource();
    // 使用 Mock 数据的当前用户 ID，生产环境应从认证服务获取
    _dataSource = ChannelCommentDataSource(
      channelId: widget.channelId,
      currentUserId: mockCurrentUserId,
    );
    _rootComment = widget.rootComment;
    _message = widget.message;

    // 如果提供了 rootCommentId 但没有 rootComment，需要加载
    if (_rootComment == null && widget.rootCommentId != null) {
      _loadRootComment();
    }

    if (_rootComment == null && _message == null) {
      _loadMessage();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _dataSource.dispose();
    super.dispose();
  }

  Future<void> _loadMessage() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final messages = await _channelDataSource.getMessages(widget.channelId);
      ChannelMessageModel? message;
      for (final m in messages) {
        if (m.id == widget.messageId) {
          message = m;
          break;
        }
      }

      if (_isDisposed) return;
      if (message == null) {
        setState(() {
          _error = 'message not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _message = message;
        _isLoading = false;
      });
    } catch (e) {
      if (_isDisposed) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRootComment() async {
    if (_isDisposed) return;

    final rootCommentId = widget.rootCommentId;
    if (rootCommentId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rootComment = await _dataSource.getRootCommentById(rootCommentId);

      if (_isDisposed) return;

      setState(() {
        _rootComment = rootComment;
        _isLoading = false;
      });
    } catch (e) {
      if (_isDisposed) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 构建消息头部（复用 ChannelMessageBubble）
  ///
  /// 仅在非线程视图且有消息数据时显示。
  /// 包含消息气泡和评论数量分隔符。
  Widget _buildMessageHeader(int commentCount) {
    final message = _message;
    if (message == null) return const SizedBox.shrink();

    // 使用 MediaQuery.sizeOf 替代 MediaQuery.of(context).size，性能更优
    final maxWidth =
        MediaQuery.sizeOf(context).width *
        ChannelLayoutConstants.messageMaxWidthRatio;

    return Column(
      children: [
        // Part1: 消息气泡（带完整 interactions）
        Padding(
          padding: ChannelLayoutConstants.messagePadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: IntrinsicWidth(
                child: ChannelMessageBubble(
                  message: message,
                  onReactionTap: (emoji) {
                    // 反应功能待实现
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
    // 如果正在加载根评论或出错，使用统一脚手架
    if (_isLoading || _error != null) {
      return CommentPageScaffold(
        isLoading: _isLoading,
        error: _error,
        onRetry: _loadRootComment,
        body: const SizedBox.shrink(),
      );
    }

    // 非线程视图且有消息时，使用自定义 headerBuilder
    final useCustomHeader = _rootComment == null && _message != null;

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
