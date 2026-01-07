// 组件展示测试页

import 'package:flutter/material.dart';
import '../../../pkg/ui/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLiked = false;
  bool _isReposted = false;
  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('组件展示', style: TextStyle(fontWeight: FontWeight.w600)),
            centerTitle: true,
            floating: true,
            backgroundColor: Color(0xFFFAFAFA),
            elevation: 0,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _card(
                  title: '头像',
                  subtitle: '涟漪扩散',
                  child: Row(
                    children: [
                      AvatarButton(size: 48, placeholder: 'A', onTap: () {}),
                      const SizedBox(width: 12),
                      AvatarButton(size: 40, placeholder: 'B', onTap: () {}),
                      const SizedBox(width: 12),
                      AvatarButton(size: 32, placeholder: 'C', onTap: () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _card(
                  title: '点赞',
                  subtitle: '彩色烟花',
                  child: Row(
                    children: [
                      LikeButton(onTap: () {}),
                      const SizedBox(width: 32),
                      LikeButton(isLiked: true, onTap: () {}),
                      const SizedBox(width: 32),
                      LikeButton(
                        isLiked: _isLiked,
                        count: _isLiked ? 129 : 128,
                        onTap: () => setState(() => _isLiked = !_isLiked),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _card(
                  title: '评论 / 转发 / 分享 / 更多',
                  subtitle: '弹跳',
                  child: Row(
                    children: [
                      CommentButton(count: 32, onTap: () {}),
                      const SizedBox(width: 24),
                      RepostButton(
                        isReposted: _isReposted,
                        count: _isReposted ? 65 : 64,
                        onTap: () => setState(() => _isReposted = !_isReposted),
                      ),
                      const SizedBox(width: 24),
                      ShareButton(onTap: () {}),
                      const SizedBox(width: 24),
                      MoreButton(onTap: () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _card(
                  title: '开关',
                  subtitle: '弹性滑动',
                  child: Row(
                    children: [
                      ToggleSwitch(
                        value: _switchValue,
                        onChanged: (v) => setState(() => _switchValue = v),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _switchValue ? '开' : '关',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(width: 24),
                      ToggleSwitch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 12),
                      ToggleSwitch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: const Color(0xFF2196F3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _sectionTitle('实际场景'),
                const SizedBox(height: 12),
                _postCard(),
                const SizedBox(height: 12),
                _postCard2(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _postCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarButton(size: 40, placeholder: 'U', onTap: () {}),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户名',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '2 小时前',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
              MoreButton(size: 20, onTap: () {}),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '点击爱心查看彩色烟花特效 🎆',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              LikeButton(
                isLiked: _isLiked,
                count: _isLiked ? 129 : 128,
                size: 20,
                onTap: () => setState(() => _isLiked = !_isLiked),
              ),
              const SizedBox(width: 28),
              CommentButton(count: 32, size: 20, onTap: () {}),
              const SizedBox(width: 28),
              RepostButton(
                isReposted: _isReposted,
                count: _isReposted ? 17 : 16,
                size: 20,
                onTap: () => setState(() => _isReposted = !_isReposted),
              ),
              const Spacer(),
              ShareButton(size: 20, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postCard2() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarButton(size: 40, placeholder: 'L', onTap: () {}),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lesser',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '官方账号',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
              MoreButton(size: 20, onTap: () {}),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '欢迎使用 Lesser 社交平台！\n\n这是一个类似 X.com 的社交应用，采用纯 gRPC 微服务架构，支持实时聊天和广播频道。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              LikeButton(isLiked: true, count: 1024, size: 20, onTap: () {}),
              const SizedBox(width: 28),
              CommentButton(isActive: true, count: 256, size: 20, onTap: () {}),
              const SizedBox(width: 28),
              RepostButton(
                isReposted: true,
                count: 512,
                size: 20,
                onTap: () {},
              ),
              const Spacer(),
              ShareButton(size: 20, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
