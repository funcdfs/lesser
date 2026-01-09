// 评论业务逻辑处理器
//
// 抽象类，具体实现由使用方提供数据源

import 'package:flutter/foundation.dart';

import 'models/comment_model.dart';
import 'utils.dart';

/// 评论数据源接口
abstract class CommentDataSource {
  /// 加载评论列表
  Future<CommentListState> loadComments(String targetId, String targetType);

  /// 加载更多评论
  Future<CommentListState> loadMoreComments(
    String targetId,
    String targetType,
    String? cursor,
  );

  /// 加载子评论线程
  Future<CommentListState> loadThread(CommentModel rootComment);

  /// 获取评论的所有子孙数量
  int getDescendantCount(String commentId);

  /// 切换点赞
  Future<void> toggleLike(String commentId);

  /// 发表评论
  Future<CommentModel> submitComment({
    required String targetId,
    required String targetType,
    required String content,
    ReplyTarget? replyTo,
  });

  /// 删除评论
  Future<void> deleteComment(String commentId);
}

/// 评论处理器
class CommentHandler extends ChangeNotifier {
  CommentHandler(this._dataSource);

  final CommentDataSource _dataSource;

  CommentListState _listState = const CommentListState();
  CommentInputState _inputState = const CommentInputState();

  CommentListState get listState => _listState;
  CommentInputState get inputState => _inputState;

  /// 加载评论列表
  Future<void> loadComments(String targetId, String targetType) async {
    _listState = _listState.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      _listState = await _dataSource.loadComments(targetId, targetType);
    } catch (e) {
      _listState = _listState.copyWith(isLoading: false, error: e.toString());
    }

    notifyListeners();
  }

  /// 加载更多评论
  Future<void> loadMoreComments(String targetId, String targetType) async {
    if (_listState.isLoadingMore || !_listState.hasMore) return;

    _listState = _listState.copyWith(isLoadingMore: true);
    notifyListeners();

    try {
      final moreState = await _dataSource.loadMoreComments(
        targetId,
        targetType,
        _listState.cursor,
      );
      _listState = _listState.copyWith(
        comments: [..._listState.comments, ...moreState.comments],
        hasMore: moreState.hasMore,
        cursor: moreState.cursor,
        isLoadingMore: false,
      );
    } catch (e) {
      _listState = _listState.copyWith(isLoadingMore: false);
    }

    notifyListeners();
  }

  /// 加载子评论线程
  Future<void> loadThread(CommentModel rootComment) async {
    _listState = _listState.copyWith(
      isLoading: true,
      rootComment: rootComment,
      error: null,
    );
    notifyListeners();

    try {
      _listState = await _dataSource.loadThread(rootComment);
    } catch (e) {
      _listState = _listState.copyWith(isLoading: false, error: e.toString());
    }

    notifyListeners();
  }

  /// 获取评论的所有子孙数量
  int getDescendantCount(String commentId) {
    return _dataSource.getDescendantCount(commentId);
  }

  /// 切换点赞（乐观更新）
  Future<void> toggleLike(String commentId) async {
    // 找到目标评论的索引，避免多次遍历
    final index = _listState.comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    // 乐观更新
    final original = _listState.comments[index];
    final updated = original.withLikeToggled();
    final comments = List<CommentModel>.from(_listState.comments);
    comments[index] = updated;
    _listState = _listState.copyWith(comments: comments);
    notifyListeners();

    try {
      await _dataSource.toggleLike(commentId);
    } catch (e) {
      // 回滚：直接用原始对象
      comments[index] = original;
      _listState = _listState.copyWith(comments: List.unmodifiable(comments));
      notifyListeners();
      rethrow;
    }
  }

  /// 设置回复目标
  void setReplyTo(CommentModel comment) {
    _inputState = _inputState.copyWith(
      replyTo: ReplyTarget(
        commentId: comment.id,
        authorName: comment.author.displayName,
        contentPreview: truncateText(comment.content, 100),
      ),
    );
    notifyListeners();
  }

  /// 取消回复
  void cancelReply() {
    _inputState = _inputState.clearReplyTo();
    notifyListeners();
  }

  /// 更新输入文本
  void updateText(String text) {
    _inputState = _inputState.copyWith(text: text);
  }

  /// 发表评论
  Future<void> submitComment(String targetId, String targetType) async {
    if (!_inputState.canSubmit) return;

    _inputState = _inputState.copyWith(isSubmitting: true);
    notifyListeners();

    try {
      final newComment = await _dataSource.submitComment(
        targetId: targetId,
        targetType: targetType,
        content: _inputState.text,
        replyTo: _inputState.replyTo,
      );

      // 追加到列表末尾（按时间升序排列，新评论在最后）
      final comments = [..._listState.comments, newComment];
      _listState = _listState.copyWith(
        comments: comments,
        totalCount: _listState.totalCount + 1,
      );
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
    final index = _listState.comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    // 保存原始状态用于回滚
    final original = _listState.comments[index];
    final comments = List<CommentModel>.from(_listState.comments);
    comments[index] = original.copyWith(isDeleted: true, content: '该评论已删除');
    _listState = _listState.copyWith(comments: comments);
    notifyListeners();

    try {
      await _dataSource.deleteComment(commentId);
    } catch (e) {
      // 回滚
      comments[index] = original;
      _listState = _listState.copyWith(comments: List.unmodifiable(comments));
      notifyListeners();
      rethrow;
    }
  }

  /// 清空状态
  void clear() {
    _listState = const CommentListState();
    _inputState = const CommentInputState();
    notifyListeners();
  }
}
