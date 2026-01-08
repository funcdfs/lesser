// 频道评论业务逻辑层

import 'package:flutter/foundation.dart';
import '../models/channel_models.dart';
import 'channel_mock_data.dart'
    show mockComments, mockReplies, mockCurrentUserId, mockCurrentUser;

/// 频道评论 Handler
///
/// 当前使用 mock 数据，之后可替换为 gRPC 数据源
class ChannelCommentHandler extends ChangeNotifier {
  CommentListState _listState = const CommentListState();
  CommentInputState _inputState = const CommentInputState();

  CommentListState get listState => _listState;
  CommentInputState get inputState => _inputState;



  /// 加载评论列表
  Future<void> loadComments(String postId) async {
    _listState = _listState.copyWith(loadState: CommentLoadState.loading);
    notifyListeners();

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final comments = mockComments[postId] ?? <ChannelCommentModel>[];

      // 标记当前用户的评论
      final processedComments = comments.map((c) {
        return c.copyWith(isOwn: c.author.id == mockCurrentUserId);
      }).toList();

      // 找出置顶评论
      final pinnedIndex = processedComments.indexWhere((c) => c.isPinned);
      ChannelCommentModel? pinnedComment;
      if (pinnedIndex != -1) {
        pinnedComment = processedComments.removeAt(pinnedIndex);
      }

      _listState = _listState.copyWith(
        comments: processedComments,
        pinnedComment: pinnedComment,
        totalCount: comments.length,
        hasMore: false,
        loadState: CommentLoadState.idle,
      );
    } catch (e) {
      _listState = _listState.copyWith(
        loadState: CommentLoadState.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  /// 加载子评论线程 (Drill-down)
  /// 递归收集所有子孙评论，按时间排序显示
  Future<void> loadThread(ChannelCommentModel rootComment) async {
    _listState = _listState.copyWith(
      loadState: CommentLoadState.loading,
      rootComment: rootComment,
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // 递归收集所有子孙评论
      final allDescendants = <ChannelCommentModel>[];
      _collectDescendants(rootComment.id, allDescendants);

      // 按时间排序（升序，最早的在前）
      allDescendants.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));

      // 标记当前用户的评论
      final processedComments = allDescendants.map((c) {
        return c.copyWith(isOwn: c.author.id == mockCurrentUserId);
      }).toList();

      _listState = _listState.copyWith(
        comments: processedComments,
        totalCount: processedComments.length,
        hasMore: false,
        loadState: CommentLoadState.idle,
      );
    } catch (e) {
      _listState = _listState.copyWith(
        loadState: CommentLoadState.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  /// 递归收集所有子孙评论
  void _collectDescendants(String parentId, List<ChannelCommentModel> result) {
    final children = mockReplies[parentId];
    if (children == null || children.isEmpty) return;
    
    for (final child in children) {
      result.add(child);
      // 递归收集这个评论的子孙
      _collectDescendants(child.id, result);
    }
  }

  /// 获取评论的所有子孙数量（递归计算）
  int getDescendantCount(String commentId) {
    final descendants = <ChannelCommentModel>[];
    _collectDescendants(commentId, descendants);
    return descendants.length;
  }

  /// 加载更多评论
  Future<void> loadMore() async {
    if (_listState.loadState.isLoadingMore || !_listState.hasMore) return;

    _listState = _listState.copyWith(loadState: CommentLoadState.loadingMore);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    // Mock: 没有更多数据
    _listState = _listState.copyWith(
      hasMore: false,
      loadState: CommentLoadState.idle,
    );
    notifyListeners();
  }



  /// 添加反应（乐观更新）
  Future<void> addReaction(String commentId, String emoji) async {
    // 1. 乐观更新
    _listState = _listState.updateComment(
      commentId,
      (c) => c.withReactionToggled(emoji),
    );
    notifyListeners();

    try {
      // 2. 发送请求（Mock: 直接成功）
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // 3. 失败回滚
      _listState = _listState.updateComment(
        commentId,
        (c) => c.withReactionToggled(emoji),
      );
      notifyListeners();
      rethrow;
    }
  }

  /// 设置回复目标
  void setReplyTo(ChannelCommentModel comment) {
    _inputState = _inputState.withReplyTo(
      ReplyTarget(
        commentId: comment.id,
        authorName: comment.author.displayName,
        contentPreview: _truncate(comment.content, 100),
      ),
    );
    notifyListeners();
  }

  /// 取消回复
  void cancelReply() {
    _inputState = _inputState.withReplyTo(null);
    notifyListeners();
  }

  /// 更新输入文本
  void updateText(String text) {
    _inputState = _inputState.copyWith(text: text);
    // 不需要 notifyListeners，输入框自己管理状态
  }

  /// 发表评论
  Future<void> submitComment(String postId) async {
    if (!_inputState.canSubmit) return;

    _inputState = _inputState.copyWith(isSubmitting: true);
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // 创建新评论
      final newComment = ChannelCommentModel(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        channelId: '1',
        author: mockCurrentUser,
        content: _inputState.text,
        replyTo: _inputState.replyTo,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
        isOwn: true,
      );

      // 插入到列表头部
      _listState = _listState.prependComment(newComment);
      _inputState = _inputState.clear();
    } catch (e) {
      _inputState = _inputState.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }

    notifyListeners();
  }

  /// 删除评论
  Future<void> deleteComment(String commentId) async {
    _listState = _listState.softDeleteComment(commentId);
    notifyListeners();

    // Mock: 直接成功
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 清空状态
  void clear() {
    _listState = const CommentListState();
    _inputState = const CommentInputState();
    notifyListeners();
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
