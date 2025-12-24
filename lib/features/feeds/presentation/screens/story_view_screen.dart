import 'package:flutter/material.dart';

/// 日常限时状态全屏查看页面
///
/// 显示：
/// - 单个 Story 的全屏视图
/// - 进度条显示 Story 剩余时间
/// - 支持前后切换 Story
class StoryViewScreen extends StatefulWidget {
  /// Story 的唯一标识符
  final String storyId;

  const StoryViewScreen({super.key, required this.storyId});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story 内容
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 5, // 示例数量
            itemBuilder: (context, index) {
              return Container(
                color: Colors.grey[800],
                child: Center(
                  child: Text(
                    'Story $index',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              );
            },
          ),
          // 进度条
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 5,
                minHeight: 4,
                backgroundColor: Colors.grey[700],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          // 关闭按钮
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
