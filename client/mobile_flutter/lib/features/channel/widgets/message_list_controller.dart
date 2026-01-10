// =============================================================================
// 消息列表控制器
// =============================================================================
//
// 管理消息列表的缓存、日期分组和滚动定位逻辑。
//
// ## 设计目的
//
// 1. **性能优化**：避免在 build 方法中重复计算列表项和日期分组
// 2. **精确定位**：支持滚动到指定消息并高亮显示（深层链接导航）
// 3. **内存管理**：使用 LRU 策略缓存 GlobalKey，防止内存无限增长

import 'package:flutter/material.dart';
import '../models/channel_message_model.dart';
import 'channel_constants.dart';

// =============================================================================
// 消息列表缓存控制器
// =============================================================================

/// 消息列表缓存控制器
///
/// 管理消息列表的缓存和日期分组逻辑，避免在 build 中重复计算。
class MessageListController {
  MessageListController();

  List<dynamic> _cachedListItems = [];
  Set<DateTime> _cachedMessageDates = {};

  /// 获取缓存的列表项（DateTime | ChannelMessageModel）
  List<dynamic> get listItems => _cachedListItems;

  /// 获取缓存的消息日期集合
  Set<DateTime> get messageDates => _cachedMessageDates;

  /// 更新缓存
  void updateCache(List<ChannelMessageModel> messages) {
    _cachedListItems = _buildListItems(messages);
    _cachedMessageDates = messages.map((m) {
      return DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
    }).toSet();
  }

  /// 查找消息在列表中的索引
  int? findMessageIndex(String messageId) {
    for (var i = 0; i < _cachedListItems.length; i++) {
      final item = _cachedListItems[i];
      if (item is ChannelMessageModel && item.id == messageId) {
        return i;
      }
    }
    return null;
  }

  /// 构建列表项（消息 + 日期分隔符）
  List<dynamic> _buildListItems(List<ChannelMessageModel> messages) {
    final items = <dynamic>[];
    DateTime? lastDate;

    for (final message in messages) {
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      if (lastDate == null || lastDate != messageDate) {
        items.add(messageDate);
        lastDate = messageDate;
      }

      items.add(message);
    }

    return items;
  }

  /// 清理资源
  void dispose() {
    _cachedListItems = [];
    _cachedMessageDates = {};
  }
}

// =============================================================================
// 高亮控制器
// =============================================================================

/// 高亮控制器
///
/// 管理消息高亮状态和滚动定位逻辑，用于深层链接导航场景。
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

  String? _highlightedMessageId;
  bool _hasScrolledToTarget = false;
  bool _isDisposed = false;

  final Map<int, GlobalKey> _itemKeys = {};
  final List<int> _keyAccessOrder = [];

  /// 当前高亮的消息 ID
  String? get highlightedMessageId => _highlightedMessageId;

  /// 是否已滚动到目标
  bool get hasScrolledToTarget => _hasScrolledToTarget;

  /// 获取或创建指定索引的 GlobalKey（带 LRU 缓存策略）
  GlobalKey getKeyForIndex(int index) {
    if (_itemKeys.containsKey(index)) {
      _keyAccessOrder.remove(index);
      _keyAccessOrder.add(index);
      return _itemKeys[index]!;
    }

    final key = GlobalKey();
    _itemKeys[index] = key;
    _keyAccessOrder.add(index);

    while (_keyAccessOrder.length > maxCachedKeys) {
      final oldestIndex = _keyAccessOrder.removeAt(0);
      _itemKeys.remove(oldestIndex);
    }

    return key;
  }

  /// 滚动到目标消息并高亮
  void scrollToMessageAndHighlight({
    required String? targetMessageId,
    required MessageListController listController,
    required BuildContext context,
  }) {
    if (_hasScrolledToTarget || _isDisposed) return;
    if (targetMessageId == null) return;

    final targetIndex = listController.findMessageIndex(targetMessageId);
    if (targetIndex != null) {
      _hasScrolledToTarget = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDisposed) return;
        _scrollToIndexAndHighlight(targetIndex, targetMessageId);
      });
    }
  }

  /// 高亮动画完成回调
  void onHighlightComplete() {
    if (_isDisposed) return;
    _highlightedMessageId = null;
    onHighlightChanged?.call(null);
  }

  /// 重置状态
  void reset() {
    _highlightedMessageId = null;
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

  void _scrollToIndexAndHighlight(int index, String messageId) {
    if (_isDisposed) return;

    final key = _itemKeys[index];
    final keyContext = key?.currentContext;

    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        alignment: ChannelLayoutConstants.scrollAlignment,
        duration: ChannelLayoutConstants.scrollDuration,
        curve: Curves.easeOut,
      ).then((_) {
        if (_isDisposed) return;
        _highlightedMessageId = messageId;
        onHighlightChanged?.call(messageId);
      });
    } else {
      if (!scrollController.hasClients) {
        _highlightedMessageId = messageId;
        onHighlightChanged?.call(messageId);
        return;
      }

      final targetOffset = index * ChannelLayoutConstants.estimatedItemHeight;
      final maxExtent = scrollController.position.maxScrollExtent;

      scrollController
          .animateTo(
            targetOffset.clamp(0.0, maxExtent),
            duration: ChannelLayoutConstants.scrollDuration,
            curve: Curves.easeOut,
          )
          .then((_) {
            if (_isDisposed) return;
            _highlightedMessageId = messageId;
            onHighlightChanged?.call(messageId);
          });
    }
  }
}
