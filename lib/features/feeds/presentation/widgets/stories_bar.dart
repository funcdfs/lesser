import 'package:flutter/material.dart';

/// 日常状态栏 (Stories Bar)
///
/// 显示：
/// - 用户和好友的日常限时状态
/// - 横向滚动列表
/// - 可点击查看完整的 Story
class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                // 跳转到 Story 全屏查看页
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StoryViewScreen(storyIndex: 0),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: const CircleAvatar(child: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'User',
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 日常限时状态全屏查看页
///
/// 显示：
/// - 当前 Story 的完整内容
/// - 顶部进度条（显示 Story 的播放进度）
/// - 支持滑动查看上一个/下一个 Story
class StoryViewScreen extends StatefulWidget {
  final int storyIndex;

  const StoryViewScreen({super.key, required this.storyIndex});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.storyIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story 内容
          Center(
            child: Container(
              color: Colors.grey[800],
              child: const Icon(Icons.image, color: Colors.white, size: 60),
            ),
          ),
          // 顶部进度条
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    height: 2,
                    color: index < _currentIndex ? Colors.white : Colors.grey,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              ),
            ),
          ),
          // 关闭按钮
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
