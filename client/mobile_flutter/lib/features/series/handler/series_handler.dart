// =============================================================================
// 剧集业务逻辑层
// =============================================================================
//
// 管理剧集相关的业务逻辑和状态，作为 UI 层和数据层之间的桥梁。
//
// ## 设计模式
//
// 采用 ChangeNotifier 模式，UI 层通过监听 Handler 的变化来更新界面。
//
// ## 核心职责
//
// 1. **数据获取**：从数据源获取剧集列表、详情、动态/剧评
// 2. **状态管理**：管理加载状态、错误状态、UI 状态
// 3. **乐观更新**：静音、置顶等操作先更新 UI，失败后回滚
// 4. **生命周期**：安全处理异步操作和组件销毁
//
// ## 使用示例
//
// ```dart
// // 创建 Handler
// final handler = SeriesHandler(SeriesMockDataSource());
//
// // 监听变化
// handler.addListener(() {
//   if (mounted) setState(() {});
// });
//
// // 获取数据
// await handler.getSeriesList();
//
// // 访问状态
// final seriesList = handler.seriesList;
// final isLoading = handler.isLoading;
// final uiState = handler.getUIState(seriesId);
// ```

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../data_access/series_data_source.dart';
import '../models/series_models.dart';

// 重新导出数据源接口，保持向后兼容
export '../data_access/series_data_source.dart';

/// 剧集业务逻辑处理器
///
/// 管理剧集列表、详情、动态的获取和状态更新。
/// 继承 [ChangeNotifier] 以支持 UI 层监听状态变化。
class SeriesHandler extends ChangeNotifier {
  /// 创建 Handler
  ///
  /// [dataSource] 数据源实现，可以是 Mock 或 gRPC
  SeriesHandler(this._dataSource);

  final SeriesDataSource _dataSource;

  // ===========================================================================
  // 状态字段
  // ===========================================================================

  /// 剧集列表（按最后动态时间降序排序）
  List<SeriesModel> _seriesList = [];

  /// 剧集 UI 状态映射（seriesId -> UIState）
  final Map<String, SeriesUIState> _uiStates = {};

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 是否已销毁（用于防止异步回调中的状态更新）
  bool _isDisposed = false;

  /// 当前正在进行的加载请求（用于防抖和共享结果）
  Completer<List<SeriesModel>>? _loadingCompleter;

  // ===========================================================================
  // 公开 getter
  // ===========================================================================

  /// 剧集列表
  List<SeriesModel> get seriesList => _seriesList;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息（null 表示无错误）
  String? get error => _error;

  /// 获取指定剧集的 UI 状态
  SeriesUIState? getUIState(String seriesId) => _uiStates[seriesId];

  // ===========================================================================
  // 数据获取方法
  // ===========================================================================

  /// 获取剧集列表
  ///
  /// 从数据源获取剧集列表，按最后动态时间降序排序。
  /// 内置防抖机制：如果已在加载中，返回同一个 Future，让多个调用者共享结果。
  ///
  /// 返回排序后的剧集列表。
  Future<List<SeriesModel>> getSeriesList() async {
    // 防抖：如果已在加载中，返回同一个 Future
    final existingCompleter = _loadingCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }

    _loadingCompleter = Completer<List<SeriesModel>>();
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      // 并行获取剧集列表和 UI 状态
      final results = await Future.wait([
        _dataSource.getSeriesList(),
        _dataSource.getUIStates(),
      ]);

      // 异步完成后检查是否已销毁
      if (_isDisposed) {
        _loadingCompleter?.complete(_seriesList);
        _loadingCompleter = null;
        return _seriesList;
      }

      final list = results[0] as List<SeriesModel>;
      final uiStates = results[1] as Map<String, SeriesUIState>;

      // 按最后动态时间降序排序
      _seriesList = List.from(list)
        ..sort((a, b) {
          final aTime = a.lastPostTime ?? DateTime(1970);
          final bTime = b.lastPostTime ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });

