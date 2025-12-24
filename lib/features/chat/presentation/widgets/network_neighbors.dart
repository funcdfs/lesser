import 'package:flutter/material.dart';

/// 网络邻居组件
///
/// 显示：
/// - 我的好友
/// - 我的粉丝
/// - 创建群组等外显功能
class NetworkNeighborsWidget extends StatelessWidget {
  const NetworkNeighborsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Network',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // 好友列表
          _buildSectionTitle('Friends'),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildNetworkMember('Friend $index', 'Active now'),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 粉丝列表
          _buildSectionTitle('Followers'),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildNetworkMember('Follower $index', 'Follow back'),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 创建群组按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.group_add),
              label: const Text('Create Group'),
              onPressed: () {
                // 创建群组
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildNetworkMember(String name, String status) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person)),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(status, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
