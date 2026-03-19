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
// final handler = SubjectHandler(SubjectMockDataSource());
//
// // 监听变化
// handler.addListener(() {
//   if (mounted) setState(() {});
// });
//
// // 获取数据
// await handler.getSubjectList();
//
// // 访问状态
// final subjectList = handler.subjectList;
// final isLoading = handler.isLoading;
// final uiState = handler.getUIState(subjectId);
// ```

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../data_access/subject_data_source.dart';
import '../models/subject_models.dart';

// 重新导出数据源接口，保持向后兼容
export '../data_access/subject_data_source.dart';

/// 剧集业务逻辑处理器
///
/// 管理剧集列表、详情、动态的获取和状态更新。
/// 继承 [ChangeNotifier] 以支持 UI 层监听状态变化。
class SubjectHandler extends ChangeNotifier {
  /// 创建 Handler
  ///
  /// [dataSource] 数据源实现，可以是 Mock 或 gRPC
  SubjectHandler(this._dataSource);

  final SubjectDataSource _dataSource;

  // ===========================================================================
  // 状态字段
  // ===========================================================================

  /// 剧集列表（按最后动态时间降序排序）
  List<SubjectModel> _subjectList = [];

  /// 剧集 UI 状态映射（subjectId -> UIState）
  final Map<String, SubjectUIState> _uiStates = {};

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 是否已销毁（用于防止异步回调中的状态更新）
  bool _isDisposed = false;

  /// 当前正在进行的加载请求（用于防抖和共享结果）
  Completer<List<SubjectModel>>? _loadingCompleter;

  // ===========================================================================
  // 公开 getter
  // ===========================================================================

  /// 剧集列表
  List<SubjectModel> get subjectList => _subjectList;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息（null 表示无错误）
  String? get error => _error;

  /// 获取指定剧集的 UI 状态
  SubjectUIState? getUIState(String subjectId) => _uiStates[subjectId];

  // ===========================================================================
  // 数据获取方法
  // ===========================================================================

  /// 获取剧集列表
  ///
  /// 从数据源获取剧集列表，按最后动态时间降序排序。
  /// 内置防抖机制：如果已在加载中，返回同一个 Future，让多个调用者共享结果。
  ///
  /// 返回排序后的剧集列表。
  Future<List<SubjectModel>> getSubjectList() async {
    // 防抖：如果已在加载中，返回同一个 Future
    final existingCompleter = _loadingCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }

    _loadingCompleter = Completer<List<SubjectModel>>();
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      // 并行获取剧集列表和 UI 状态
      final results = await Future.wait([
        _dataSource.getSubjectList(),
        _dataSource.getUIStates(),
      ]);

      // 异步完成后检查是否已销毁
      if (_isDisposed) {
        _loadingCompleter?.complete(_subjectList);
        _loadingCompleter = null;
        return _subjectList;
      }

      final list = results[0] as List<SubjectModel>;
      final uiStates = results[1] as Map<String, SubjectUIState>;

      // 按最后动态时间降序排序
      _subjectList = List.from(list)
        ..sort((a, b) {
          final aTime = a.lastPostTime ?? DateTime(1970);
          final bTime = b.lastPostTime ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });

      // 初始化 UI 状态（优先使用数据源返回的状态）
      for (final subject in _subjectList) {
        _uiStates[subject.id] =
            uiStates[subject.id] ?? SubjectUIState(subjectId: subject.id);
      }

      _loadingCompleter?.complete(_subjectList);
    } catch (e) {
      if (_isDisposed) {
        _loadingCompleter?.complete(_subjectList);
        _loadingCompleter = null;
        return _subjectList;
      }
      _error = e.toString();
      _loadingCompleter?.completeError(e);
    }

    _isLoading = false;
    _loadingCompleter = null;
    _safeNotifyListeners();
    return _subjectList;
  }

  /// 获取剧集详情
  ///
  /// 根据剧集 ID 获取完整的剧集信息。
  /// 如果剧集不存在，返回 null。
  Future<SubjectModel?> getSubjectDetail(String id) async {
    return _dataSource.getSubjectDetail(id);
  }

  /// 获取剧集动态列表
  ///
  /// 返回指定剧集的动态列表，按时间升序排列（最新在底部）。
  Future<List<MessageModel>> getPosts(String subjectId, {String? topicId}) async {
    final posts = await _dataSource.getPosts(subjectId, topicId: topicId);
    return List.from(posts)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// 获取剧集话题列表
  ///
  /// 返回指定剧集的话题列表（用于 Discord 模式）。
  Future<List<SubjectTopicModel>> getTopics(String subjectId) async {
    return _dataSource.getTopics(subjectId);
  }

  /// 刷新剧集列表
  ///
  /// 重新获取剧集列表，用于下拉刷新等场景。
  Future<void> refresh() async {
    // 重置加载状态以允许重新请求
    _isLoading = false;
    await getSubjectList();
  }

  // ===========================================================================
  // UI 状态操作（乐观更新）
  // ===========================================================================

  /// 切换静音状态
  ///
  /// 采用乐观更新策略：先更新 UI，请求失败后回滚。
  /// 静音后不会收到推送通知，但仍会计算未读数。
  Future<void> toggleMute(String subjectId) async {
    final currentState = _uiStates[subjectId];
    if (currentState == null) return;

    final newMuted = !currentState.isMuted;

    // 乐观更新
    _uiStates[subjectId] = currentState.copyWith(isMuted: newMuted);
    _safeNotifyListeners();

    try {
      await _dataSource.toggleMute(subjectId, newMuted);
    } catch (e) {
      if (_isDisposed) return;
      // 请求失败，回滚状态
      _uiStates[subjectId] = currentState;
      _safeNotifyListeners();
      rethrow;
    }
  }

  /// 切换置顶状态
  ///
  /// 采用乐观更新策略：先更新 UI，请求失败后回滚。
  /// 置顶的剧集会在列表顶部显示。
  Future<void> togglePin(String subjectId) async {
    final currentState = _uiStates[subjectId];
    if (currentState == null) return;

    final newPinned = !currentState.isPinned;

    // 乐观更新
    _uiStates[subjectId] = currentState.copyWith(isPinned: newPinned);
    _safeNotifyListeners();

    try {
      await _dataSource.togglePin(subjectId, newPinned);
    } catch (e) {
      if (_isDisposed) return;
      // 请求失败，回滚状态
      _uiStates[subjectId] = currentState;
      _safeNotifyListeners();
      rethrow;
    }
  }

  /// 切换视图模式
  ///
  /// 切换 Telegram/Discord 视图模式
  void toggleViewMode(String subjectId, SubjectViewMode mode) {
    final currentState = _uiStates[subjectId];
    if (currentState == null) return;

    if (currentState.viewMode == mode) return;

    _uiStates[subjectId] = currentState.copyWith(viewMode: mode);
    _safeNotifyListeners();
    // 视图模式属于本地状态，如果需要保存到服务端则在这里发请求
  }

  /// 更新未读数
  ///
  /// 直接更新指定剧集的未读动态数量。
  void updateUnreadCount(String subjectId, int count) {
    final currentState = _uiStates[subjectId];
    if (currentState == null) return;

    _uiStates[subjectId] = currentState.copyWith(unreadCount: count);
    _safeNotifyListeners();
  }

  /// 移除剧集的 UI 状态
  ///
  /// 当剧集被删除或取消订阅时调用，清理对应的 UI 状态。
  void removeUIState(String subjectId) {
    if (_uiStates.remove(subjectId) != null) {
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
