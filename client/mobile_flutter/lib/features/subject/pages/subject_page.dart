// =============================================================================
// 剧集列表页 - Series Page (Tab 2)
// =============================================================================
//
// ## 设计目的
// 作为底部导航栏 Tab 2 的入口页面，展示用户关注的剧集列表。
// 这里的剧集（Subject）采用“话题/消息”风格的 Feed 流展示。
//
// ## 页面结构
// - AppBar: 返回（左侧） + 标题（居中） + 搜索/更多（右侧）
// - Search Mode: AppBar 变为搜索框，下方显示话题标签列表
// - Body: 话题 Feed 流（SubjectItem）
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
import '../widgets/notification_item.dart';
import '../widgets/subject_tag_drawer.dart';
import 'subject_detail_page.dart';
import 'comment_notification_page.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  late final SubjectHandler _handler;
  final TextEditingController _searchController = TextEditingController();

  // 搜索状态
  bool _isSearching = false;

  // 标签筛选状态
  final Set<String> _selectedTags = {};

  bool _isHandlerInitialized = false;
  List<SubjectModel>? _filteredSubjectList;

  @override
  void initState() {
    super.initState();
    _handler = SubjectHandler(SubjectMockDataSource());
    _isHandlerInitialized = true;
    _handler.addListener(_onHandlerChanged);
    _handler.getSubjectList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_isHandlerInitialized) {
      _handler.removeListener(_onHandlerChanged);
      _handler.dispose();
    }
    super.dispose();
  }

  void _onHandlerChanged() {
    if (!mounted) return;
    _updateFilteredList();
    setState(() {});
  }

  void _updateFilteredList() {
    var list = [..._handler.subjectList];
    
    // 标签过滤
    if (_selectedTags.isNotEmpty) {
      list = list.where((s) {
        return s.tags.any((t) => _selectedTags.contains(t));
      }).toList();
    }
    
    // 搜索词过滤
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((s) {
        return s.title.toLowerCase().contains(query) || 
               (s.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    _filteredSubjectList = list;
  }

  Future<void> _onRefresh() async {
    try {
      await _handler.refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('刷新失败，请稍后重试')),
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

  void _onSearchToggle() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _updateFilteredList();
      }
    });
  }

  void _onMoreTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('更多操作开发中')),
    );
  }

  void _onRetry() {
    _handler.getSubjectList();
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
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(colors),
                  if (_isSearching) _buildSearchTagPanel(colors),
                  ..._buildContent(colors),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            ),
          ),
          if (!_isSearching)
            SubjectTagDrawer(
              tags: mockSubjectTags,
              selectedTags: _selectedTags,
              onTagTap: _onTagTap,
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppColorScheme colors) {
    return SliverAppBar(
      backgroundColor: colors.surfaceBase,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      floating: true,
      pinned: true,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: colors.divider),
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(fontSize: 16, color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: '搜索话题...',
                hintStyle: TextStyle(color: colors.textTertiary),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (_) => _onHandlerChanged(),
            )
          : Text(
              '话题',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
      actions: [
        TapScale(
          onTap: _onSearchToggle,
          scale: TapScales.small,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              size: 24,
              color: colors.textPrimary,
            ),
          ),
        ),
        TapScale(
          onTap: _onMoreTap,
          scale: TapScales.small,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.more_horiz_rounded,
              size: 24,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTagPanel(AppColorScheme colors) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceBase,
          border: Border(bottom: BorderSide(color: colors.divider.withValues(alpha: 0.5), width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'tags：',
                style: TextStyle(fontSize: 13, color: colors.textTertiary, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: mockSubjectTags.length,
                itemBuilder: (context, index) {
                  final tag = mockSubjectTags[index];
                  final isSelected = _selectedTags.contains(tag.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      onSelected: (_) => _onTagTap(tag),
                      selectedColor: colors.accentSoft,
                      labelStyle: TextStyle(
                        color: isSelected ? colors.accent : colors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: colors.surfaceElevated,
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(color: isSelected ? colors.accent : colors.divider.withValues(alpha: 0.5)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(AppColorScheme colors) {
    if (_handler.isLoading) {
      return [const _LoadingView()];
    }

    final error = _handler.error;
    if (error != null) {
      return [
        _ErrorView(error: error, onRetry: _onRetry),
      ];
    }

    final subjectList = _isSearching ? (_filteredSubjectList ?? []) : _handler.subjectList;

    if (subjectList.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: colors.textDisabled),
                const SizedBox(height: 16),
                Text(
                  '没有找到匹配的话题',
                  style: TextStyle(color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      // 置顶通知箱
      SliverToBoxAdapter(
        child: SubjectNotificationItem(
          notifications: mockCommentNotifications,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CommentNotificationPage(),
              ),
            );
          },
        ),
      ),
      // 话题列表
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final subject = subjectList[index];
            return SubjectItem(
              subject: subject,
              uiState: _handler.getUIState(subject.id),
              onTap: () => _onSeriesTap(subject),
            );
          },
          childCount: subjectList.length,
        ),
      ),
    ];
  }
}

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
          color: colors.accent,
        ),
      ),
    );
  }
}

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
            Icon(Icons.error_outline_rounded, size: 48, color: colors.textDisabled),
            const SizedBox(height: 16),
            Text(error, style: TextStyle(color: colors.textTertiary)),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
