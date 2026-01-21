// =============================================================================
// 数据访问层导出
// =============================================================================
//
// 统一导出数据访问层的接口、Mock实现和具体实现。
//
// 模块结构：
// ├── series_data_source.dart      - 剧集数据源接口
// ├── series_mock_data_source.dart - Mock 实现（开发用）
// ├── series_comment_data_source.dart - 评论数据源
// └── mock/
//     └── series_mock_data.dart    - Mock 数据定义
//
// 使用示例：
// import 'package:app/features/series/data_access/data_access.dart';
//
// final dataSource = SeriesMockDataSource();
// final commentDataSource = SeriesCommentDataSource(seriesId: '1');

export 'series_comment_data_source.dart';
export 'series_data_source.dart';
export 'series_mock_data_source.dart';
export 'mock/series_mock_data.dart';
