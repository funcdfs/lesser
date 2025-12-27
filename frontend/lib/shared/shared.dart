/// Shared 层的公共导出
///
/// 这个文件集中导出所有 shared 层的代码，使得其他 feature 可以方便地导入
///
/// 用法：
/// ```dart
/// import 'package:lesser/shared/shared.dart';
/// ```

library;

// 主题
export 'theme/theme.dart';

// 工具函数
export 'utils/logger_service.dart';
export 'utils/number_formatter.dart';
export 'utils/time_formatter.dart';
export 'utils/inner_drag_lock.dart';

// UI 组件 - TDesign 封装
export 'widgets/app_button.dart';
export 'widgets/app_cell.dart';
export 'widgets/app_dialog.dart';
export 'widgets/app_empty.dart';
export 'widgets/app_input.dart';
export 'widgets/app_loading.dart';
export 'widgets/app_toast.dart';
export 'widgets/app_nav_bar.dart';
export 'widgets/app_bottom_nav_bar.dart';
export 'widgets/app_avatar.dart';
export 'widgets/app_image.dart';

// UI 组件 - 自定义
export 'widgets/avatar.dart';
export 'widgets/chip.dart';
export 'widgets/expandable_text.dart';
export 'widgets/icon_container.dart';
export 'widgets/list_tile.dart';
export 'widgets/shimmer.dart';
export 'widgets/autocomplete.dart';
