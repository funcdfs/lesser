import 'package:flutter/material.dart';

/// Feed 图片组件
///
/// 负责显示 Feed 中的图片
class FeedImagesWidget extends StatelessWidget {
  const FeedImagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      height: 300,
      child: const Center(child: Icon(Icons.image, size: 60)),
    );
  }
}
