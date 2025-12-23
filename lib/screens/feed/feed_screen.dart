import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/post.dart';
import '../../config/shadcn_theme.dart';
import '../../widgets/post_card.dart';
import '../detail_screen.dart';

class FeedScreen extends StatelessWidget {
  final String feedMode;

  const FeedScreen({
    super.key,
    required this.feedMode,
  });

  @override
  Widget build(BuildContext context) {
    // If we want to support pulling to refresh or other scroll effects, 
    // wrapping in CustomScrollView is good.
    return CustomScrollView(
      slivers: [
        FeedList(feedMode: feedMode),
      ],
    );
  }
}

class FeedList extends StatelessWidget {
  final String feedMode;

  const FeedList({
    super.key,
    required this.feedMode,
  });

  void _navigateToDetail(BuildContext context, Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine data based on feedMode
    // For now we just use mockPosts for both, maybe shuffle or filter if we had real data
    final posts = mockPosts; 

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final post = posts[index % posts.length];
        return Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: ShadcnColors.border)),
          ),
          child: PostCard(
            post: post,
            onTap: () => _navigateToDetail(context, post),
          ),
        );
      }, childCount: 10),
    );
  }
}
