import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

/// 用户数据模型
/// 
/// 表示用户的基本信息，用于在 [UserAvatarRow] 中显示用户头像和名称。
/// 
/// 示例用法：
/// ```dart
/// const user = UserItem(
///   id: '1',
///   name: '小明',
///   avatarUrl: 'https://example.com/avatar.jpg',
///   isOnline: true,
/// );
/// ```
class UserItem {
  /// 用户 ID
  /// 
  /// 用于唯一标识用户
  final String id;

  /// 用户名
  /// 
  /// 显示在头像下方
  final String name;

  /// 头像 URL
  /// 
  /// 如果为空字符串，将显示默认头像图标
  final String avatarUrl;

  /// 是否在线
  /// 
  /// 可用于显示在线状态指示器（当前未实现）
  final bool isOnline;

  /// 用户状态
  /// 
  /// 可选的状态文本，如"在线"、"离线"等
  final String? status;

  /// 创建用户数据模型
  const UserItem({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
    this.status,
  });
}

/// 用户头像行组件
///
/// 横向滚动的用户头像列表，末尾带有"查看全部"按钮。
///
/// 视觉规格（遵循 Requirements 4.1-4.6, 7.1-7.3）：
/// - 头像：48px 圆形
/// - 用户名：12px，[AppColors.foreground]，居中
/// - 间距：[AppSpacing.md] (12px)
/// - 查看全部按钮：灰色圆形背景 + chevron_right 图标
/// 
/// 无障碍支持：
/// - 每个用户头像使用 [Semantics] 提供按钮语义
/// - 包含用户名称的描述标签
/// - "查看全部"按钮有明确的语义标签
/// 
/// 示例用法：
/// ```dart
/// UserAvatarRow(
///   users: [
///     UserItem(id: '1', name: '小明', avatarUrl: '...'),
///     UserItem(id: '2', name: '小红', avatarUrl: '...'),
///   ],
///   onUserTap: (user) {
///     print('点击了用户: ${user.name}');
///   },
///   onViewAll: () {
///     print('查看全部');
///   },
/// )
/// ```
/// 
/// 参见：
/// - [UserItem] - 用户数据模型
/// - [UserTabSection] - 用户切换区域组件
class UserAvatarRow extends StatelessWidget {
  /// 用户列表
  final List<UserItem> users;

  /// 用户点击回调
  /// 
  /// 当用户点击某个头像时触发
  final void Function(UserItem user)? onUserTap;

  /// 查看全部回调
  /// 
  /// 当用户点击"查看全部"按钮时触发
  final VoidCallback? onViewAll;

  /// 行高度
  /// 
  /// 默认为 100px
  final double height;

  /// 创建用户头像行组件
  const UserAvatarRow({
    super.key,
    required this.users,
    this.onUserTap,
    this.onViewAll,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: users.length + 1, // +1 for "查看全部" button
        itemBuilder: (context, index) {
          if (index == users.length) {
            return _buildViewAllButton(context);
          }
          return _buildUserAvatar(context, users[index]);
        },
      ),
    );
  }

  /// 构建用户头像项
  /// 
  /// [context] - 构建上下文
  /// [user] - 用户数据
  Widget _buildUserAvatar(BuildContext context, UserItem user) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Semantics(
        label: '用户 ${user.name}',
        button: true,
        child: GestureDetector(
          onTap: onUserTap != null ? () => onUserTap!(user) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头像：48px 圆形
              CircleAvatar(
                radius: 24, // 48px diameter
                backgroundImage: user.avatarUrl.isNotEmpty 
                    ? NetworkImage(user.avatarUrl) 
                    : null,
                backgroundColor: AppColors.secondary,
                child: user.avatarUrl.isEmpty 
                    ? Icon(
                        Icons.person,
                        color: AppColors.mutedForeground,
                        size: 24,
                        semanticLabel: null, // 由父级 Semantics 处理
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              // 用户名：12px，居中
              SizedBox(
                width: 56,
                child: Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建"查看全部"按钮
  /// 
  /// [context] - 构建上下文
  Widget _buildViewAllButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Semantics(
        label: '查看全部用户',
        button: true,
        child: GestureDetector(
          onTap: onViewAll,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 圆形背景 + chevron_right 图标
              CircleAvatar(
                radius: 24, // 48px diameter
                backgroundColor: AppColors.secondary,
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.foreground,
                  size: 24,
                  semanticLabel: null, // 由父级 Semantics 处理
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // "查看全部"文字
              SizedBox(
                width: 56,
                child: Text(
                  '查看全部',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
