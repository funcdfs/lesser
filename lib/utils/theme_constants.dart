import 'package:flutter/material.dart';
import '../config/shadcn_theme.dart';

/// Shadcn 设计系统主题常量集合
/// 避免硬编码颜色值，统一使用定义的常量
class ThemeConstants {
  // 文本颜色样式
  static const TextStyle primaryTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: ShadcnColors.foreground,
  );

  static const TextStyle secondaryTextStyle = TextStyle(
    color: ShadcnColors.mutedForeground,
    fontSize: 14,
  );

  static const TextStyle captionTextStyle = TextStyle(
    color: ShadcnColors.mutedForeground,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle smallCaptionTextStyle = TextStyle(
    color: ShadcnColors.mutedForeground,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 15,
    color: ShadcnColors.foreground,
    height: 1.4,
  );

  static const TextStyle expandButtonTextStyle = TextStyle(
    color: ShadcnColors.primary,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  // 图标颜色
  static const Color iconColorDefault = ShadcnColors.mutedForeground;
  static const Color iconColorActive = ShadcnColors.foreground;
  static const Color iconColorLiked = ShadcnColors.destructive;
  static const Color iconColorMuted = ShadcnColors.mutedForeground;

  // 边框和分隔线
  static const Color separatorColor = ShadcnColors.border;
  static const Color dividerColor = ShadcnColors.border;

  // 卡片相关
  static const double cardElevation = 0.0;
  static const double cardBorderRadius = ShadcnRadius.lg;
  static const Color cardShadowColor = Colors.transparent;

  // 圆角
  static const double borderRadiusSmall = ShadcnRadius.sm;
  static const double borderRadiusMedium = ShadcnRadius.md;
  static const double borderRadiusLarge = ShadcnRadius.lg;

  // 动画
  static const Duration standardAnimationDuration = Duration(milliseconds: 200);
  static const Duration likeAnimationDuration = Duration(milliseconds: 600);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 300);

  // 间距
  static const double spacingXXSmall = ShadcnSpacing.xxs;
  static const double spacingXSmall = ShadcnSpacing.xs;
  static const double spacingSmall = ShadcnSpacing.sm;
  static const double spacingMedium = ShadcnSpacing.md;
  static const double spacingLarge = ShadcnSpacing.lg;
  static const double spacingXLarge = ShadcnSpacing.xl;
  static const double spacingXXLarge = ShadcnSpacing.xl2;

  // 按钮相关
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;

  // 头像相关
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 48.0;

  // 图标大小
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeExtraLarge = 32.0;

  // 列表和网格
  static const double listItemHeight = 60.0;
  static const double gridSpacing = 8.0;

  // 输入框相关
  static const double inputBorderRadius = ShadcnRadius.md;
  static const double inputHeight = 40.0;
  static const double inputPaddingHorizontal = ShadcnSpacing.md;
  static const double inputPaddingVertical = ShadcnSpacing.sm;

  // 阴影
  static List<BoxShadow> get subtleBoxShadow => ShadcnShadows.subtle;
  static List<BoxShadow> get smallBoxShadow => ShadcnShadows.sm;
  static List<BoxShadow> get mediumBoxShadow => ShadcnShadows.md;
  static List<BoxShadow> get largeBoxShadow => ShadcnShadows.lg;

  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [ShadcnColors.primary, Color(0xFF3F3F46)],
  );

  // 开/关状态颜色
  static const Color enabledColor = ShadcnColors.foreground;
  static const Color disabledColor = ShadcnColors.mutedForeground;
  static const Color errorColor = ShadcnColors.destructive;
  static const Color successColor = Color(0xFF22C55E); // Green 500
  static const Color warningColor = Color(0xFFEAB308); // Yellow 500
  static const Color infoColor = ShadcnColors.primary;
}

/// 帖子相关的主题常量
class PostThemeConstants {
  // 帖子卡片
  static const double postCardPaddingVertical = ShadcnSpacing.md;
  static const double postCardPaddingHorizontal = ShadcnSpacing.lg;
  static const double postAvatarSize = 40.0;

  // 帖子内容
  static const double postContentFontSize = 15.0;
  static const double postContentLineHeight = 1.4;
  static const int postContentMaxLines = 3;

  // 帖子操作栏
  static const double postActionsBarSpacing = ShadcnSpacing.lg;
  static const double postActionsBarSmallSpacing = ShadcnSpacing.sm;

  // 帖子图片
  static const double postImageBorderRadius = 12.0;
  static const double postImageHeight = 300.0;
  static const double postImageCarouselItemWidth = 250.0;
  static const double postImageCarouselSpacing = 8.0;
  static const int postMaxImages = 50;

  // 动画时长
  static const Duration postLikeAnimDuration = Duration(milliseconds: 600);
  static const Duration postLoadingDuration = Duration(milliseconds: 300);

  // 颜色
  static const Color postBackgroundColor = ShadcnColors.background;
  static const Color postTextColor = ShadcnColors.foreground;
  static const Color postMutedTextColor = ShadcnColors.mutedForeground;
  static const Color postBorderColor = ShadcnColors.border;

  // 文本样式
  static const TextStyle postAuthorNameStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: ShadcnColors.foreground,
  );

  static const TextStyle postAuthorHandleStyle = TextStyle(
    color: ShadcnColors.mutedForeground,
    fontSize: 14,
  );

  static const TextStyle postTimestampStyle = TextStyle(
    color: ShadcnColors.mutedForeground,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle postContentStyle = TextStyle(
    fontSize: 15,
    color: ShadcnColors.foreground,
    height: 1.4,
  );
}

/// 操作按钮相关主题常量
class ActionButtonThemeConstants {
  static const double buttonSize = 32.0;
  static const double buttonIconSize = 18.0;
  static const double buttonPadding = ShadcnSpacing.md;
  static const double buttonTextFontSize = 12.0;
  static const double buttonCountFontSize = 13.0;

  // 颜色
  static const Color likeButtonColor = ShadcnColors.destructive;
  static const Color likeButtonHoverColor = Color(0xFFDC2626); // Red 600
  static const Color normalButtonColor = ShadcnColors.mutedForeground;
  static const Color normalButtonHoverColor = ShadcnColors.foreground;

  // 动画
  static const Duration likeAnimDuration = Duration(milliseconds: 200);
}
