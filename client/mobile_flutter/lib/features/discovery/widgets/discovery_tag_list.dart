import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

class DiscoveryTagList extends StatelessWidget {
  const DiscoveryTagList({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
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
}
