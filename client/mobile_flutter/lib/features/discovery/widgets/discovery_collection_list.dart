import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

class DiscoveryCollectionList extends StatelessWidget {
  const DiscoveryCollectionList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return Container(
              width: 240,
              decoration: BoxDecoration(
                color: AppColors.of(context).surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage("https://picsum.photos/400/200"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "精选片单 #$index",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "编辑精选 · 20 部",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
