import 'package:flutter/material.dart';

class DiscoveryActorList extends StatelessWidget {
  const DiscoveryActorList({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
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
                Text("演员 $index", style: const TextStyle(fontSize: 12)),
              ],
            );
          },
        ),
      ),
    );
  }
}
