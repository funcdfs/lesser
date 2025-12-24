import 'package:flutter/material.dart';

/// 融合 Note.com 和 Shadcn 设计系统的主题配置
///
/// Note.com 风格特点：
/// - 更柔和的颜色和优雅的排版
/// - 精致的间距和圆角
/// - 优雅的字体层次
///
/// Shadcn 风格特点：
/// - 清晰的层次结构
/// - 系统化的设计令牌
/// - Zinc 色板作为基础

// ============================================================================
// 颜色系统 - 融合 Note.com 的柔和与 Shadcn 的系统化
// ============================================================================

/// 基础色板 - 基于 Zinc，但更柔和（Note.com 风格）
class AppColors {
  // Zinc 色板（Shadcn 基础）
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // 语义化颜色（融合两种风格）
  static const Color background = Colors.white; // 背景色
  static const Color foreground = Color(0xFF0A0A0A); // 更柔和的黑色（Note.com 风格）

  static const Color card = Colors.white; // 卡片背景色
  static const Color cardForeground = Color(0xFF0A0A0A);

  static const Color popover = Colors.white; // 弹出框背景色
  static const Color popoverForeground = Color(0xFF0A0A0A);

  // 主色调 - 融合 Note.com 的优雅和 Shadcn 的清晰
  static const Color primary = Color(0xFF18181B); // 深色主色（Note.com 风格）
  static const Color primaryForeground = zinc50;

  // 次要色调 - 更柔和的灰色（Note.com 风格）
  static const Color secondary = Color(0xFFF5F5F5); // 比 zinc100 更柔和
  static const Color secondaryForeground = Color(0xFF1A1A1A);

  // 减弱提示色 - Note.com 的优雅灰色
  static const Color muted = Color(0xFFF9F9F9);
  static const Color mutedForeground = Color(0xFF6B6B6B); // 比 zinc500 更柔和

  // 强调色
  static const Color accent = Color(0xFFF5F5F5);
  static const Color accentForeground = Color(0xFF1A1A1A);

  // 破坏性操作颜色
  static const Color destructive = Color(0xFFEF4444); // Red 500
  static const Color destructiveForeground = zinc50;

  // 边框和输入框
  static const Color border = Color(0xFFE5E5E5); // 比 zinc200 更柔和
  static const Color input = Color(0xFFE5E5E5);
  static const Color ring = Color(0xFF18181B); // 焦点环形颜色

  // 成功、警告、信息颜色（Note.com 风格）
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color warning = Color(0xFFEAB308); // Yellow 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // 强调色 - 优雅紫色系列 (Premium Accent)
  static const Color accentPurple = Color(0xFFC084FC); // Purple 400 - 柔和优雅的紫色
  static const Color accentPurpleLight = Color(
    0xFFF5F3FF,
  ); // Purple 50 - 极浅紫色背景
}

// ============================================================================
// 间距系统 - 基于 4px 网格，融合 Note.com 的精致
// ============================================================================

class AppSpacing {
  static const double xxs = 2.0; // 极小
  static const double xs = 4.0; // 很小
  static const double sm = 8.0; // 小
  static const double md = 12.0; // 中
  static const double lg = 16.0; // 大
  static const double xl = 20.0; // 很大
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
  static const double xl6 = 64.0;
}

// ============================================================================
// 圆角系统 - Note.com 的精致圆角
// ============================================================================

class AppRadius {
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 6.0; // Note.com 风格，比 Shadcn 更精致
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xl2 = 16.0;
  static const double xl3 = 20.0;
  static const double full = 9999.0; // 用于胶囊形状
}

// ============================================================================
// 阴影系统 - 融合两种风格的优雅阴影
// ============================================================================

