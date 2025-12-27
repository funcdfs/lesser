// 导出新的颜色和间距系统
export 'colors.dart';
export 'spacing.dart';

/// 主题系统入口文件
///
/// 此文件作为主题系统的统一入口，导出所有设计令牌：
/// - AppColors: 黑色基调的颜色系统 (colors.dart)
/// - AppSpacing: 基于 4px 网格的间距系统 (spacing.dart)
/// - AppRadius: 圆角系统 (spacing.dart)
/// - AppShadows: 阴影系统 (spacing.dart)
///
/// 使用方式：
/// ```dart
/// import 'package:your_app/shared/theme/theme.dart';
///
/// // 使用颜色
/// Container(color: AppColors.background)
///
/// // 使用间距
/// Padding(padding: EdgeInsets.all(AppSpacing.md))
///
/// // 使用圆角
/// BorderRadius.circular(AppRadius.lg)
///
/// // 使用阴影
/// BoxDecoration(boxShadow: AppShadows.md)
/// ```
///
/// 主题配置请使用 app_theme.dart 中的 AppTheme 类。
