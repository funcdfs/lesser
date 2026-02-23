// =============================================================================
// 剧集列表页 - Series Page (Tab 2)
// =============================================================================
//
// ## 设计目的
// 作为底部导航栏 Tab 2 的入口页面，展示用户关注的剧集列表。
// 支持标签筛选、下拉刷新、剧集搜索、创建剧集和剧集详情导航。
//
// ## 页面结构
// - AppBar: 清除筛选（左侧） + 标题（居中） + 搜索/创建剧集（右侧）
// - Body: 剧集列表（支持下拉刷新）
// - Overlay: 底部标签抽屉（可拖拽展开）
//
// ## 状态管理
// - 使用 SeriesHandler 管理剧集数据和 UI 状态
// - 标签筛选状态由页面本地管理（_selectedTags）
// - Handler 变化时通过 Listener 触发重建
//
// ## 生命周期处理
// - initState: 创建 Handler，添加监听器，加载数据
// - dispose: 先移除监听器，再 dispose Handler（防止回调竞态）
//
// ## 数据源
// 当前使用 SeriesMockDataSource，后续可替换为 gRPC 数据源。
// 标签数据从 mock_data 获取，便于统一管理。
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../data_access/subject_mock_data_source.dart';
import '../data_access/mock/subject_mock_data.dart';
import '../handler/subject_handler.dart';
import '../models/subject_models.dart';
import '../widgets/subject_item.dart';
import '../widgets/subject_tag_drawer.dart';
import 'subject_detail_page.dart';

