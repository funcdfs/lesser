import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';

class InspectionPage extends StatelessWidget {
  const InspectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Info / Discovery'),
            floating: true,
          ),
          _buildSectionHeader(context, "Today's Hot"),
          _buildHorizontalList(context, 10, "Movie", Colors.redAccent),
          
          _buildSectionHeader(context, "Weekly Hot"),
          _buildHorizontalList(context, 10, "Series", Colors.blueAccent),
          
          _buildSectionHeader(context, "Popular Tags"),
          _buildHorizontalChips(context, ["Sci-Fi", "Action", "Romance", "Zombie", "History", "Comedy"]),
          
          _buildSectionHeader(context, "Popular Actors"),
          _buildHorizontalAvatarList(context, 10),
          
          _buildSectionHeader(context, "More"),
          const SliverToBoxAdapter(
             child: Padding(
               padding: EdgeInsets.all(16.0),
               child: Center(child: Text("More content coming soon...")),
             ),
          ),
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
  
  Widget _buildHorizontalChips(BuildContext context, List<String> tags) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tags.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return Chip(
              label: Text(tags[index]), 
              backgroundColor: AppColors.of(context).surfaceElevated,
              side: BorderSide.none,
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildHorizontalAvatarList(BuildContext context, int count) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple.withValues(alpha: 0.2),
                  child: Text("A$index"),
                ),
                const SizedBox(height: 4),
                Text("Actor $index", style: const TextStyle(fontSize: 12)),
              ],
            );
          },
        ),
      ),
    );
  }
}
