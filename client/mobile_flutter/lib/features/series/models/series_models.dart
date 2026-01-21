// =============================================================================
// 剧集模块数据模型统一导出
// =============================================================================
//
// 本文件作为剧集模块所有数据模型的统一入口，外部使用时只需导入此文件即可。
//
// ## 模型层级结构
//
// ```
// series_models.dart (本文件 - 统一导出)
// ├── series_model.dart        - 剧集核心模型 + UI 状态
// ├── series_post_model.dart   - 剧集动态/剧评模型
// ├── series_comment_model.dart - 剧集评论模型
// ├── series_tag.dart          - 剧集标签模型
// └── reaction_model.dart       - 反应模型（重新导出公共模型）
// ```
//
// ## 使用示例
//
// ```dart
// import 'package:app/features/series/models/series_models.dart';
//
// final series = SeriesModel(id: '1', name: '绝命毒师', ...);
// final post = SeriesPostModel(id: 'p1', content: '...', ...);
// ```

export 'series_comment_model.dart';
export 'series_model.dart';
export 'series_post_model.dart';
export 'series_tag.dart';
export 'reaction_model.dart';
