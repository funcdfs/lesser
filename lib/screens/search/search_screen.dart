import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../config/shadcn_theme.dart';
import '../../widgets/shadcn/shadcn_chip.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Hot Section
  int _hotIndex = 0;
  
  // Mock Data Groups
  late final List<Article> _allHotArticles;
  late final List<Article> _travelHotArticles;
  late final List<Article> _foodHotArticles;
  late final List<Article> _techHotArticles;

  final List<String> _hotTags = [
    '旅行', '美食', '摄影', '艺术', '音乐', 
    '电影', '读书', '健身', '科技', '设计'
  ];

  @override
  void initState() {
    super.initState();
    _allHotArticles = List.generate(5, (index) => mockArticles[index % mockArticles.length]);
    
    final travelArticles = mockArticles.where((a) => a.category == 'travel').toList();
    _travelHotArticles = List.generate(5, (index) {
      if (travelArticles.isNotEmpty) return travelArticles[index % travelArticles.length];
      return mockArticles[index % mockArticles.length];
    });

    final foodArticles = mockArticles.where((a) => a.category == 'food').toList();
    _foodHotArticles = List.generate(5, (index) {
      if (foodArticles.isNotEmpty) return foodArticles[index % foodArticles.length];
      return mockArticles[index % mockArticles.length];
    });
    
    _techHotArticles = List.generate(5, (index) => mockArticles[(index + 2) % mockArticles.length]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSearchSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ShadcnColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ShadcnRadius.xl)),
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
                leading: const Icon(Icons.history, color: ShadcnColors.mutedForeground),
                title: const Text('搜索历史', style: TextStyle(color: ShadcnColors.foreground)),
              ),
              ListTile(
                leading: const Icon(Icons.filter_list, color: ShadcnColors.mutedForeground),
                title: const Text('搜索过滤', style: TextStyle(color: ShadcnColors.foreground)),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: ShadcnColors.mutedForeground),
                title: const Text('高级设置', style: TextStyle(color: ShadcnColors.foreground)),
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
            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: ShadcnSpacing.lg)),
            
            // Hot Section
            SliverToBoxAdapter(
              child: _buildHotSection(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: ShadcnSpacing.xl2)),
            
            // Hot Tags Section
            SliverToBoxAdapter(
              child: _buildHotTagsSection(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: ShadcnSpacing.xl4)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShadcnSpacing.lg, 
        ShadcnSpacing.lg, 
        ShadcnSpacing.lg, 
        0
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
            prefixIcon: const Icon(Icons.search, color: ShadcnColors.mutedForeground),
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune, color: ShadcnColors.mutedForeground),
              onPressed: _showSearchSettings,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ShadcnSpacing.lg, 
              vertical: 14 
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotSection() {
    final tabs = ['全局热门', '旅游', '美食', '科技'];
    final dataLists = [_allHotArticles, _travelHotArticles, _foodHotArticles, _techHotArticles];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(ShadcnSpacing.lg, 0, ShadcnSpacing.lg, ShadcnSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.show_chart, color: ShadcnColors.primary, size: 20),
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
        
        // Tab selector
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? ShadcnColors.foreground : Colors.transparent,
                      borderRadius: BorderRadius.circular(ShadcnRadius.full),
                      border: Border.all(
                        color: isSelected ? ShadcnColors.foreground : ShadcnColors.border,
                      ),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? ShadcnColors.background : ShadcnColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: ShadcnSpacing.lg),
        
        // Content with AnimatedSwitcher
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
                indent: ShadcnSpacing.lg + 24, // Indent to align with text
                color: ShadcnColors.border
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

class _RankedArticleItem extends StatelessWidget {
  final int rank;
  final Article article;

  const _RankedArticleItem({
    required this.rank,
    required this.article,
  });

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFF59E0B); // Gold
    if (rank == 2) return const Color(0xFF71717A); // Silver
    if (rank == 3) return const Color(0xFFA1A1AA); // Bronze
    return ShadcnColors.mutedForeground.withOpacity(0.5);
  }

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
            // Rank Number
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: _getRankColor(rank),
                ),
              ),
            ),
            const SizedBox(width: ShadcnSpacing.md),
            
            // Content
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
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                            color: ShadcnColors.mutedForeground,
                            shape: BoxShape.circle),
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
            
            // Thumbnail (Right side)
            ClipRRect(
              borderRadius: BorderRadius.circular(ShadcnRadius.md),
              child: Container(
                color: ShadcnColors.secondary,
                child: Image.network(
                  article.coverImage,
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  cacheWidth: 160, 
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: 80, 
                    height: 60,
                    child: Icon(Icons.image, color: ShadcnColors.mutedForeground),
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
