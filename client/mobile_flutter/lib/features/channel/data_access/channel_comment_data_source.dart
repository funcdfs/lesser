// =============================================================================
// 频道评论数据源
// =============================================================================
//
// 实现公共评论组件的 [CommentDataSource] 接口，为频道消息提供评论数据。
//
// ## 设计说明
//
// 1. **接口实现**：实现 `pkg/comment` 中定义的 `CommentDataSource` 接口，
//    使频道评论可以复用公共评论 UI 组件
//
// 2. **扁平化展示**：评论采用扁平化列表展示（类似 Twitter），
//    而非传统的嵌套树形结构
//
// 3. **循环引用防护**：递归方法使用 `visited` 集合防止循环引用导致无限循环
//
// ## 数据结构
//
// Mock 数据使用两个 Map 存储：
// - `mockComments[messageId]` - 根评论列表
// - `mockReplies[parentId]` - 子评论列表
//
// ## 使用示例
//
// ```dart
// final dataSource = ChannelCommentDataSource(
//   channelId: 'channel_1',
//   currentUserId: 'user_1',
// );
//
// final state = await dataSource.loadComments('message_1', 'channel_message');
// ```

import '../../../pkg/comment/comment.dart';
import '../models/channel_comment_model.dart' as channel;
import 'mock/channel_mock_data.dart';

/// 频道评论数据源
///
/// 实现 [CommentDataSource] 接口，为频道消息提供评论数据。
/// 当前使用 Mock 数据，生产环境应替换为 gRPC 实现。
class ChannelCommentDataSource implements CommentDataSource {
  ChannelCommentDataSource({
    required this.channelId,
    required this.currentUserId,
  });

  /// 所属频道 ID
  final String channelId;

  /// 当前用户 ID（用于标记 isOwn）
  final String currentUserId;

  /// 缓存的子孙评论数量（commentId -> count）
  final Map<String, int> _descendantCounts = {};

  /// 最大递归深度限制，防止恶意数据导致栈溢出
  static const int _maxRecursionDepth = 100;

  // ===========================================================================
  // CommentDataSource 接口实现
  // ===========================================================================

