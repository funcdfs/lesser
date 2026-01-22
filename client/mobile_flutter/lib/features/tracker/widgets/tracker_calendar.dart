import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

class TrackerCalendar extends StatelessWidget {
  const TrackerCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'This Week',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.of(context).textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final isToday = index == 2; // Mock "Today"
                final colorScheme = AppColors.of(context);
                return Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: isToday
                        ? colorScheme.accent
                        : colorScheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday
                              ? colorScheme.surfaceBase
                              : colorScheme.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${22 + index}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? colorScheme.surfaceBase
                              : colorScheme.textPrimary,
                        ),
                      ),
                      if (index % 2 == 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday
                                ? colorScheme.surfaceBase
                                : colorScheme.accent,
                          ),
                        )
                      ]
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
