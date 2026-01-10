// =============================================================================
// 频道数据源接口
// =============================================================================
//
// 定义频道数据获取的抽象接口，支持多种实现（Mock、gRPC 等）。
//
// ## 设计目的
//
// 1. **依赖倒置**：Handler 层依赖抽象接口而非具体实现
// 2. **易于测试**：可以注入 Mock 实现进行单元测试
// 3. **平滑切换**：开发阶段使用 Mock，生产环境切换到 gRPC
//
// ## 实现类
//
// - `ChannelMockDataSource` - Mock 实现，用于开发和测试
// - `ChannelGrpcDataSource` - gRPC 实现，用于生产环境（待实现）

import '../models/channel_models.dart';

/// 频道数据源接口
///
/// 抽象频道相关的数据获取逻辑，便于切换不同的数据源实现。
abstract class ChannelDataSource {
  /// 获取频道列表
  ///
  /// 返回当前用户订阅的所有频道。
  Future<List<ChannelModel>> getChannels();

  /// 获取频道详情
  ///
  /// 根据频道 ID 获取完整的频道信息，包括置顶消息等。
  /// 如果频道不存在，返回 null。
  Future<ChannelModel?> getChannelDetail(String id);

  /// 获取频道消息列表
  ///
  /// 返回指定频道的消息列表，按时间升序排列（最新在底部）。
  Future<List<ChannelMessageModel>> getMessages(String channelId);

  /// 切换静音状态
  ///
  /// 静音后不会收到该频道的推送通知，但仍会计算未读数。
  Future<void> toggleMute(String channelId, bool muted);

  /// 切换置顶状态
  ///
  /// 置顶的频道会在列表顶部显示。
  Future<void> togglePin(String channelId, bool pinned);
}
