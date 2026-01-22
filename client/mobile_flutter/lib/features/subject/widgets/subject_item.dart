// =============================================================================
// 剧集列表项组件
// =============================================================================
//
// 显示剧集列表中的单个剧集项，包含头像、名称、订阅数、最后动态和状态信息。
//
// ## 布局结构
//
// ```
// ┌─────────────────────────────────────────────────────────────┐
// │  [头像]  │  剧集名称  订阅数      │  📌 🔕  时间           │
// │         │  最后动态预览...       │        未读数          │
// └─────────────────────────────────────────────────────────────┘
// ```
//
// ## 特性
//
// - Hero 动画：头像支持与详情页的共享元素过渡
// - 状态图标：显示置顶、静音状态
// - 未读徽章：显示未读动态数量
//
// ## 组件拆分
//
// 为保持代码清晰，将列表项拆分为多个私有 Widget：
// - `_SubjectAvatar` - 头像（带 Hero）
// - `_Content` - 中间内容区
// - `_LastPost` - 最后动态预览
// - `_Trailing` - 右侧状态区

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../models/subject_models.dart';
import 'subject_constants.dart';

/// 剧集列表项
///
/// 显示剧集的基本信息和状态，点击可进入剧集详情页。
class SubjectItem extends StatelessWidget {
  const SubjectItem({
    super.key,
    required this.subject,
    this.uiState,
    this.onTap,
  });

  /// 剧集数据
  final SubjectModel subject;

  /// UI 状态（未读数、静音、置顶）
  final SubjectUIState? uiState;

  /// 点击回调
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TapScale(
      onTap: onTap,
      scale: TapScales.card,
      child: Container(
        padding: SubjectItemLayout.padding,
        decoration: BoxDecoration(
          color: colors.surfaceBase,
          border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            _SubjectAvatar(subject: subject),
            const SizedBox(width: SubjectItemLayout.avatarSpacing),
            Expanded(
              child: _Content(subject: subject, colors: colors),
            ),
            const SizedBox(width: SubjectItemLayout.trailingSpacing),
            _Trailing(
              subject: subject,
              uiState: uiState ?? SubjectUIState(subjectId: subject.id),
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 私有子组件
// =============================================================================

/// 剧集头像
///
/// 使用 Hero 动画实现与详情页的共享元素过渡。
class _SubjectAvatar extends StatelessWidget {
  const _SubjectAvatar({required this.subject});

  final SubjectModel subject;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'subject_avatar_${subject.id}',
      // placeholderBuilder 保持 child 可见，避免动画结束时闪烁
      placeholderBuilder: (_, size, child) =>
          SizedBox(width: size.width, height: size.height, child: child),
      child: AvatarButton(
        imageUrl: subject.coverUrl,
        size: SubjectItemLayout.avatarSize,
        placeholder: subject.coverPlaceholder,
        enableTapScale: false,
      ),
    );
  }
}

/// 中间内容区
///
/// 显示剧集名称、订阅数和最后动态预览。
class _Content extends StatelessWidget {
  const _Content({required this.subject, required this.colors});

  final SubjectModel subject;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 第一行：剧集名 + 订阅数 + 徽章
        Row(
          children: [
            Flexible(
              child: Text(
                subject.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (subject.isOfficial)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                     color: colors.accent,
                     borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("OFFICIAL", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            if (subject.isVerified)
               Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.verified_rounded, size: 14, color: Colors.blueAccent),
              ),
            const SizedBox(width: 8),
            SubscriberBadge(count: subject.subscriberCount),
          ],
        ),
        const SizedBox(height: SubjectItemLayout.titleSpacing),
        // 第二行：最后动态预览
        _LastPost(subject: subject, colors: colors),
      ],
    );
  }
}

/// 最后动态预览
class _LastPost extends StatelessWidget {
  const _LastPost({required this.subject, required this.colors});

  final SubjectModel subject;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final lastPost = subject.lastPostPreview;
    final hasPost = lastPost != null && lastPost.isNotEmpty;

    return Text(
      hasPost ? lastPost : '暂无动态',
      style: TextStyle(
        fontSize: 14,
        color: hasPost ? colors.textSecondary : colors.textDisabled,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 右侧状态区
///
/// 显示时间、状态图标（置顶、静音）和未读徽章。
class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.subject,
    required this.uiState,
    required this.colors,
  });

  final SubjectModel subject;
  final SubjectUIState uiState;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isPinned = uiState.isPinned;
    final isMuted = uiState.isMuted;
    final unreadCount = uiState.unreadCount;
    final lastPostTime = subject.lastPostTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 第一行：状态图标 + 时间
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPinned)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.push_pin_rounded,
                  size: 13,
                  color: colors.textDisabled,
                ),
              ),
            if (isMuted)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.notifications_off_rounded,
                  size: 13,
                  color: colors.textDisabled,
                ),
              ),
            if (lastPostTime != null)
              TimeBadge(time: lastPostTime, size: TimeBadgeSize.medium),
          ],
        ),
        // 第二行：未读徽章（有未读时显示，无未读时不占位）
        if (unreadCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: UnreadBadge(count: unreadCount, isMuted: isMuted),
          ),
      ],
    );
  }
}
