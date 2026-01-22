// =============================================================================
// 动态列表控制器
// =============================================================================
//
// 管理动态列表的缓存、日期分组和滚动定位逻辑。
//
// ## 设计目的
//
// 1. **性能优化**：避免在 build 方法中重复计算列表项和日期分组
// 2. **精确定位**：支持滚动到指定动态并高亮显示（深层链接导航）
// 3. **内存管理**：使用 LRU 策略缓存 GlobalKey，防止内存无限增长
//

import 'package:flutter/material.dart';
import '../models/subject_post_model.dart';
import 'subject_constants.dart';

// =============================================================================
// 动态列表缓存控制器
// =============================================================================

/// 列表项类型（日期分隔符或动态）
sealed class ListItem {}

/// 日期分隔符项
class DateItem extends ListItem {
  DateItem(this.date);
  final DateTime date;
}

/// 动态项
class PostItem extends ListItem {
  PostItem(this.post);
  final SubjectPostModel post;
}

/// 动态列表缓存控制器
///
/// 管理动态列表的缓存和日期分组逻辑，避免在 build 中重复计算。
class PostListController {
  PostListController();

  List<ListItem> _cachedListItems = [];
  Set<DateTime> _cachedPostDates = {};

  /// 获取缓存的列表项
  List<ListItem> get listItems => _cachedListItems;

  /// 获取缓存的动态日期集合
  Set<DateTime> get postDates => _cachedPostDates;

  /// 更新缓存
  void updateCache(List<SubjectPostModel> posts) {
    _cachedListItems = _buildListItems(posts);
    _cachedPostDates = posts.map((p) {
      return DateTime(p.createdAt.year, p.createdAt.month, p.createdAt.day);
    }).toSet();
  }

  /// 查找动态在列表中的索引
  int? findPostIndex(String postId) {
    for (var i = 0; i < _cachedListItems.length; i++) {
      final item = _cachedListItems[i];
      if (item is PostItem && item.post.id == postId) {
        return i;
      }
    }
    return null;
  }

  /// 构建列表项（动态 + 日期分隔符）
  List<ListItem> _buildListItems(List<SubjectPostModel> posts) {
    final items = <ListItem>[];
    DateTime? lastDate;

    for (final post in posts) {
      final postDate = DateTime(
        post.createdAt.year,
        post.createdAt.month,
        post.createdAt.day,
      );

      if (lastDate == null || lastDate != postDate) {
        items.add(DateItem(postDate));
        lastDate = postDate;
      }

      items.add(PostItem(post));
    }

    return items;
  }

  /// 清理资源
  void dispose() {
    _cachedListItems = [];
    _cachedPostDates = {};
  }
}

// =============================================================================
// 高亮控制器
// =============================================================================

/// 高亮控制器
///
/// 管理动态高亮状态和滚动定位逻辑，用于深层链接导航场景。
/// 使用 LRU 策略缓存 GlobalKey，防止内存无限增长。
class HighlightController {
  HighlightController({
    required this.scrollController,
    this.onHighlightChanged,
    this.maxCachedKeys = 100,
  });

  final ScrollController scrollController;
  final void Function(String?)? onHighlightChanged;
  final int maxCachedKeys;

  String? _highlightedPostId;
  bool _hasScrolledToTarget = false;
  bool _isDisposed = false;

  final Map<int, GlobalKey> _itemKeys = {};
  final List<int> _keyAccessOrder = [];

  /// 当前高亮的动态 ID
  String? get highlightedPostId => _highlightedPostId;

  /// 是否已滚动到目标
  bool get hasScrolledToTarget => _hasScrolledToTarget;

  /// 获取或创建指定索引的 GlobalKey（带 LRU 缓存策略）
  GlobalKey getKeyForIndex(int index) {
    // 检查缓存中是否已存在
    final existingKey = _itemKeys[index];
    if (existingKey != null) {
      // 更新 LRU 访问顺序
      _keyAccessOrder.remove(index);
      _keyAccessOrder.add(index);
      return existingKey;
    }

    // 创建新的 GlobalKey
    final key = GlobalKey();
    _itemKeys[index] = key;
    _keyAccessOrder.add(index);

    // LRU 淘汰：超过最大缓存数时移除最旧的
    while (_keyAccessOrder.length > maxCachedKeys) {
      final oldestIndex = _keyAccessOrder.removeAt(0);
      _itemKeys.remove(oldestIndex);
    }

    return key;
  }

  /// 滚动到目标动态并高亮
  ///
  /// [targetPostId] 目标动态 ID
  /// [listController] 动态列表控制器，用于查找动态索引
  void scrollToPostAndHighlight({
    required String? targetPostId,
    required PostListController listController,
  }) {
    if (_hasScrolledToTarget || _isDisposed) return;
    if (targetPostId == null) return;

    final targetIndex = listController.findPostIndex(targetPostId);
    if (targetIndex != null) {
      _hasScrolledToTarget = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDisposed) return;
        _scrollToIndexAndHighlight(targetIndex, targetPostId);
      });
    }
  }

  /// 高亮动画完成回调
  void onHighlightComplete() {
    if (_isDisposed) return;
    _highlightedPostId = null;
    onHighlightChanged?.call(null);
  }

  /// 重置状态
  void reset() {
    _highlightedPostId = null;
    _hasScrolledToTarget = false;
  }

  /// 清理缓存的 keys
  void clearKeys() {
    _itemKeys.clear();
    _keyAccessOrder.clear();
  }

  /// 销毁控制器
  void dispose() {
    _isDisposed = true;
    clearKeys();
  }

  void _scrollToIndexAndHighlight(int index, String postId) {
    if (_isDisposed) return;

    final key = _itemKeys[index];
    final keyContext = key?.currentContext;

    if (keyContext != null) {
      Scrollable.ensureVisible(
            keyContext,
            alignment: SubjectLayoutConstants.scrollAlignment,
            duration: SubjectLayoutConstants.scrollDuration,
            curve: Curves.easeOut,
          )
          .then((_) {
            if (_isDisposed) return;
            _highlightedPostId = postId;
            onHighlightChanged?.call(postId);
          })
          .catchError((Object error) {
            // 滚动动画被中断时忽略错误，仍然设置高亮
            if (_isDisposed) return;
            _highlightedPostId = postId;
            onHighlightChanged?.call(postId);
          });
    } else {
      if (!scrollController.hasClients) {
        _highlightedPostId = postId;
        onHighlightChanged?.call(postId);
        return;
      }

      final targetOffset = index * SubjectLayoutConstants.estimatedItemHeight;
      final maxExtent = scrollController.position.maxScrollExtent;

      scrollController
          .animateTo(
            targetOffset.clamp(0.0, maxExtent),
            duration: SubjectLayoutConstants.scrollDuration,
            curve: Curves.easeOut,
          )
          .then((_) {
            if (_isDisposed) return;
            _highlightedPostId = postId;
            onHighlightChanged?.call(postId);
          })
          .catchError((Object error) {
            // 滚动动画被中断时忽略错误，仍然设置高亮
            if (_isDisposed) return;
            _highlightedPostId = postId;
            onHighlightChanged?.call(postId);
          });
    }
  }
}
