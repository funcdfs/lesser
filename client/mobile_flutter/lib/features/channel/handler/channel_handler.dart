// =============================================================================
// 频道业务逻辑层
// =============================================================================
//
// 管理频道相关的业务逻辑和状态，作为 UI 层和数据层之间的桥梁。
//
// ## 设计模式
//
// 采用 ChangeNotifier 模式，UI 层通过监听 Handler 的变化来更新界面。
//
// ## 核心职责
//
// 1. **数据获取**：从数据源获取频道列表、详情、消息
// 2. **状态管理**：管理加载状态、错误状态、UI 状态
// 3. **乐观更新**：静音、置顶等操作先更新 UI，失败后回滚
// 4. **生命周期**：安全处理异步操作和组件销毁
//
// ## 使用示例
//
// ```dart
// // 创建 Handler
// final handler = ChannelHandler(ChannelMockDataSource());
//
// // 监听变化
// handler.addListener(() {
//   if (mounted) setState(() {});
// });
//
// // 获取数据
// await handler.getChannels();
//
// // 访问状态
// final channels = handler.channels;
// final isLoading = handler.isLoading;
// final uiState = handler.getUIState(channelId);
// ```

import 'package:flutter/foundation.dart';
import '../data_access/channel_data_source.dart';
import '../models/channel_models.dart';

// 重新导出数据源接口，保持向后兼容
export '../data_access/channel_data_source.dart';

/// 频道业务逻辑处理器
///
/// 管理频道列表、详情、消息的获取和状态更新。
/// 继承 [ChangeNotifier] 以支持 UI 层监听状态变化。
class ChannelHandler extends ChangeNotifier {
  /// 创建 Handler
  ///
  /// [dataSource] 数据源实现，可以是 Mock 或 gRPC
  ChannelHandler(this._dataSource);

  final ChannelDataSource _dataSource;

  // ===========================================================================
  // 状态字段
  // ===========================================================================

  /// 频道列表（按最后消息时间降序排序）
  List<ChannelModel> _channels = [];

  /// 频道 UI 状态映射（channelId -> UIState）
  final Map<String, ChannelUIState> _uiStates = {};

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 是否已销毁（用于防止异步回调中的状态更新）
  bool _isDisposed = false;

  // ===========================================================================
  // 公开 getter
  // ===========================================================================

  /// 频道列表
  List<ChannelModel> get channels => _channels;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息（null 表示无错误）
  String? get error => _error;

  /// 获取指定频道的 UI 状态
  ChannelUIState? getUIState(String channelId) => _uiStates[channelId];

  // ===========================================================================
  // 数据获取方法
  // ===========================================================================

  /// 获取频道列表
  ///
  /// 从数据源获取频道列表，按最后消息时间降序排序。
  /// 内置防抖机制：如果已在加载中，直接返回当前数据。
  ///
  /// 返回排序后的频道列表。
  Future<List<ChannelModel>> getChannels() async {
    // 防抖：避免重复请求
    if (_isLoading) return _channels;

    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final list = await _dataSource.getChannels();

      // 异步完成后检查是否已销毁
      if (_isDisposed) return _channels;

      // 按最后消息时间降序排序
      _channels = List.from(list)
        ..sort((a, b) {
          final aTime = a.lastMessageTime ?? DateTime(1970);
          final bTime = b.lastMessageTime ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });

      // 初始化 UI 状态
      for (final channel in _channels) {
        _uiStates.putIfAbsent(
          channel.id,
          () => ChannelUIState(channelId: channel.id),
        );
      }
    } catch (e) {
      if (_isDisposed) return _channels;
      _error = e.toString();
    }

    _isLoading = false;
    _safeNotifyListeners();
    return _channels;
  }

  /// 获取频道详情
  ///
  /// 根据频道 ID 获取完整的频道信息。
  /// 如果频道不存在，返回 null。
  Future<ChannelModel?> getChannelDetail(String id) async {
    return _dataSource.getChannelDetail(id);
  }

  /// 获取频道消息列表
  ///
  /// 返回指定频道的消息列表，按时间升序排列（最新在底部）。
  Future<List<ChannelMessageModel>> getMessages(String channelId) async {
    final messages = await _dataSource.getMessages(channelId);
    return List.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// 刷新频道列表
  ///
  /// 重新获取频道列表，用于下拉刷新等场景。
  Future<void> refresh() async {
    // 重置加载状态以允许重新请求
    _isLoading = false;
    await getChannels();
  }

  // ===========================================================================
  // UI 状态操作（乐观更新）
  // ===========================================================================

  /// 切换静音状态
  ///
  /// 采用乐观更新策略：先更新 UI，请求失败后回滚。
  /// 静音后不会收到推送通知，但仍会计算未读数。
  Future<void> toggleMute(String channelId) async {
    final currentState = _uiStates[channelId];
    if (currentState == null) return;

    final newMuted = !currentState.isMuted;

    // 乐观更新
    _uiStates[channelId] = currentState.copyWith(isMuted: newMuted);
    _safeNotifyListeners();

    try {
      await _dataSource.toggleMute(channelId, newMuted);
    } catch (e) {
      if (_isDisposed) return;
      // 请求失败，回滚状态
      _uiStates[channelId] = currentState;
      _safeNotifyListeners();
      rethrow;
    }
  }

  /// 切换置顶状态
  ///
  /// 采用乐观更新策略：先更新 UI，请求失败后回滚。
  /// 置顶的频道会在列表顶部显示。
  Future<void> togglePin(String channelId) async {
    final currentState = _uiStates[channelId];
    if (currentState == null) return;

    final newPinned = !currentState.isPinned;

    // 乐观更新
    _uiStates[channelId] = currentState.copyWith(isPinned: newPinned);
    _safeNotifyListeners();

    try {
      await _dataSource.togglePin(channelId, newPinned);
    } catch (e) {
      if (_isDisposed) return;
      // 请求失败，回滚状态
      _uiStates[channelId] = currentState;
      _safeNotifyListeners();
      rethrow;
    }
  }

  /// 更新未读数
  ///
  /// 直接更新指定频道的未读消息数量。
  void updateUnreadCount(String channelId, int count) {
    final currentState = _uiStates[channelId];
    if (currentState == null) return;

    _uiStates[channelId] = currentState.copyWith(unreadCount: count);
    _safeNotifyListeners();
  }

  // ===========================================================================
  // 生命周期
  // ===========================================================================

  /// 安全通知监听器
  ///
  /// 检查是否已销毁，避免在组件销毁后调用 notifyListeners。
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
