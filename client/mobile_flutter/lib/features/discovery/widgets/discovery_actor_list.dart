import 'package:flutter/material.dart';
import '../../../../pkg/ui/theme/theme.dart';

/// Actors 组件 - 匹配 HTML 设计，带排名和趋势指示器
class DiscoveryActorList extends StatelessWidget {
  const DiscoveryActorList({super.key});

  static const List<String> _actorNames = [
    'Timothée\nChalamet',
    'Florence\nPugh',
    'Zendaya',
    'John\nKrasinski',
    'Emily\nBlunt',
  ];

  static const List<int> _trends = [
    1, // 上升
    0, // 持平
    -1, // 下降
    0,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.of(context).accent;
    final surfaceElevated = AppColors.of(context).surfaceElevated;
    final textSecondary = AppColors.of(context).textSecondary;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _actorNames.length,
          itemBuilder: (context, index) {
            final isFirst = index == 0;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 头像
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isFirst
                                ? LinearGradient(
                                    colors: [
                                      accentColor,
                                      Colors.purple.shade500,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey.shade300,
                                      Colors.grey.shade500,
                                    ],
                                  ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipOval(
                            child: Image.network(
                              'https://picsum.photos/seed/actor$index/200/200',
                              fit: BoxFit.cover,
                              width: 66,
                              height: 66,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade400,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade400,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 32,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // 排名徽章
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isFirst
                                  ? Colors.blue.shade500
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 趋势指示器
                        if (_trends[index] != 0)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _trends[index] > 0
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: _trends[index] > 0
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                        if (_trends[index] == 0 && index == 1)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: surfaceElevated,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.remove,
                                color: Colors.grey.shade400,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 名字
                    Text(
                      _actorNames[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
