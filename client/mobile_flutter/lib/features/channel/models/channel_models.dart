// =============================================================================
// 频道模块数据模型统一导出
// =============================================================================
//
// 本文件作为频道模块所有数据模型的统一入口，外部使用时只需导入此文件即可。
//
// ## 模型层级结构
//
// ```
// channel_models.dart (本文件 - 统一导出)
// ├── channel_model.dart        - 频道核心模型 + UI 状态
// ├── channel_message_model.dart - 频道消息模型
// ├── channel_comment_model.dart - 频道评论模型
// ├── channel_tag.dart          - 频道标签模型
// └── reaction_model.dart       - 反应模型（重新导出公共模型）
// ```
//
// ## 使用示例
//
// ```dart
// import 'package:app/features/channel/models/channel_models.dart';
//
// final channel = ChannelModel(id: '1', name: '技术频道', ...);
// final message = ChannelMessageModel(id: 'm1', content: '...', ...);
// ```

export 'channel_comment_model.dart';
export 'channel_model.dart';
export 'channel_message_model.dart';
export 'channel_tag.dart';
export 'reaction_model.dart';
