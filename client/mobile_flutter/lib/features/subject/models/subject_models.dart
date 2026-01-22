// =============================================================================
// 剧集模块数据模型统一导出
// =============================================================================
//
// 本文件作为剧集模块所有数据模型的统一入口，外部使用时只需导入此文件即可。
//
// ## 模型层级结构
//
// ```
// subject_models.dart (本文件 - 统一导出)
// ├── subject_model.dart        - 剧集核心模型 + UI 状态
// ├── subject_post_model.dart   - 剧集动态/剧评模型
// ├── subject_comment_model.dart - 剧集评论模型
// ├── subject_tag.dart          - 剧集标签模型
// └── reaction_model.dart       - 反应模型（重新导出公共模型）
// ```
//
// ## 使用示例
//
// ```dart
// import 'package:app/features/subject/models/subject_models.dart';
//
// final subject = SubjectModel(id: '1', name: '绝命毒师', ...);
// final post = SubjectPostModel(id: 'p1', content: '...', ...);
// ```

export 'subject_comment_model.dart';
export 'subject_model.dart';
export 'subject_post_model.dart';
export 'subject_tag.dart';
export 'reaction_model.dart';
