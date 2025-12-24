import 'package:flutter/material.dart';

/// Feed 卡片骨架屏
///
/// 用于加载状态下显示占位符，改善用户体验
class FeedsCardSkeleton extends StatelessWidget {
  const FeedsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息骨架
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 80, color: Colors.grey[300]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 图片骨架
          Container(color: Colors.grey[200], height: 300),
          // 操作栏骨架
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(height: 20, width: 20, color: Colors.grey[300]),
                const SizedBox(width: 20),
                Container(height: 20, width: 20, color: Colors.grey[300]),
                const SizedBox(width: 20),
                Container(height: 20, width: 20, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
