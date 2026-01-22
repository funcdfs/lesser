import 'package:flutter/material.dart';

class TrackerNewsList extends StatelessWidget {
  const TrackerNewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListTile(
            leading: Container(
              width: 60,
              height: 60,
              color: Colors.grey.withValues(alpha: 0.2),
            ),
            title: Text('Breaking News Title #$index'),
            subtitle: const Text('Short summary of the news content...'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          );
        },
        childCount: 10,
      ),
    );
  }
}
