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

// UI 组件
export 'widgets/avatar.dart';
export 'widgets/button.dart';
export 'widgets/card.dart';
export 'widgets/chip.dart';
export 'widgets/expandable_text.dart';
export 'widgets/icon_container.dart';
export 'widgets/list_tile.dart';
