import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

class DiscoveryNewsList extends StatelessWidget {
  const DiscoveryNewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.of(context).surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: NetworkImage("https://picsum.photos/160/120"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  "资讯标题 #$index",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "这里是资讯摘要内容，可以展示更多详细信息...",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.of(context).textTertiary,
                ),
              ),
            ),
          );
        },
        childCount: 5,
      ),
    );
  }
}
