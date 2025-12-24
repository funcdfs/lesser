import 'package:flutter/material.dart';
import '../../common/data/mock_data.dart';
import '../../common/config/shadcn_theme.dart';
import '../../common/widgets/shadcn/shadcn_chip.dart';

/// 搜索与发现屏幕
///
/// 该组件实现了综合搜索体验：
/// 1. 顶部提供交互式搜索栏。
/// 2. 中间展示多类别的“热门榜单”，支持切换分类浏览热门文章。
/// 3. 底部展示“热门标签”墙。
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// 搜索框输入控制器
  final TextEditingController _searchController = TextEditingController();

  /// 当前选中的热门榜单分类索引
  int _hotIndex = 0;

  // 模拟各个类别的热榜数据
  late final List<Article> _allHotArticles;
  late final List<Article> _travelHotArticles;
  late final List<Article> _foodHotArticles;
  late final List<Article> _techHotArticles;

  /// 这里定义了发现页底部的热门标签
  final List<String> _hotTags = [
    '旅行',
    '美食',
    '摄影',
    '艺术',
    '音乐',
    '电影',
    '读书',
    '健身',
    '科技',
    '设计',
  ];

  @override
  void initState() {
    super.initState();
    // 初始化时对模拟数据进行随机分配/各类别采样
    _allHotArticles = List.generate(
      5,
      (index) => mockArticles[index % mockArticles.length],
    );

    final travelArticles = mockArticles
        .where((a) => a.category == 'travel')
        .toList();
    _travelHotArticles = List.generate(5, (index) {
      if (travelArticles.isNotEmpty) {
        return travelArticles[index % travelArticles.length];
      }
      return mockArticles[index % mockArticles.length];
    });

    final foodArticles = mockArticles
        .where((a) => a.category == 'food')
        .toList();
    _foodHotArticles = List.generate(5, (index) {
      if (foodArticles.isNotEmpty) {
        return foodArticles[index % foodArticles.length];
      }
      return mockArticles[index % mockArticles.length];
    });

    _techHotArticles = List.generate(
      5,
      (index) => mockArticles[(index + 2) % mockArticles.length],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 弹出搜索设置模态框
  void _showSearchSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ShadcnColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ShadcnRadius.xl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ShadcnSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '搜索设置',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ShadcnColors.foreground,
                ),
              ),
              const SizedBox(height: ShadcnSpacing.lg),
              ListTile(
                leading: const Icon(
                  Icons.history,
                  color: ShadcnColors.mutedForeground,
                ),
                title: const Text(
                  '搜索历史',
                  style: TextStyle(color: ShadcnColors.foreground),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.filter_list,
                  color: ShadcnColors.mutedForeground,
                ),
                title: const Text(
                  '搜索过滤',
                  style: TextStyle(color: ShadcnColors.foreground),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: ShadcnColors.mutedForeground,
                ),
                title: const Text(
                  '高级设置',
                  style: TextStyle(color: ShadcnColors.foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadcnColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部搜索搜索
            SliverToBoxAdapter(child: _buildSearchBar()),
            const SliverToBoxAdapter(child: SizedBox(height: ShadcnSpacing.lg)),

            // 热门榜单
            SliverToBoxAdapter(child: _buildHotSection()),
            const SliverToBoxAdapter(
              child: SizedBox(height: ShadcnSpacing.xl2),
            ),

            // 热门标签
            SliverToBoxAdapter(child: _buildHotTagsSection()),
            const SliverToBoxAdapter(
              child: SizedBox(height: ShadcnSpacing.xl4),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建圆角搜索栏
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShadcnSpacing.lg,
        ShadcnSpacing.lg,
        ShadcnSpacing.lg,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ShadcnColors.secondary,
          borderRadius: BorderRadius.circular(ShadcnRadius.lg),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: ShadcnColors.foreground),
          decoration: InputDecoration(
            hintText: '搜索文章、话题、用户...',
            hintStyle: const TextStyle(color: ShadcnColors.mutedForeground),
            prefixIcon: const Icon(
              Icons.search,
              color: ShadcnColors.mutedForeground,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune, color: ShadcnColors.mutedForeground),
              onPressed: _showSearchSettings,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ShadcnSpacing.lg,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建“热门榜单”区块，包含分类切换和排行列表
  Widget _buildHotSection() {
    final tabs = ['全局热门', '旅游', '美食', '科技'];
    final dataLists = [
      _allHotArticles,
      _travelHotArticles,
      _foodHotArticles,
      _techHotArticles,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区块标题
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ShadcnSpacing.lg,
            0,
            ShadcnSpacing.lg,
            ShadcnSpacing.md,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.show_chart,
                color: ShadcnColors.primary,
                size: 20,
              ),
              const SizedBox(width: ShadcnSpacing.sm),
              Text(
                '热门榜单',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 分类切换栏
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.lg),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _hotIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: ShadcnSpacing.md),
                child: GestureDetector(
                  onTap: () => setState(() => _hotIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ShadcnColors.foreground
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(ShadcnRadius.full),
                      border: Border.all(
                        color: isSelected
                            ? ShadcnColors.foreground
                            : ShadcnColors.border,
                      ),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? ShadcnColors.background
                            : ShadcnColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: ShadcnSpacing.lg),

        // 实际的排行列表。使用 AnimatedSwitcher 提供切换时的平滑过渡。
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey<int>(_hotIndex),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: dataLists[_hotIndex].length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.5,
                indent: ShadcnSpacing.lg + 24,
                color: ShadcnColors.border,
              ),
              itemBuilder: (context, index) {
                return _RankedArticleItem(
                  rank: index + 1,
                  article: dataLists[_hotIndex][index],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 底部标签区块
  Widget _buildHotTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.tag, color: ShadcnColors.foreground, size: 20),
              const SizedBox(width: ShadcnSpacing.sm),
              Text(
                '热门标签',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ShadcnSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.lg),
          child: Wrap(
            spacing: ShadcnSpacing.md,
            runSpacing: ShadcnSpacing.md,
            children: _hotTags.map((tag) => ShadcnChip(label: tag)).toList(),
          ),
        ),
      ],
    );
  }
}

/// 内部私有：单一的热点排行项目样式
class _RankedArticleItem extends StatelessWidget {
  final int rank;
  final Article article;

  const _RankedArticleItem({required this.rank, required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ShadcnSpacing.lg,
          vertical: ShadcnSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 排名数字
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: ShadcnColors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: ShadcnSpacing.md),

            // 文本信息部分
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ShadcnColors.foreground,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        article.author,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 一个小白点间隔
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: ShadcnColors.mutedForeground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${article.likes} 热度',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ShadcnColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: ShadcnSpacing.md),

            // 封面图片（右侧）
            ClipRRect(
              borderRadius: BorderRadius.circular(ShadcnRadius.md),
              child: Container(
                color: ShadcnColors.secondary,
                child: Image.network(
                  article.coverImage,
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: 80,
                    height: 60,
                    child: Icon(
                      Icons.image,
                      color: ShadcnColors.mutedForeground,
                    ),
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
