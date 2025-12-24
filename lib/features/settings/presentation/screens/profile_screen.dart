import 'package:flutter/material.dart';

/// 个人资料和设置页面
///
/// 负责：
/// - 显示用户信息
/// - 编辑资料
/// - 应用设置
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 打开设置
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户头像和基本信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, child: Icon(Icons.person)),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('@username', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  const Text(
                    'This is your bio description',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Following', '123'),
                      _buildStatColumn('Followers', '456'),
                      _buildStatColumn('Posts', '78'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Edit Profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Follow'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            // 用户动态（Posts）
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Posts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.image)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // 账号设置
          const _SettingsSection(title: 'Account'),
          _SettingsTile(
            title: 'Email',
            subtitle: 'your@email.com',
            onTap: () {},
          ),
          _SettingsTile(
            title: 'Phone',
            subtitle: '+1 234 567 8900',
            onTap: () {},
          ),
          const Divider(),
          // 隐私设置
          const _SettingsSection(title: 'Privacy & Security'),
          _SettingsToggleTile(
            title: 'Private Account',
            subtitle: 'Only approved followers can see your posts',
            value: false,
            onChanged: (value) {},
          ),
          _SettingsToggleTile(
            title: 'Show Online Status',
            value: true,
            onChanged: (value) {},
          ),
          const Divider(),
          // 通知设置
          const _SettingsSection(title: 'Notifications'),
          _SettingsToggleTile(
            title: 'Push Notifications',
            value: true,
            onChanged: (value) {},
          ),
          _SettingsToggleTile(
            title: 'Email Notifications',
            value: false,
            onChanged: (value) {},
          ),
          const Divider(),
          // 其他
          const _SettingsSection(title: 'Other'),
          _SettingsTile(title: 'About', onTap: () {}),
          _SettingsTile(title: 'Help & Support', onTap: () {}),
          _SettingsTile(title: 'Logout', onTap: () {}),
        ],
      ),
    );
  }
}

/// 设置部分标题
class _SettingsSection extends StatelessWidget {
  final String title;

  const _SettingsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// 设置项
class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// 设置开关项
class _SettingsToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
