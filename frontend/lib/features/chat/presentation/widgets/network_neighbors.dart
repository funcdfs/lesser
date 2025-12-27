import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/app_cell.dart';

// 模拟用户数据类
class UserItem {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String? status;

  const UserItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
    this.status,
  });
}

// 定义标签类型枚举
enum NetworkTab { friends, followers, following }

class NetworkNeighborsWidget extends StatefulWidget {
  const NetworkNeighborsWidget({super.key});

  @override
  State<NetworkNeighborsWidget> createState() => _NetworkNeighborsWidgetState();
}

class _NetworkNeighborsWidgetState extends State<NetworkNeighborsWidget> {
  // 当前选中的标签
  NetworkTab _currentTab = NetworkTab.friends;

  // 切换标签的方法
  void _switchTab(NetworkTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  // 模拟好友数据
  final List<UserItem> _friends = const [
    UserItem(
      id: '1',
      name: '小明',
      avatarUrl: 'https://picsum.photos/seed/user1/200',
      isOnline: true,
      status: '在线',
    ),
    UserItem(
      id: '2',
      name: '小红',
      avatarUrl: 'https://picsum.photos/seed/user2/200',
      isOnline: false,
      status: '离线',
    ),
    UserItem(
      id: '3',
      name: '小李',
      avatarUrl: 'https://picsum.photos/seed/user3/200',
      isOnline: true,
      status: '在线',
    ),
    UserItem(
      id: '4',
      name: '小王',
      avatarUrl: 'https://picsum.photos/seed/user4/200',
      isOnline: false,
      status: '离线',
    ),
    UserItem(
      id: '5',
      name: '小张',
      avatarUrl: 'https://picsum.photos/seed/user5/200',
      isOnline: true,
      status: '在线',
    ),
  ];

  // 模拟粉丝数据
  final List<UserItem> _followers = const [
    UserItem(
      id: '6',
      name: '粉丝1',
      avatarUrl: 'https://picsum.photos/seed/follower1/200',
      isOnline: false,
    ),
    UserItem(
      id: '7',
      name: '粉丝2',
      avatarUrl: 'https://picsum.photos/seed/follower2/200',
      isOnline: true,
    ),
    UserItem(
      id: '8',
      name: '粉丝3',
      avatarUrl: 'https://picsum.photos/seed/follower3/200',
      isOnline: false,
    ),
  ];

  // 模拟关注数据
  final List<UserItem> _following = const [
    UserItem(
      id: '9',
      name: '关注1',
      avatarUrl: 'https://picsum.photos/seed/following1/200',
      isOnline: true,
    ),
    UserItem(
      id: '10',
      name: '关注2',
      avatarUrl: 'https://picsum.photos/seed/following2/200',
      isOnline: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 根据当前选中的标签获取对应的数据
    List<UserItem> getCurrentUsers() {
      switch (_currentTab) {
        case NetworkTab.friends:
          return _friends;
        case NetworkTab.followers:
          return _followers;
        case NetworkTab.following:
          return _following;
      }
    }

    // 根据当前选中的标签获取"查看全部"按钮文字
    String getMoreButtonText() {
      switch (_currentTab) {
        case NetworkTab.friends:
          return '查看全部好友';
        case NetworkTab.followers:
          return '查看全部粉丝';
        case NetworkTab.following:
          return '查看全部关注';
      }
    }

    final currentUsers = getCurrentUsers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签切换栏
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              _buildTabButton(NetworkTab.friends, '好友'),
              _buildTabButton(NetworkTab.followers, '粉丝'),
              _buildTabButton(NetworkTab.following, '关注'),
            ],
          ),
        ),

        // 横向滚动的用户卡片列表
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: currentUsers.length + 1, // +1 是为了添加"更多"按钮
            itemBuilder: (context, index) {
              if (index == currentUsers.length) {
                // 更多按钮
                return _buildMoreButton(context, getMoreButtonText());
              }
              return _buildUserCard(context, currentUsers[index]);
            },
          ),
        ),

        // 其他功能项保持不变
        const SizedBox(height: AppSpacing.lg),
        AppCell(
          title: '创建群聊',
          description: '创建新的群组聊天',
          leftIcon: Icons.group_add_outlined,
          showArrow: true,
          onTap: () {},
        ),

        AppCell(
          title: '创建频道',
          description: '创建新的频道',
          leftIcon: Icons.campaign_outlined,
          showArrow: true,
          onTap: () {},
        ),

        AppCell(
          title: '添加好友',
          description: '通过ID或二维码添加',
          leftIcon: Icons.person_add_alt_outlined,
          showArrow: true,
          onTap: () {},
        ),

        AppCell(
          title: '附近的人',
          description: '发现周围的朋友',
          leftIcon: Icons.location_on_outlined,
          showArrow: true,
          onTap: () {},
        ),
      ],
    );
  }

  // 构建用户卡片
  Widget _buildUserCard(BuildContext context, UserItem user) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          Stack(
            children: [
              // 用户头像
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              // 在线状态指示器
              if (user.isOnline) ...[
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // 用户名
          SizedBox(
            width: 72,
            child: Text(
              user.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 用户状态
          if (user.status != null) ...[
            SizedBox(
              width: 72,
              child: Text(
                user.status!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: user.isOnline
                      ? AppColors.success
                      : AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 构建标签按钮
  Widget _buildTabButton(NetworkTab tab, String label) {
    final isSelected = _currentTab == tab;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.lg),
      child: InkWell(
        onTap: () => _switchTab(tab),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.foreground
                    : AppColors.mutedForeground,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 构建更多按钮
  Widget _buildMoreButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.chevron_right, color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: 72,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
