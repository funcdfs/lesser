// 组件展示测试页面

import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/app_theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // 状态
  bool _isLiked = false;
  int _likeCount = 128;
  bool _isCommented = false;
  int _commentCount = 42;
  bool _isReposted = false;
  int _repostCount = 16;
  bool _toggleValue = false;

  // 数字动画测试
  int _animCount = 99;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '组件展示',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: colors.surfaceBase,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: colors.surfaceBase,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 数字翻页动画
          _buildSection(
            '数字翻页动画 AnimatedCount',
            '数字变化时的滑动淡入淡出效果',
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _animCount -= 10),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _animCount--),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    const SizedBox(width: 16),
                    AnimatedCount(
                      count: _animCount,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => setState(() => _animCount++),
                      icon: const Icon(Icons.add_rounded),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _animCount += 10),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '当前值: $_animCount',
                  style: TextStyle(color: colors.textTertiary),
                ),
              ],
            ),
          ),

          // LikeButton
          _buildSection(
            '点赞按钮 LikeButton',
            '烟花特效 + 渐变红心',
            Row(
              children: [
                LikeButton(
                  isLiked: _isLiked,
                  count: _likeCount,
                  onTap: () => setState(() {
                    _isLiked = !_isLiked;
                    _likeCount += _isLiked ? 1 : -1;
                  }),
                ),
                const SizedBox(width: 32),
                const LikeButton(isLiked: false, count: 0),
                const SizedBox(width: 32),
                const LikeButton(isLiked: true, count: 9999),
              ],
            ),
          ),

          // CommentButton
          _buildSection(
            '评论按钮 CommentButton',
            '弹跳特效',
            Row(
              children: [
                CommentButton(
                  isActive: _isCommented,
                  count: _commentCount,
                  onTap: () => setState(() {
                    _isCommented = !_isCommented;
                    _commentCount += _isCommented ? 1 : -1;
                  }),
                ),
                const SizedBox(width: 32),
                const CommentButton(isActive: false, count: 0),
                const SizedBox(width: 32),
                const CommentButton(isActive: true, count: 1234),
              ],
            ),
          ),

          // RepostButton
          _buildSection(
            '转发按钮 RepostButton',
            '弹跳特效',
            Row(
              children: [
                RepostButton(
                  isReposted: _isReposted,
                  count: _repostCount,
                  onTap: () => setState(() {
                    _isReposted = !_isReposted;
                    _repostCount += _isReposted ? 1 : -1;
                  }),
                ),
                const SizedBox(width: 32),
                const RepostButton(isReposted: false, count: 0),
                const SizedBox(width: 32),
                const RepostButton(isReposted: true, count: 567),
              ],
            ),
          ),

          // ShareButton
          _buildSection(
            '分享按钮 ShareButton',
            '弹跳特效',
            Row(
              children: [
                ShareButton(onTap: () {}),
                const SizedBox(width: 32),
                const ShareButton(size: 20),
                const SizedBox(width: 32),
                const ShareButton(size: 28),
              ],
            ),
          ),

          // MoreButton
          _buildSection(
            '更多按钮 MoreButton',
            '弹跳特效',
            Row(
              children: [
                MoreButton(onTap: () {}),
                const SizedBox(width: 32),
                const MoreButton(size: 20),
                const SizedBox(width: 32),
                const MoreButton(size: 28),
              ],
            ),
          ),

          // AvatarButton
          _buildSection(
            '头像按钮 AvatarButton',
            '涟漪特效',
            Row(
              children: [
                AvatarButton(placeholder: 'A', size: 40, onTap: () {}),
                const SizedBox(width: 16),
                AvatarButton(placeholder: 'B', size: 48, onTap: () {}),
                const SizedBox(width: 16),
                AvatarButton(placeholder: 'C', size: 56, onTap: () {}),
              ],
            ),
          ),

          // ToggleSwitch
          _buildSection(
            '开关按钮 ToggleSwitch',
            '弹性滑动特效',
            Row(
              children: [
                ToggleSwitch(
                  value: _toggleValue,
                  onChanged: (v) => setState(() => _toggleValue = v),
                ),
                const SizedBox(width: 24),
                ToggleSwitch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: const Color(0xFFE91E63),
                ),
                const SizedBox(width: 24),
                ToggleSwitch(
                  value: false,
                  onChanged: (_) {},
                  width: 56,
                  height: 32,
                ),
              ],
            ),
          ),

          // 操作栏组合
          _buildSection(
            '操作栏组合',
            '模拟帖子底部操作栏',
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CommentButton(
                    isActive: _isCommented,
                    count: _commentCount,
                    onTap: () => setState(() {
                      _isCommented = !_isCommented;
                      _commentCount += _isCommented ? 1 : -1;
                    }),
                  ),
                  RepostButton(
                    isReposted: _isReposted,
                    count: _repostCount,
                    onTap: () => setState(() {
                      _isReposted = !_isReposted;
                      _repostCount += _isReposted ? 1 : -1;
                    }),
                  ),
                  LikeButton(
                    isLiked: _isLiked,
                    count: _likeCount,
                    onTap: () => setState(() {
                      _isLiked = !_isLiked;
                      _likeCount += _isLiked ? 1 : -1;
                    }),
                  ),
                  ShareButton(onTap: () {}),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.of(context).textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
