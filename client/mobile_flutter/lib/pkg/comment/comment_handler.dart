// 评论业务逻辑处理器
//
// 抽象类，具体实现由使用方提供数据源

import 'package:flutter/foundation.dart';

import 'models/comment_model.dart';
import 'utils.dart';

/// 评论操作结果
class CommentResult<T> {
  const CommentResult.success(this.data) : error = null;
  const CommentResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

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
  Future<CommentResult<void>> loadMoreComments(
    String targetId,
    String targetType,
  ) async {
    if (_listState.isLoadingMore || !_listState.hasMore) {
      return const CommentResult.success(null);
    }

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
      notifyListeners();
      return const CommentResult.success(null);
    } catch (e) {
      _listState = _listState.copyWith(isLoadingMore: false);
      notifyListeners();
      return CommentResult.failure(e.toString());
    }
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
  ///
  /// 返回 [CommentResult] 表示操作结果，调用方可据此显示错误提示
  Future<CommentResult<void>> toggleLike(String commentId) async {
    // 找到目标评论的索引，避免多次遍历
    final index = _listState.comments.indexWhere((c) => c.id == commentId);
    if (index == -1) {
      return const CommentResult.failure('评论不存在');
    }

    // 保存原始列表用于回滚
    final originalComments = List<CommentModel>.from(_listState.comments);
    final original = originalComments[index];
    final updated = original.withLikeToggled();

    // 乐观更新
    final newComments = List<CommentModel>.from(originalComments);
    newComments[index] = updated;
    _listState = _listState.copyWith(comments: newComments);
    notifyListeners();

    try {
      await _dataSource.toggleLike(commentId);
      return const CommentResult.success(null);
    } catch (e) {
      // 回滚：使用原始列表
      _listState = _listState.copyWith(comments: originalComments);
      notifyListeners();
      return CommentResult.failure(e.toString());
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

  /// 删除评论（乐观更新）
  ///
  /// 返回 [CommentResult] 表示操作结果，调用方可据此显示错误提示
  Future<CommentResult<void>> deleteComment(String commentId) async {
    final index = _listState.comments.indexWhere((c) => c.id == commentId);
    if (index == -1) {
      return const CommentResult.failure('评论不存在');
    }

    // 保存原始列表用于回滚
    final originalComments = List<CommentModel>.from(_listState.comments);
    final original = originalComments[index];

    // 乐观更新
    final newComments = List<CommentModel>.from(originalComments);
    newComments[index] = original.copyWith(isDeleted: true, content: '该评论已删除');
    _listState = _listState.copyWith(comments: newComments);
    notifyListeners();

    try {
      await _dataSource.deleteComment(commentId);
      return const CommentResult.success(null);
    } catch (e) {
      // 回滚：使用原始列表
      _listState = _listState.copyWith(comments: originalComments);
      notifyListeners();
      return CommentResult.failure(e.toString());
    }
  }

  /// 清空状态
  void clear() {
    _listState = const CommentListState();
    _inputState = const CommentInputState();
    notifyListeners();
  }
}
