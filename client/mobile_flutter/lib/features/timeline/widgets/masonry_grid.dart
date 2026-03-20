// Masonry 瀑布流布局组件

import 'package:flutter/material.dart';

/// Masonry 瀑布流布局
///
/// 自动将子组件分配到多列中，每列高度尽可能平衡
class MasonryGrid extends StatelessWidget {
  const MasonryGrid({
    super.key,
    required this.children,
    this.columnCount = 2,
    this.spacing = 16.0,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;
  final int columnCount;
  final double spacing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算每列宽度
          final columnWidth =
              (constraints.maxWidth - spacing * (columnCount - 1)) /
              columnCount;

          // 创建列
          final columns = List.generate(columnCount, (index) => <Widget>[]);

          // 分配子组件到各列（简单轮询分配）
          for (int i = 0; i < children.length; i++) {
            columns[i % columnCount].add(children[i]);
          }

          // 构建行
          final rowChildren = <Widget>[];
          for (int i = 0; i < columnCount; i++) {
            rowChildren.add(
              SizedBox(
                width: columnWidth,
                child: Column(
                  children: [
                    for (int j = 0; j < columns[i].length; j++) ...[
                      columns[i][j],
                      if (j < columns[i].length - 1) SizedBox(height: spacing),
                    ],
                  ],
                ),
              ),
            );
            if (i < columnCount - 1) {
              rowChildren.add(SizedBox(width: spacing));
            }
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          );
        },
      ),
    );
  }
}
