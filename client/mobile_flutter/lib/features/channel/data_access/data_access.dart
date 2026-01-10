// =============================================================================
// 频道数据访问层统一导出
// =============================================================================
//
// 本文件作为频道数据访问层的统一入口。
//
// ## 数据访问层架构
//
// ```
// data_access.dart (本文件 - 统一导出)
// ├── channel_data_source.dart      - 频道数据源接口
// ├── channel_mock_data_source.dart - Mock 实现（开发用）
// ├── channel_comment_data_source.dart - 评论数据源
// └── mock/
//     └── channel_mock_data.dart    - Mock 数据定义
// ```
//
// ## 使用示例
//
// ```dart
// import 'package:app/features/channel/data_access/data_access.dart';
//
// // 开发阶段使用 Mock 数据源
// final dataSource = ChannelMockDataSource();
//
// // 生产环境替换为 gRPC 数据源
// // final dataSource = ChannelGrpcDataSource(channel);
// ```

export 'channel_comment_data_source.dart';
export 'channel_data_source.dart';
export 'channel_mock_data_source.dart';
export 'mock/channel_mock_data.dart';
