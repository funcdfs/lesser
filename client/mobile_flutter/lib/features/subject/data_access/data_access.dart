// =============================================================================
// 数据访问层导出
// =============================================================================
//
// 统一导出数据访问层的接口、Mock实现和具体实现。
//
// 模块结构：
// ├── subject_data_source.dart      - 剧集数据源接口
// ├── subject_mock_data_source.dart - Mock 实现（开发用）
// ├── subject_comment_data_source.dart - 评论数据源
// └── mock/
//     └── subject_mock_data.dart    - Mock 数据定义
//
// 使用示例：
// import 'package:app/features/subject/data_access/data_access.dart';
//
// final dataSource = SubjectMockDataSource();
// final commentDataSource = SubjectCommentDataSource(subjectId: '1');

export 'subject_comment_data_source.dart';
export 'subject_data_source.dart';
export 'subject_mock_data_source.dart';
export 'mock/subject_mock_data.dart';
