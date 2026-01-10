// =============================================================================
// 频道 Mock 数据源
// =============================================================================
//
// 实现 [ChannelDataSource] 接口的 Mock 版本，用于开发阶段测试。
//
// ## 使用场景
//
// - 开发阶段：无需后端服务即可进行 UI 开发
// - 单元测试：提供可预测的测试数据
// - 演示环境：展示应用功能
//
// ## 模拟行为
//
// - 所有方法都有模拟网络延迟（50-100ms）
// - 数据来自 `mock/channel_mock_data.dart`
// - 写操作（toggleMute、togglePin）只模拟延迟，不实际修改数据

import '../models/channel_models.dart';
import 'channel_data_source.dart';
import 'mock/channel_mock_data.dart';

/// Mock 数据源实现
///
/// 实现 [ChannelDataSource] 接口，提供模拟数据用于开发测试。
class ChannelMockDataSource implements ChannelDataSource {
  @override
  Future<List<ChannelModel>> getChannels() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(mockChannels);
  }

  @override
  Future<Map<String, ChannelUIState>> getUIStates() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 50));
    return Map.from(mockChannelUIStates);
  }

  @override
  Future<ChannelModel?> getChannelDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    for (final channel in mockChannels) {
      if (channel.id == id) return channel;
    }
    return null;
  }

  @override
  Future<List<ChannelMessageModel>> getMessages(String channelId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final messages = mockMessages[channelId];
    return messages != null ? List.from(messages) : [];
  }

  @override
  Future<void> toggleMute(String channelId, bool muted) async {
    // 模拟网络延迟，实际不修改数据
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> togglePin(String channelId, bool pinned) async {
    // 模拟网络延迟，实际不修改数据
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
