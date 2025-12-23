import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../config/shadcn_theme.dart';
import '../widgets/shadcn/shadcn_card.dart';
import '../widgets/shadcn/shadcn_list_tile.dart';
import '../widgets/shadcn/shadcn_icon_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  final bool _isVipMember = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadcnColors.zinc50,
      body: CustomScrollView(
        slivers: [
          // Personal Info Card Section
          SliverToBoxAdapter(
            child: _buildPersonalCard(),
          ),

          // Membership Settings
          SliverToBoxAdapter(
            child: _buildMembershipSection(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: ShadcnSpacing.md),
          ),

          // Publishing Control Panel
          SliverToBoxAdapter(
            child: _buildPublishingPanel(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: ShadcnSpacing.md),
          ),

          // Feedback & Contact
          SliverToBoxAdapter(
            child: _buildFeedbackSection(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: ShadcnSpacing.md),
          ),

          // App Settings
          SliverToBoxAdapter(
            child: _buildAppSettings(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: ShadcnSpacing.xl2),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalCard() {
    return Container(
      margin: const EdgeInsets.all(ShadcnSpacing.lg),
      padding: const EdgeInsets.all(ShadcnSpacing.xl2),
      decoration: BoxDecoration(
        color: ShadcnColors.card,
        borderRadius: BorderRadius.circular(ShadcnRadius.lg),
        border: Border.all(color: ShadcnColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ShadcnColors.secondary,
                  border: Border.all(
                    color: ShadcnColors.border,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 36,
                  color: ShadcnColors.mutedForeground,
                ),
              ),
              const SizedBox(width: ShadcnSpacing.lg),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '用户昵称',
                          style: TextStyle(
                            color: ShadcnColors.foreground,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (_isVipMember) ...[
                          const SizedBox(width: ShadcnSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ShadcnSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ShadcnColors.foreground,
                              borderRadius: BorderRadius.circular(ShadcnRadius.sm),
                            ),
                            child: const Text(
                              'VIP',
                              style: TextStyle(
                                color: ShadcnColors.background,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'ID: 123456789',
                      style: TextStyle(
                        color: ShadcnColors.mutedForeground,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: ShadcnSpacing.sm),
                    const Text(
                      '热爱生活，分享美好',
                      style: TextStyle(
                        color: ShadcnColors.mutedForeground,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Button
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.edit_outlined,
                  color: ShadcnColors.mutedForeground,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: ShadcnSpacing.xl),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('328', '关注'),
              Container(
                width: 1,
                height: 32,
                color: ShadcnColors.border,
              ),
              _buildStatItem('1.2K', '粉丝'),
              Container(
                width: 1,
                height: 32,
                color: ShadcnColors.border,
              ),
              _buildStatItem('86', '发布'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: ShadcnColors.foreground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: ShadcnColors.mutedForeground,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.lg),
      child: ShadcnCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.workspace_premium,
                iconColor: Color(0xFFF59E0B),
              ),
              title: '会员中心',
              subtitle: _isVipMember ? 'VIP会员 享受专属权益' : '开通会员 解锁更多功能',
              trailing: _isVipMember
                  ? const Icon(Icons.chevron_right, 
                      color: ShadcnColors.mutedForeground, size: 20)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ShadcnSpacing.md,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ShadcnColors.foreground,
                        borderRadius: BorderRadius.circular(ShadcnRadius.full),
                      ),
                      child: const Text(
                        '立即开通',
                        style: TextStyle(
                          color: ShadcnColors.background,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.palette_outlined,
                iconColor: Color(0xFFEC4899),
              ),
              title: '个性化设置',
              subtitle: '自定义您的发布样式',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishingPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.lg),
      child: ShadcnCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(ShadcnSpacing.lg),
              child: Text(
                '我的发布',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ShadcnColors.foreground,
                ),
              ),
            ),
            const Divider(height: 1),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.article_outlined,
                iconColor: Color(0xFF3B82F6),
              ),
              title: '我的文章',
              subtitle: '查看和管理已发布的文章',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.drafts_outlined,
                iconColor: Color(0xFF8B5CF6),
              ),
              title: '草稿箱',
              subtitle: '8篇草稿',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.favorite_outline,
                iconColor: Color(0xFFEC4899),
              ),
              title: '我的收藏',
              subtitle: '126个收藏',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.bar_chart_outlined,
                iconColor: Color(0xFF10B981),
              ),
              title: '数据统计',
              subtitle: '查看发布数据和互动情况',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.lg),
      child: ShadcnCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.feedback_outlined,
                iconColor: Color(0xFFF59E0B),
              ),
              title: '意见反馈',
              subtitle: '告诉我们您的建议',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.support_agent_outlined,
                iconColor: Color(0xFF06B6D4),
              ),
              title: '联系客服',
              subtitle: '在线客服 09:00-21:00',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.help_outline,
                iconColor: Color(0xFF6366F1),
              ),
              title: '帮助中心',
              subtitle: '常见问题与使用指南',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ShadcnSpacing.lg),
      child: ShadcnCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(ShadcnSpacing.lg),
              child: Text(
                '应用设置',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ShadcnColors.foreground,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ShadcnSpacing.lg,
                vertical: ShadcnSpacing.md,
              ),
              child: Row(
                children: [
                  const ShadcnIconContainer(
                    icon: Icons.dark_mode_outlined,
                    iconColor: ShadcnColors.zinc700,
                  ),
                  const SizedBox(width: ShadcnSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '深色模式',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ShadcnColors.foreground,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '保护眼睛，节省电量',
                          style: TextStyle(
                            fontSize: 13,
                            color: ShadcnColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                    },
                    activeTrackColor: ShadcnColors.foreground,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.notifications_outlined,
                iconColor: Color(0xFFEF4444),
              ),
              title: '通知设置',
              subtitle: '管理推送通知',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.language_outlined,
                iconColor: Color(0xFF14B8A6),
              ),
              title: '语言设置',
              subtitle: '简体中文',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.privacy_tip_outlined,
                iconColor: Color(0xFF78716C),
              ),
              title: '隐私设置',
              subtitle: '账号与隐私管理',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 60),
            ShadcnListTile(
              leading: const ShadcnIconContainer(
                icon: Icons.info_outline,
                iconColor: ShadcnColors.zinc600,
              ),
              title: '关于我们',
              subtitle: 'v1.0.0',
              trailing: const Icon(Icons.chevron_right, 
                  color: ShadcnColors.mutedForeground, size: 20),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