class AppShadows {
  // 微弱阴影 - Note.com 风格
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  // 小阴影
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // 中等阴影 - Note.com 风格，更柔和
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // 大阴影
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // 超大阴影
  static List<BoxShadow> get xl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

// ============================================================================
// 主题数据 - 统一的主题配置
// ============================================================================

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        surface: AppColors.card,
        onSurface: AppColors.cardForeground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
        outline: AppColors.border,
      ),
      // 导航栏主题 - Note.com 风格的简洁
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        titleSpacing: AppSpacing.lg,
        titleTextStyle: const TextStyle(
          color: AppColors.foreground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3, // Note.com 风格的紧凑字距
          height: 1.2,
        ),
      ),
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.mutedForeground,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      // 卡片主题 - Note.com 风格的精致
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.ring, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      // 文本主题 - 融合 Note.com 的优雅排版和 Shadcn 的层次
      textTheme: const TextTheme(
        // H1 - 超大展示文字
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        // H2 - 大展示文字
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
          letterSpacing: -0.6,
          height: 1.25,
        ),
        // H3 - 中展示文字
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
          letterSpacing: -0.4,
          height: 1.3,
        ),
        // H4 - 标题文字
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
          letterSpacing: -0.2,
          height: 1.35,
        ),
        // H5 - 小标题
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
          letterSpacing: -0.1,
          height: 1.4,
        ),
        // 正文（大）
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.foreground,
          height: 1.6, // Note.com 风格的行高
          letterSpacing: 0,
        ),
        // 正文（中）
        bodyMedium: TextStyle(
          fontSize: 15,
          color: AppColors.foreground,
          height: 1.5,
          letterSpacing: 0,
        ),
        // 正文（小）
        bodySmall: TextStyle(
          fontSize: 14,
          color: AppColors.foreground,
          height: 1.5,
          letterSpacing: 0,
        ),
        // 标签文字（大）
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
          letterSpacing: 0,
        ),
        // 标签文字（中）
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedForeground,
          letterSpacing: 0,
        ),
        // 标签文字（小）
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedForeground,
          letterSpacing: 0,
        ),
      ),
      // 字体 - 使用系统字体（Note.com 风格）
      fontFamily: 'SF Pro Display',
    );
  }
}

// ============================================================================
// 向后兼容的别名（为了平滑迁移）
// ============================================================================

/// @deprecated 使用 AppColors 代替
@Deprecated('使用 AppColors 代替')
typedef ShadcnColors = AppColors;

/// @deprecated 使用 AppSpacing 代替
@Deprecated('使用 AppSpacing 代替')
typedef ShadcnSpacing = AppSpacing;

/// @deprecated 使用 AppRadius 代替
@Deprecated('使用 AppRadius 代替')
typedef ShadcnRadius = AppRadius;

/// @deprecated 使用 AppShadows 代替
@Deprecated('使用 AppShadows 代替')
typedef ShadcnShadows = AppShadows;

/// @deprecated 使用 AppTheme 代替
@Deprecated('使用 AppTheme 代替')
class ShadcnThemeData {
  static ThemeData get lightTheme => AppTheme.lightTheme;
}

// ============================================================================
// 主题常量集合 - 统一的主题常量定义
// ============================================================================