      // 初始化 UI 状态（优先使用数据源返回的状态）
      for (final series in _seriesList) {
        _uiStates[series.id] =
            uiStates[series.id] ?? SeriesUIState(seriesId: series.id);
      }

      _loadingCompleter?.complete(_seriesList);
    } catch (e) {
      if (_isDisposed) {
        _loadingCompleter?.complete(_seriesList);
        _loadingCompleter = null;
        return _seriesList;
      }
      _error = e.toString();
      _loadingCompleter?.completeError(e);
    }

    _isLoading = false;
    _loadingCompleter = null;
    _safeNotifyListeners();
    return _seriesList;
  }

  /// 获取剧集详情
  ///
  /// 根据剧集 ID 获取完整的剧集信息。
  /// 如果剧集不存在，返回 null。
  Future<SeriesModel?> getSeriesDetail(String id) async {
    return _dataSource.getSeriesDetail(id);
  }

  /// 获取剧集动态列表
  ///
  /// 返回指定剧集的动态列表，按时间升序排列（最新在底部）。
  Future<List<SeriesPostModel>> getPosts(String seriesId) async {
    final posts = await _dataSource.getPosts(seriesId);
    return List.from(posts)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// 刷新剧集列表
  ///
  /// 重新获取剧集列表，用于下拉刷新等场景。
  Future<void> refresh() async {
    // 重置加载状态以允许重新请求
    _isLoading = false;
    await getSeriesList();
  }

  // ===========================================================================
  // UI 状态操作（乐观更新）
  // ===========================================================================

  /// 切换静音状态
  ///
  /// 采用乐观更新策略：先更新 UI，请求失败后回滚。
  /// 静音后不会收到推送通知，但仍会计算未读数。
  Future<void> toggleMute(String seriesId) async {
    final currentState = _uiStates[seriesId];
    if (currentState == null) return;

    final newMuted = !currentState.isMuted;

    // 乐观更新
    _uiStates[seriesId] = currentState.copyWith(isMuted: newMuted);
    _safeNotifyListeners();

    try {
      await _dataSource.toggleMute(seriesId, newMuted);
    } catch (e) {
      if (_isDisposed) return;
      // 请求失败，回滚状态
      _uiStates[seriesId] = currentState;
      _safeNotifyListeners();
      rethrow;
    }
  }

  /// 切换置顶状态
  ///
  /// 采用乐观更新策略：先更新 UI，请求失败后回滚。
  /// 置顶的剧集会在列表顶部显示。
  Future<void> togglePin(String seriesId) async {
    final currentState = _uiStates[seriesId];
    if (currentState == null) return;

    final newPinned = !currentState.isPinned;

    // 乐观更新
    _uiStates[seriesId] = currentState.copyWith(isPinned: newPinned);
    _safeNotifyListeners();

    try {
      await _dataSource.togglePin(seriesId, newPinned);
    } catch (e) {
      if (_isDisposed) return;
      // 请求失败，回滚状态
      _uiStates[seriesId] = currentState;
      _safeNotifyListeners();
      rethrow;
    }
  }

  /// 更新未读数
  ///
  /// 直接更新指定剧集的未读动态数量。
  void updateUnreadCount(String seriesId, int count) {
    final currentState = _uiStates[seriesId];
    if (currentState == null) return;

    _uiStates[seriesId] = currentState.copyWith(unreadCount: count);
    _safeNotifyListeners();
  }

  /// 移除剧集的 UI 状态
  ///
  /// 当剧集被删除或取消订阅时调用，清理对应的 UI 状态。
  void removeUIState(String seriesId) {
    if (_uiStates.remove(seriesId) != null) {
      _safeNotifyListeners();
    }
  }

  /// 清理所有 UI 状态
  ///
  /// 用于用户登出或重置状态时。
  void clearAllUIStates() {
    if (_uiStates.isNotEmpty) {
      _uiStates.clear();
      _safeNotifyListeners();
    }
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