  @override
  Future<CommentListState> loadComments(
    String targetId,
    String targetType,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final rootComments =
        mockComments[targetId] ?? <channel.ChannelCommentModel>[];

    // 收集所有评论（根评论 + 所有子孙评论）- 扁平化展示
    final allComments = <channel.ChannelCommentModel>[];

    for (final rootComment in rootComments) {
      allComments.add(rootComment);
      // 递归收集该根评论的所有子孙
      _collectDescendants(rootComment.id, allComments);
    }

    // 按时间排序（最早的在前）
    allComments.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));

    // 计算子孙数量（用于显示"查看 X 条回复"）
    _calculateDescendantCounts(targetId);

    // 转换为公共评论模型并标记 isOwn
    final comments = allComments.map((c) {
      final model = c.toCommentModel();
      return model.copyWith(isOwn: c.author.id == currentUserId);
    }).toList();

    // 提取置顶评论
    final pinnedIndex = comments.indexWhere((c) => c.isPinned);
    CommentModel? pinnedComment;
    if (pinnedIndex != -1) {
      pinnedComment = comments.removeAt(pinnedIndex);
    }

    return CommentListState(
      comments: comments,
      pinnedComment: pinnedComment,
      totalCount: allComments.length,
      hasMore: false,
    );
  }

  @override
  Future<CommentListState> loadThread(CommentModel rootComment) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 递归收集所有子孙评论
    final allDescendants = <channel.ChannelCommentModel>[];
    _collectDescendants(rootComment.id, allDescendants);

    // 按时间排序
    allDescendants.sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));

    // 转换并标记
    final comments = allDescendants.map((c) {
      final model = c.toCommentModel();
      return model.copyWith(isOwn: c.author.id == currentUserId);
    }).toList();

    return CommentListState(
      comments: comments,
      rootComment: rootComment,
      totalCount: comments.length,
      hasMore: false,
    );
  }

  @override
  Future<CommentListState> loadMoreComments(
    String targetId,
    String targetType,
    String? cursor,
  ) async {
    // Mock: 暂无分页，直接返回空
    await Future.delayed(const Duration(milliseconds: 100));
    return const CommentListState(hasMore: false);
  }

  @override
  int getDescendantCount(String commentId) {
    return _descendantCounts[commentId] ?? 0;
  }

  @override
  Future<void> toggleLike(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock: 直接成功，实际不修改数据
  }

  @override
  Future<CommentModel> submitComment({
    required String targetId,
    required String targetType,
    required String content,
    ReplyTarget? replyTo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 创建新评论（Mock 实现）
    return CommentModel(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      targetId: targetId,
      targetType: targetType,
      author: CommentAuthor(
        id: currentUserId,
        username: 'me',
        displayName: '我',
        avatarUrl: 'https://i.pravatar.cc/100?img=20',
      ),
      content: content,
      replyTo: replyTo,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      isOwn: true,
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock: 直接成功，实际不修改数据
  }

  // ===========================================================================
  // 扩展方法（非接口定义）
  // ===========================================================================

  /// 通过评论 ID 获取根评论模型
  ///
  /// 用于深层链接导航场景：从通知跳转到特定评论时，
  /// 需要先找到该评论所属的根评论，再定位到具体位置。
  Future<CommentModel?> getRootCommentById(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // 在根评论中查找
    for (final entry in mockComments.entries) {
      for (final comment in entry.value) {
        if (comment.id == commentId) {
          return comment.toCommentModel();
        }
      }
    }

    // 在子评论中查找，然后向上追溯根评论
    for (final entry in mockReplies.entries) {
      for (final comment in entry.value) {
        if (comment.id == commentId) {
          return _findRootComment(entry.key);
        }
      }
    }

    return null;
  }

  // ===========================================================================
  // 私有辅助方法
  // ===========================================================================

  /// 递归查找根评论
  ///
  /// 从指定的父评论 ID 开始，向上追溯直到找到根评论。
  /// 使用深度限制和已访问集合防止循环引用导致栈溢出。
  CommentModel? _findRootComment(
    String parentId, {
    int depth = 0,
    Set<String>? visited,
  }) {
    // 深度限制检查
    if (depth >= _maxRecursionDepth) return null;

    // 初始化或复用已访问集合
    final visitedSet = visited ?? <String>{};

    // 循环引用检查
    if (visitedSet.contains(parentId)) return null;
    visitedSet.add(parentId);

    // 检查是否是根评论
    for (final entry in mockComments.entries) {
      for (final comment in entry.value) {
        if (comment.id == parentId) {
          return comment.toCommentModel();
        }
      }
    }

    // 继续向上查找
    for (final entry in mockReplies.entries) {
      for (final comment in entry.value) {
        if (comment.id == parentId) {
          return _findRootComment(
            entry.key,
            depth: depth + 1,
            visited: visitedSet,
          );
        }
      }
    }

    return null;
  }

  /// 递归收集所有子孙评论
  ///
  /// 将指定评论的所有子孙评论添加到 [result] 列表中。
  ///
  /// 参数：
  /// - [parentId] 父评论 ID
  /// - [result] 结果列表（会被修改）
  /// - [depth] 当前递归深度，超过 [_maxRecursionDepth] 时停止
  /// - [visited] 已访问节点集合，防止循环引用导致无限循环
  void _collectDescendants(
    String parentId,
    List<channel.ChannelCommentModel> result, {
    int depth = 0,
    Set<String>? visited,
  }) {
    // 深度限制检查
    if (depth >= _maxRecursionDepth) return;

    // 初始化或复用已访问集合
    final visitedSet = visited ?? <String>{};

    // 循环引用检查
    if (visitedSet.contains(parentId)) return;
    visitedSet.add(parentId);

    final children = mockReplies[parentId];
    if (children == null || children.isEmpty) return;

    for (final child in children) {
      // 跳过已访问的子节点
      if (visitedSet.contains(child.id)) continue;
      result.add(child);
      _collectDescendants(
        child.id,
        result,
        depth: depth + 1,
        visited: visitedSet,
      );
    }
  }

  /// 计算所有评论的子孙数量
  ///
  /// 遍历指定消息的所有根评论，计算每个评论的子孙数量并缓存。
  void _calculateDescendantCounts(String messageId) {
    _descendantCounts.clear();

    final comments = mockComments[messageId] ?? [];
    final visited = <String>{}; // 共享已访问集合
    for (final comment in comments) {
      _calculateDescendantCountRecursive(comment.id, visited: visited);
    }
  }

  /// 递归计算子孙数量
  ///
  /// 返回指定评论的子孙总数，并将结果缓存到 [_descendantCounts]。
  int _calculateDescendantCountRecursive(
    String commentId, {
    int depth = 0,
    required Set<String> visited,
  }) {
    // 深度限制检查
    if (depth >= _maxRecursionDepth) {
      _descendantCounts[commentId] = 0;
      return 0;
    }

    // 循环引用检查
    if (visited.contains(commentId)) {
      _descendantCounts[commentId] = 0;
      return 0;
    }
    visited.add(commentId);

    final children = mockReplies[commentId];
    if (children == null || children.isEmpty) {
      _descendantCounts[commentId] = 0;
      return 0;
    }

    int count = children.length;
    for (final child in children) {
      count += _calculateDescendantCountRecursive(
        child.id,
        depth: depth + 1,
        visited: visited,
      );
    }

    _descendantCounts[commentId] = count;
    return count;
  }
}