/// 通用主题常量集合
/// 避免硬编码颜色值，统一使用定义的常量
class ThemeConstants {
  // 文本颜色样式
  static const TextStyle primaryTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.foreground,
  );

  static const TextStyle secondaryTextStyle = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 14,
  );

  static const TextStyle captionTextStyle = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle smallCaptionTextStyle = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 15,
    color: AppColors.foreground,
    height: 1.4,
  );

  static const TextStyle expandButtonTextStyle = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  // 图标颜色
  static const Color iconColorDefault = AppColors.mutedForeground;
  static const Color iconColorActive = AppColors.foreground;
  static const Color iconColorLiked = AppColors.destructive;
  static const Color iconColorMuted = AppColors.mutedForeground;

  // 边框和分隔线
  static const Color separatorColor = AppColors.border;
  static const Color dividerColor = AppColors.border;

  // 卡片相关
  static const double cardElevation = 0.0;
  static const double cardBorderRadius = AppRadius.lg;
  static const Color cardShadowColor = Colors.transparent;

  // 圆角
  static const double borderRadiusSmall = AppRadius.sm;
  static const double borderRadiusMedium = AppRadius.md;
  static const double borderRadiusLarge = AppRadius.lg;

  // 动画
  static const Duration standardAnimationDuration = Duration(milliseconds: 200);
  static const Duration likeAnimationDuration = Duration(milliseconds: 600);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 300);

  // 间距
  static const double spacingXXSmall = AppSpacing.xxs;
  static const double spacingXSmall = AppSpacing.xs;
  static const double spacingSmall = AppSpacing.sm;
  static const double spacingMedium = AppSpacing.md;
  static const double spacingLarge = AppSpacing.lg;
  static const double spacingXLarge = AppSpacing.xl;
  static const double spacingXXLarge = AppSpacing.xl2;

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
  static const double inputBorderRadius = AppRadius.md;
  static const double inputHeight = 40.0;
  static const double inputPaddingHorizontal = AppSpacing.md;
  static const double inputPaddingVertical = AppSpacing.sm;

  // 阴影
  static List<BoxShadow> get subtleBoxShadow => AppShadows.subtle;
  static List<BoxShadow> get smallBoxShadow => AppShadows.sm;
  static List<BoxShadow> get mediumBoxShadow => AppShadows.md;
  static List<BoxShadow> get largeBoxShadow => AppShadows.lg;

  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, Color(0xFF3F3F46)],
  );

  // 开/关状态颜色
  static const Color enabledColor = AppColors.foreground;
  static const Color disabledColor = AppColors.mutedForeground;
  static const Color errorColor = AppColors.destructive;
  static const Color successColor = AppColors.success;
  static const Color warningColor = AppColors.warning;
  static const Color infoColor = AppColors.info;
}

/// 帖子相关的主题常量
class PostThemeConstants {
  // 帖子卡片
  static const double postCardPaddingVertical = AppSpacing.md;
  static const double postCardPaddingHorizontal = AppSpacing.lg;
  static const double postAvatarSize = 40.0;

  // 帖子内容
  static const double postContentFontSize = 15.0;
  static const double postContentLineHeight = 1.4;
  static const int postContentMaxLines = 3;

  // 帖子操作栏
  static const double postActionsBarSpacing = AppSpacing.lg;
  static const double postActionsBarSmallSpacing = AppSpacing.sm;

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
  static const Color postBackgroundColor = AppColors.background;
  static const Color postTextColor = AppColors.foreground;
  static const Color postMutedTextColor = AppColors.mutedForeground;
  static const Color postBorderColor = AppColors.border;
  static const Color postHandleColor = AppColors.zinc200;

  // 文本样式
  static const TextStyle postAuthorNameStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors.foreground,
  );

  static const TextStyle postAuthorHandleStyle = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 14,
  );

  static const TextStyle postTimestampStyle = TextStyle(
    color: AppColors.mutedForeground,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle postContentStyle = TextStyle(
    fontSize: 15,
    color: AppColors.foreground,
    height: 1.4,
  );
}

/// 操作按钮相关主题常量
class ActionButtonThemeConstants {
  static const double buttonSize = 32.0;
  static const double buttonIconSize = 18.0;
  static const double buttonPadding = AppSpacing.md;
  static const double buttonTextFontSize = 12.0;
  static const double buttonCountFontSize = 13.0;

  // 颜色
  static const Color likeButtonColor = AppColors.destructive;
  static const Color likeButtonHoverColor = Color(0xFFDC2626); // Red 600
  static const Color normalButtonColor = AppColors.mutedForeground;
  static const Color normalButtonHoverColor = AppColors.foreground;

  // 动画
  static const Duration likeAnimDuration = Duration(milliseconds: 200);
}
