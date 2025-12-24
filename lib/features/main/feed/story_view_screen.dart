import 'package:flutter/material.dart';
import '../../common/data/mock_data.dart';
import '../../common/widgets/shadcn/shadcn_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../common/utils/inner_drag_lock.dart';

/// 全屏故事浏览屏幕
///
/// 该组件模拟了类 Instagram/Threads 的故事(Story)交互逻辑：
/// - 支持左右点击切换故事。
/// - 支持滑动切换不同用户。
/// - 带有顶部进度条。
/// - 支持简单的私信和点赞交互模拟。
class StoryViewScreen extends StatefulWidget {
  /// 拥有故事的用户列表
  final List<User> users;

  /// 初始定位的用户索引
  final int initialUserIndex;

  const StoryViewScreen({
    super.key,
    required this.users,
    required this.initialUserIndex,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  /// 页面控制器，用于处理用户间左右滑动
  late PageController _pageController;

  /// 当前正在查看的用户索引
  int _currentUserIndex = 0;

  /// 当前正在查看该用户的第几个故事
  int _currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _pageController = PageController(initialPage: widget.initialUserIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 跳转至下一个故事
  void _nextStory() {
    final stories = mockStories[widget.users[_currentUserIndex].id] ?? [];
    if (_currentStoryIndex < stories.length - 1) {
      // 如果当前用户还有下一个故事，则自增索引
      setState(() {
        _currentStoryIndex++;
      });
    } else {
      // 否则，尝试切换到下一个用户
      if (_currentUserIndex < widget.users.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // 如果已经是最后一个用户的最后一个故事，则关闭视图
        Navigator.pop(context);
      }
    }
  }

  /// 跳转至上一个故事
  void _previousStory() {
    if (_currentStoryIndex > 0) {
      // 如果当前用户还有上一个故事
      setState(() {
        _currentStoryIndex--;
      });
    } else {
      // 否则，尝试切换回上一个用户
      if (_currentUserIndex > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 透明背景，提升层级感
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // 点击遮罩层外区域关闭
        child: Container(
          color: Colors.black54, // 半透明背景调暗
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                InnerDragLock.start();
              } else if (notification is ScrollEndNotification) {
                InnerDragLock.end();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.users.length,
              onPageChanged: (index) {
                setState(() {
                  _currentUserIndex = index;
                  _currentStoryIndex = 0; // 切换用户时，重置故事预览点
                });
              },
              itemBuilder: (context, index) {
                final user = widget.users[index];
                final stories = mockStories[user.id] ?? [];

                if (stories.isEmpty) {
                  return Center(
                    child: Text(
                      '用户 ${user.name} 暂无故事',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final safeStoryIndex = _currentStoryIndex >= stories.length
                    ? 0
                    : _currentStoryIndex;
                final story = stories[safeStoryIndex];

                return Center(
                  child: GestureDetector(
                    onTap: () {}, // 阻止层级传递到外层的 PageView
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 60,
                      ), // 上下留白，模拟悬浮卡片感
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 背景图片
                          CachedNetworkImage(
                            imageUrl: story.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error, color: Colors.white),
                            ),
                          ),

                          // 核心交互区域（点击左侧 1/3 向前，点击右侧 2/3 向后）
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 100, // 底部留出 100 像素作为功能栏点击区
                            child: GestureDetector(
                              onTapUp: (details) {
                                final width = MediaQuery.of(context).size.width;
                                if (details.localPosition.dx < width / 3) {
                                  _previousStory();
                                } else {
                                  _nextStory();
                                }
                              },
                              child: Container(color: Colors.transparent),
                            ),
                          ),

                          // 顶部状态信息（进度条、用户信息、关闭按钮）
                          Positioned(
                            top: 20,
                            left: 10,
                            right: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 进度条组
                                Row(
                                  children: List.generate(stories.length, (i) {
                                    return Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: i == safeStoryIndex
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.3,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            1.5,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 10),
                                // 用户头像和名称
                                Row(
                                  children: [
                                    ShadcnAvatar(
                                      avatarUrl: user.avatar,
                                      fallbackInitials: user.name,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _getTimeAgo(story.timestamp),
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 底部交互栏（输入框、点赞、分享）
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 20,
                            child: Row(
                              children: [
                                // 模拟回复输入框
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "发送私信...",
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // 点赞
                                _buildCircleActionButton(
                                  icon: Icons.favorite_border,
                                  onTap: () => _showSnackBar("已点赞"),
                                ),

                                const SizedBox(width: 12),

                                // 分享
                                _buildCircleActionButton(
                                  icon: Icons.share_outlined,
                                  onTap: () => _showSnackBar("已分享"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 构建圆形的辅助操作按钮（点赞、分享等）
  Widget _buildCircleActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  /// 显示简单的提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 计算并格式化发布时间（例如：1h, 5m）
  String _getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inMinutes}m';
    }
  }
}
