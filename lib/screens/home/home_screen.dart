import 'package:flutter/material.dart';
import '../../config/shadcn_theme.dart';
import '../feed/feed_screen.dart';
import '../feed/stories_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadcnColors.background,
      appBar: AppBar(
        backgroundColor: ShadcnColors.background,
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          indicatorColor: ShadcnColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: ShadcnColors.foreground,
          unselectedLabelColor: ShadcnColors.mutedForeground,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '关注'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: const [
          // Recommend Feed (No Stories)
          FeedScreen(feedMode: 'trending'),
          // Follow Feed (With Stories)
          _FollowFeed(),
        ],
      ),
    );
  }
}

class _FollowFeed extends StatelessWidget {
  const _FollowFeed();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: StoriesBar(),
        ),
        const SliverToBoxAdapter(
          child: Divider(color: ShadcnColors.border, thickness: 1, height: 1),
        ),
        // We need the feed list here. Since FeedScreen was a Scaffold, we need to extract the list part.
        // For now, I will assume I can modify FeedScreen to be just the list or refactor it.
        // Using a modified FeedScreen wrapper for now that works as a sliver would be ideal, 
        // but FeedScreen returns a Scaffold.
        // Let's assume FeedScreen will be refactored to return just the list content or I will inline it here later.
        // Actually, to make it work *now*, I should probably refactor FeedScreen first or make a re-usable
        // SliverFeedList widget.
        // For this step, I will simply embed the FeedScreen logic refactored.
        
        // Waiting for FeedScreen refactor.
        // But to make this compile and work, I will use a placeholder or the refactored widget.
        // Let's use the to-be-created `FeedList` widget.
        const FeedList(feedMode: 'following'),
      ],
    );
  }
}
