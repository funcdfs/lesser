// =============================================================================
// 剧集详情页 AppBar - Detail App Bar Widget
// =============================================================================
//
// ## 设计目的
// 为剧集详情页提供统一的毛玻璃效果 AppBar，包含返回按钮、剧集信息和更多操作。
// 使用 Hero 动画实现从列表页到详情页的头像过渡效果。
//
// ## 视觉设计
// - 毛玻璃背景效果（FrostedAppBar）
// - 底部细线分隔
// - 剧集头像支持 Hero 动画
// - 显示剧集名称和订阅者数量
//
// ## 组件结构
// - leading: 返回按钮
// - title: 剧集标题组件（头像 + 名称 + 订阅数）
// - actions: 更多操作按钮
//
// ## 使用示例
// ```dart
// DetailAppBar(
//   series: _series,
//   seriesId: widget.seriesId,
//   moreButtonKey: _moreButtonKey,
//   onBack: () => Navigator.pop(context),
//   onMoreTap: _showMoreMenu,
// )
// ```
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';


import '../../../pkg/ui/widgets/widgets.dart';
import '../models/subject_model.dart';

/// 剧集详情页毛玻璃 AppBar
///
/// ## 参数说明
/// - [series]: 剧集数据模型（可为 null，加载中状态）
/// - [seriesId]: 剧集 ID，用于 Hero 动画 tag
/// - [moreButtonKey]: 更多按钮的 GlobalKey，用于弹出菜单定位
/// - [onBack]: 返回按钮回调
/// - [onMoreTap]: 更多按钮回调
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({
    super.key,
    required this.series,
    required this.seriesId,
    required this.moreButtonKey,
    required this.onBack,
    required this.onMoreTap,
  });

  final SubjectModel? series;
  final String seriesId;
  final GlobalKey moreButtonKey;
  final VoidCallback onBack;
  final VoidCallback onMoreTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final seriesData = series;

    return FrostedAppBar(
      blur: 20,
      opacity: 0.8,
      border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          size: 22,
          color: colors.textPrimary,
        ),
        onPressed: onBack,
      ),
      title: seriesData == null
          ? null
          : _SubjectTitle(subject: seriesData, subjectId: seriesId),
      actions: [
        IconButton(
          key: moreButtonKey,
          icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary),
          onPressed: onMoreTap,
        ),
      ],
    );
  }
}

/// 剧集标题组件
///
/// 显示剧集头像、名称和订阅者数量。
/// 头像使用 Hero 动画，实现从列表页到详情页的平滑过渡。
class _SubjectTitle extends StatelessWidget {
  const _SubjectTitle({required this.subject, required this.subjectId});

  final SubjectModel subject;
  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        // 头像 Hero
        Hero(
          tag: 'subject_avatar_$subjectId',
          placeholderBuilder: (_, size, child) =>
              SizedBox(width: size.width, height: size.height, child: child),
          child: AvatarButton(
            imageUrl: subject.coverUrl,
            size: 40,
            placeholder: subject.coverPlaceholder,
            enableTapScale: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subject.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              SubscriberBadge(
                count: subject.subscriberCount,
                size: SubscriberBadgeSize.small,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
