import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

/// 用户标签类型枚举
/// 
/// 定义用户切换区域的三种标签类型：
/// - [friends]：好友列表
/// - [followers]：粉丝列表
/// - [following]：关注列表
enum UserTabType {
  /// 好友列表
  friends,
  /// 粉丝列表
  followers,
  /// 关注列表
  following,
}

/// 用户切换区域组件
///
/// 显示三个标签页：好友、粉丝、关注。
/// 实现选中态下划线指示器和选中/未选中样式切换。
///
/// 视觉规格（遵循 Requirements 3.1-3.7, 7.1-7.3）：
/// - Tab 间距：[AppSpacing.xl] (24px)
/// - 选中态：[AppColors.foreground]，FontWeight.bold，下划线 20x3px
/// - 未选中态：[AppColors.mutedForeground]，FontWeight.normal
/// - 下划线颜色：[AppColors.foreground]
/// 
/// 无障碍支持：
/// - 每个标签使用 [Semantics] 提供按钮语义
/// - 标记选中状态供屏幕阅读器识别
/// 
/// 示例用法：
/// ```dart
/// UserTabSection(
///   contentBuilder: (tabType) {
///     return UserAvatarRow(users: getUsersForTab(tabType));
///   },
///   onTabChanged: (tabType) {
///     print('切换到: $tabType');
///   },
/// )
/// ```
/// 
/// 参见：
/// - [UserTabType] - 标签类型枚举
/// - [UserAvatarRow] - 用户头像行组件
/// - [getTabLabel] - 获取标签显示文本的辅助函数
class UserTabSection extends StatefulWidget {
  /// 初始选中的标签
  /// 
  /// 默认为 [UserTabType.friends]
  final UserTabType initialTab;

  /// 标签切换回调
  /// 
  /// 当用户切换标签时触发，参数为新选中的标签类型
  final void Function(UserTabType type)? onTabChanged;

  /// 内容构建器
  /// 
  /// 根据当前选中的标签构建对应的内容区域
  final Widget Function(UserTabType type)? contentBuilder;

  /// 创建用户切换区域组件
  const UserTabSection({
    super.key,
    this.initialTab = UserTabType.friends,
    this.onTabChanged,
    this.contentBuilder,
  });

  @override
  State<UserTabSection> createState() => UserTabSectionState();
}

/// UserTabSection 的状态类
/// 
/// 公开以便测试可以访问当前选中的标签
class UserTabSectionState extends State<UserTabSection> {
  late UserTabType _currentTab;

  /// 获取当前选中的标签
  UserTabType get currentTab => _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  /// 切换标签
  /// 
  /// [tab] 要切换到的标签类型
  void switchTab(UserTabType tab) {
    if (_currentTab != tab) {
      setState(() {
        _currentTab = tab;
      });
      widget.onTabChanged?.call(tab);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildTabButton(UserTabType.friends, '好友'),
              _buildTabButton(UserTabType.followers, '粉丝'),
              _buildTabButton(UserTabType.following, '关注'),
            ],
          ),
        ),
        // 内容区域
        if (widget.contentBuilder != null)
          widget.contentBuilder!(_currentTab),
      ],
    );
  }

  /// 构建标签按钮
  /// 
  /// [tab] 标签类型
  /// [label] 显示的标签文本
  Widget _buildTabButton(UserTabType tab, String label) {
    final isSelected = _currentTab == tab;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      child: Semantics(
        label: '$label标签',
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: () => switchTab(tab),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.foreground
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // 下划线指示器
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.foreground : Colors.transparent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 获取标签的显示文本
/// 
/// [type] 标签类型
/// 
/// 返回对应的中文标签文本：
/// - [UserTabType.friends] → "好友"
/// - [UserTabType.followers] → "粉丝"
/// - [UserTabType.following] → "关注"
String getTabLabel(UserTabType type) {
  switch (type) {
    case UserTabType.friends:
      return '好友';
    case UserTabType.followers:
      return '粉丝';
    case UserTabType.following:
      return '关注';
  }
}
