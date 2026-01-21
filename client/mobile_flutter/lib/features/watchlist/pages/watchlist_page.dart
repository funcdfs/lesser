import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Watchlist & News'),
            floating: true,
          ),
          
          _buildSectionHeader(context, "Watch Later"),
          _buildHorizontalList(context, 10, "Saved", Colors.orange),
          
          _buildSectionHeader(context, "Top News"),
           _buildNewsList(context),

          // Add extra padding for bottom nav
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.of(context).textPrimary)),
            Text("10+ More", style: TextStyle(color: AppColors.of(context).textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, int count, String labelPrefix, Color baseColor) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return Container(
              width: 100,
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text("$labelPrefix #$index", style: TextStyle(color: AppColors.of(context).textPrimary)),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildNewsList(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListTile(
            leading: Container(width: 60, height: 60, color: Colors.grey.withValues(alpha: 0.2)),
            title: Text("Breaking News Title #$index"),
            subtitle: Text("Short summary of the news content..."),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          );
        },
        childCount: 10,
      ),
    );
  }
}
