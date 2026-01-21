// =============================================================================
// 剧集评论页 - Series Comment Page
// =============================================================================
//
// ## 设计目的
// 封装公共评论组件（pkg/comment），提供剧集特定的数据源和动态头部。
// 支持两种入口模式：
// 1. 动态评论：显示原始动态 + 评论列表
// 2. 线程视图：显示根评论 + 子评论列表（深层链接导航）
//
// ## 数据源
// 使用 SeriesCommentDataSource 作为评论数据源，实现 CommentDataSource 接口。
// 当前使用 Mock 数据，后续可替换为 gRPC 数据源。
//
// ## 深层链接支持
// - rootCommentId: 根评论 ID，用于加载根评论数据
// - targetCommentId: 目标评论 ID，用于滚动定位和高亮
//
// ## 动态头部
// 非线程视图时，使用 SeriesPostBubble 显示原始动态。
// 动态气泡下方显示评论数量分隔符。
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/comment/comment.dart';
import '../data_access/series_mock_data_source.dart';
import '../data_access/series_comment_data_source.dart';
import '../data_access/mock/series_mock_data.dart';
import '../models/series_comment_model.dart' as series;
import '../models/series_post_model.dart';
import '../widgets/series_constants.dart';
import '../widgets/series_post.dart' show SeriesPostBubble;
import '../widgets/comment_page_scaffold.dart';

/// 剧集评论页
///
/// 封装公共评论组件，提供剧集特定的数据源和动态头部。
///
/// ## 参数说明
/// - [postId]: 动态 ID（必需）
/// - [seriesId]: 剧集 ID（必需）
/// - [post]: 原始动态（可选，用于显示动态头部）
/// - [rootComment]: 根评论（可选，线程视图模式）
/// - [rootCommentId]: 根评论 ID（可选，深层链接需要加载根评论）
/// - [targetCommentId]: 目标评论 ID（可选，深层链接滚动定位）
class SeriesCommentPage extends StatefulWidget {
  const SeriesCommentPage({
    super.key,
    required this.postId,
    required this.seriesId,
    this.post,
    this.rootComment,
    this.rootCommentId,
    this.targetCommentId,
  });

  final String postId;
  final String seriesId;
  final SeriesPostModel? post; // 原始动态（用于显示动态头部）
  final CommentModel? rootComment;
  final String? rootCommentId; // 根评论 ID（用于深层链接，需要加载根评论）
  final String? targetCommentId; // 深层链接目标评论 ID

  /// 从剧集评论模型创建
  ///
  /// 便捷工厂方法，将 SeriesCommentModel 转换为通用 CommentModel。
  /// 用于从评论列表点击进入线程视图。
  static SeriesCommentPage fromSeriesComment({
    required String postId,
    required String seriesId,
    required series.SeriesCommentModel comment,
    String? targetCommentId,
  }) {
    return SeriesCommentPage(
      postId: postId,
      seriesId: seriesId,
      rootComment: comment.toCommentModel(),
      targetCommentId: targetCommentId,
    );
  }

  @override
  State<SeriesCommentPage> createState() => _SeriesCommentPageState();
}

class _SeriesCommentPageState extends State<SeriesCommentPage> {
  late final SeriesCommentDataSource _dataSource;
  CommentModel? _rootComment;
  SeriesPostModel? _post;
  late final SeriesMockDataSource _seriesDataSource;
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _seriesDataSource = SeriesMockDataSource();
    // 使用 Mock 数据的当前用户 ID，生产环境应从认证服务获取
    _dataSource = SeriesCommentDataSource(
      seriesId: widget.seriesId,
      currentUserId: mockCurrentUserId,
    );
    _rootComment = widget.rootComment;
    _post = widget.post;

    // 如果提供了 rootCommentId 但没有 rootComment，需要加载
    if (_rootComment == null && widget.rootCommentId != null) {
      _loadRootComment();
    }

    if (_rootComment == null && _post == null) {
      _loadPost();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _dataSource.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await _seriesDataSource.getPosts(widget.seriesId);
      SeriesPostModel? post;
      for (final p in posts) {
        if (p.id == widget.postId) {
          post = p;
          break;
        }
      }

      if (_isDisposed) return;
      if (post == null) {
        setState(() {
          _error = 'post not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _post = post;
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

  /// 构建动态头部（复用 SeriesPostBubble）
  ///
  /// 仅在非线程视图且有动态数据时显示。
  /// 包含动态气泡和评论数量分隔符。
  Widget _buildPostHeader(int commentCount) {
    final post = _post;
    if (post == null) return const SizedBox.shrink();

    // 使用 MediaQuery.sizeOf 替代 MediaQuery.of(context).size，性能更优
    final maxWidth =
        MediaQuery.sizeOf(context).width *
        SeriesLayoutConstants.messageMaxWidthRatio;

    return Column(
      children: [
        // Part1: 动态气泡（带完整 interactions）
        Padding(
          padding: SeriesLayoutConstants.messagePadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: IntrinsicWidth(
                child: SeriesPostBubble(
                  post: post,
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

    // 非线程视图且有动态时，使用自定义 headerBuilder
    final useCustomHeader = _rootComment == null && _post != null;

    return CommentPage(
      targetId: widget.postId,
      targetType: 'series_post',
      dataSource: _dataSource,
      rootComment: _rootComment,
      channelId: widget.seriesId,
      targetCommentId: widget.targetCommentId,
      headerBuilder: useCustomHeader ? _buildPostHeader : null,
    );
  }
}
