// 个人主页
import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import 'settings_page.dart';
import '../widgets/profile_tab_widgets.dart';
import 'package:intl/date_symbol_data_local.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Tab states matching TSX
  String _activeReviewCategory = '我的长评';
  String _libraryView = 'media'; // "media" or "playlists"
  String _activeMediaStatus = '想看';
  String _activeMediaCategory = '全部';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_CN', null);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF0F172A), // Slate 900
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_rounded, color: Colors.white70),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Decor
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.2), // Indigo 500
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const _ProfileHeader(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _BioSection(),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabDelegate(
                height: 49,
                child: Container(
                  color: colors.surfaceBase,
                  height: 49,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: colors.accent,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: colors.accent,
                    unselectedLabelColor: colors.textTertiary,
                    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    tabs: const [
                      Tab(text: '影评互动'),
                      Tab(text: '影视档案'),
                      Tab(text: '动态轨迹'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: 影评互动 (Reviews)
            _buildReviewsTab(context),
            // Tab 2: 影视档案 (Library)
            _buildLibraryTab(context),
            // Tab 3: 动态轨迹 (Activity)
            _buildActivityTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    final colors = AppColors.of(context);
    return CustomScrollView(
      slivers: [
        // Sticky Review Chips
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabDelegate(
            height: 54,
            child: Container(
              color: colors.surfaceBase,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['我的长评', '我的短评', '我的讨论', '赞过的'].map((cat) {
                    final isSelected = _activeReviewCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeReviewCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? colors.accent : colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? colors.accent : colors.divider.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        // Reviews List
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProfileReviewCard(review: reviews[index % reviews.length]),
              ),
              childCount: 10,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildLibraryTab(BuildContext context) {
    final colors = AppColors.of(context);
    return CustomScrollView(
      slivers: [
        // Sticky Library Nav
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabDelegate(
            height: _libraryView == 'media' ? 140 : 54,
            child: Container(
              color: colors.surfaceBase,
              child: Column(
                children: [
                  // Sub-tabs
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: colors.divider.withValues(alpha: 0.3))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _LibrarySubTab(
                              label: '作品档案', 
                              isSelected: _libraryView == 'media',
                              onTap: () => setState(() => _libraryView = 'media'),
                            ),
                            const SizedBox(width: 24),
                            _LibrarySubTab(
                              label: '收藏片单', 
                              isSelected: _libraryView == 'playlists',
                              onTap: () => setState(() => _libraryView = 'playlists'),
                            ),
                          ],
                        ),
                        if (_libraryView == 'playlists')
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: colors.accent.withValues(alpha: 0.1),
                              foregroundColor: colors.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('新建片单', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                  // Media filters
                  if (_libraryView == 'media') ...[
                    // Status Filters
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: ['想看', '看过'].map((status) {
                          final isSelected = _activeMediaStatus == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: GestureDetector(
                              onTap: () => setState(() => _activeMediaStatus = status),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? colors.accent : colors.textSecondary,
                                    ),
                                  ),
                                  if (isSelected) 
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 16,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: colors.accent,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Category Chips
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: ['全部', '电影', '电视剧', '动漫', '短剧', '图书', '其他'].map((cat) {
                            final isSelected = _activeMediaCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _activeMediaCategory = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? colors.textPrimary : colors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? colors.surfaceBase : colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Content
        if (_libraryView == 'media')
          const SliverFillRemaining(
            hasScrollBody: false,
            child: ProfileMediaGrid(),
          )
        else
          const SliverFillRemaining(
            hasScrollBody: false,
            child: ProfilePlaylistGrid(),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProfileActivityHeatmap(),
        ),
        SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with badge
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.5), width: 2), // Indigo 400
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1740252117027-4275d3f84385?w=200'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)], // Amber 300 to 500
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F172A), width: 2),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, size: 10, color: Color(0xFF78350F)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name and badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '影迷小张',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Label(
                      icon: Icons.auto_awesome_rounded,
                      text: '资深影评人',
                      color: const Color(0xFFF59E0B),
                      bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    ),
                    _Label(
                      text: 'Lv.8',
                      color: Colors.white70,
                      bgColor: Colors.white.withValues(alpha: 0.1),
                      isItalic: true,
                    ),
                    const _Label(
                      icon: Icons.location_on_rounded,
                      text: '北京',
                      color: Colors.white54,
                      bgColor: Colors.transparent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              _ActionButton(icon: Icons.edit_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _ActionButton(icon: Icons.share_rounded, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _BioSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Text(
        '热爱光影艺术，专注独立电影。每年观影量 300+，很高兴在这里遇见同好。',
        style: TextStyle(
          fontSize: 14,
          color: colors.textSecondary,
          height: 1.5,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    this.icon,
    required this.color,
    required this.bgColor,
    this.isItalic = false,
  });

  final String text;
  final IconData? icon;
  final Color color;
  final Color bgColor;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              fontStyle: isItalic ? FontStyle.italic : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}


class _LibrarySubTab extends StatelessWidget {

  const _LibrarySubTab({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? colors.textPrimary : colors.textTertiary,
            ),
          ),
          if (isSelected) 
            Container(
              margin: const EdgeInsets.only(top: 14),
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: colors.textPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabDelegate({required this.child, required this.height});
  final Widget child;
  final double height;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) => oldDelegate.height != height;
}