/// 剧集列表页 - Tab 2 入口
///
/// ## 功能特性
/// - 剧集列表展示（支持下拉刷新）
/// - 标签筛选（底部抽屉）
/// - 剧集搜索（AppBar 右侧）
/// - 创建剧集（AppBar 右侧）
/// - 加载/空/错误状态处理
/// - 剧集详情页导航
class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  late final SubjectHandler _handler;

  // 标签筛选状态（本地管理，后续可考虑移入 Handler）
  // 标签数据从 mock_data 获取，便于后续替换为后端数据
  final Set<String> _selectedTags = {};

  // 标记 Handler 是否已初始化，防止 initState 异常时 dispose 崩溃
  bool _isHandlerInitialized = false;

  // 缓存过滤后的剧集列表，避免在 build() 中高频重新计算 O(N*M)
  List<SubjectModel>? _filteredSubjectList;

  @override
  void initState() {
    super.initState();
    // 使用 Mock 数据源，后续可替换为 gRPC 数据源
    _handler = SubjectHandler(SubjectMockDataSource());
    _isHandlerInitialized = true;
    _handler.addListener(_onHandlerChanged);
    _handler.getSubjectList();
  }

  /// Handler 状态变化回调
  ///
  /// 注意：已有 mounted 检查，确保 dispose 后不会调用 setState
  void _onHandlerChanged() {
    if (!mounted) return;
    _updateFilteredList();
    setState(() {});
  }

  /// 预计算并缓存过滤后的列表
  void _updateFilteredList() {
    var list = _handler.subjectList;
    if (_selectedTags.isNotEmpty) {
      list = list.where((s) {
        return s.tags.any((t) => _selectedTags.contains(t));
      }).toList();
    }
    _filteredSubjectList = list;
  }

  @override
  void dispose() {
    // 重要：先检查是否已初始化，防止 initState 异常时崩溃
    if (_isHandlerInitialized) {
      // 先移除监听器，防止 dispose 后仍收到回调
      // 虽然 _onHandlerChanged 中有 mounted 检查，但这是双重保险
      _handler.removeListener(_onHandlerChanged);
      _handler.dispose();
    }
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await _handler.refresh();
    } catch (e) {
      // 刷新失败时显示提示，但不阻塞 UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('刷新失败，请稍后重试'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onSeriesTap(SubjectModel subject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            SubjectDetailPage(subjectId: subject.id, initialSubject: subject),
      ),
    );
  }

  void _onTagTap(SubjectTag tag) {
    setState(() {
      if (_selectedTags.contains(tag.id)) {
        _selectedTags.remove(tag.id);
      } else {
        _selectedTags.add(tag.id);
      }
      _updateFilteredList();
    });
  }

  void _onClearTags() {
    setState(() {
      _selectedTags.clear();
      _updateFilteredList();
    });
  }

  void _onRetry() {
    _handler.getSubjectList();
  }

  /// 搜索剧集
  void _onSearchTap() {
    // TODO: 跳转到剧集搜索页
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('搜索功能开发中'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 创建剧集
  void _onCreateSeriesTap() {
    // TODO: 跳转到创建剧集页
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('创建剧集功能开发中'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: colors.textPrimary,
              backgroundColor: colors.surfaceElevated,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: colors.surfaceBase,
                    surfaceTintColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    floating: true,
                    centerTitle: true,
                    // AppBar 底部分割线
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0.5),
                      child: Container(height: 0.5, color: colors.divider),
                    ),
                    // 左侧：清除筛选按钮（仅在有选中标签时显示，使用与选中 tag 一致的样式）
                    leading: _selectedTags.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: TapScale(
                                onTap: _onClearTags,
                                scale: TapScales.small,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.accentSoft,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: colors.accent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.filter_list_rounded,
                                        size: 14,
                                        color: colors.accent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_selectedTags.length}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colors.accent,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.close_rounded,
                                        size: 14,
                                        color: colors.accent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                    leadingWidth: _selectedTags.isNotEmpty ? 100 : null,
                    title: GestureDetector(
                      onTap: () {
                        PrimaryScrollController.of(context).animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Text(
                        '频道',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    // 右侧：搜索 + 创建频道（剧集）
                    actions: [
                      // 搜索按钮
                      TapScale(
                        onTap: _onSearchTap,
                        scale: TapScales.small,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            size: 24,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      // 创建剧集按钮
                      TapScale(
                        onTap: _onCreateSeriesTap,
                        scale: TapScales.small,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                            left: 6,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 26,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildContent(colors),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            ),
          ),
          // 使用统一的 SubjectTagDrawer 组件，标签数据从 mock_data 获取
          SubjectTagDrawer(
            tags: mockSubjectTags,
            selectedTags: _selectedTags,
            onTagTap: _onTagTap,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppColorScheme colors) {
    if (_handler.isLoading) {
      return const _LoadingView();
    }

    final error = _handler.error;
    if (error != null) {
      return _ErrorView(error: error, onRetry: _onRetry);
    }

    if (_handler.subjectList.isEmpty) {
      return const _EmptyView();
    }

    final subjectList = _filteredSubjectList ?? _handler.subjectList;

    if (subjectList.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            '没有找到匹配的剧集',
            style: TextStyle(color: colors.textTertiary),
          ),
        ),
      );
    }

    return _SubjectListView(
      subjectList: subjectList,
      getUIState: _handler.getUIState,
      onRefresh: _onRefresh,
      onSeriesTap: _onSeriesTap,
    );
  }
}

// =============================================================================
// 私有 Widget 类
// =============================================================================

/// 加载中视图
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.textTertiary,
        ),
      ),
    );
  }
}

/// 空状态视图
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tv_rounded, size: 64, color: colors.textDisabled),
            const SizedBox(height: 16),
            Text(
              '暂无关注剧集',
              style: TextStyle(fontSize: 16, color: colors.textTertiary),
            ),
            const SizedBox(height: 8),
            Text(
              '关注感兴趣的剧集，获取最新动态',
              style: TextStyle(fontSize: 14, color: colors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

/// 错误视图
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(fontSize: 16, color: colors.textTertiary),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 14, color: colors.textDisabled),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TapScale(
              onTap: onRetry,
              scale: TapScales.medium,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '重试',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 剧集列表视图
///
/// 使用 RefreshIndicator 支持下拉刷新。
/// 列表项使用 SubjectItem 组件，传入 UI 状态用于显示未读数等。
class _SubjectListView extends StatelessWidget {
  const _SubjectListView({
    required this.subjectList,
    required this.getUIState,
    required this.onRefresh,
    required this.onSeriesTap,
  });

  final List<SubjectModel> subjectList;
  final SubjectUIState? Function(String subjectId) getUIState;
  final Future<void> Function() onRefresh;
  final void Function(SubjectModel) onSeriesTap;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final subject = subjectList[index];
        return SubjectItem(
          subject: subject,
          uiState: getUIState(subject.id),
          onTap: () => onSeriesTap(subject),
        );
      }, childCount: subjectList.length),
    );
  }
}
