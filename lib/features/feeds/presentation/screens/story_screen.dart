import 'package:flutter/material.dart';
import '../widgets/stories_bar.dart';

/// 日常限时状态屏幕
///
/// 显示用户关注的人发布的日常状态（Stories）
/// 位于信息流顶部的横向滚动栏
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {
    return const StoriesBar();
  }
}
