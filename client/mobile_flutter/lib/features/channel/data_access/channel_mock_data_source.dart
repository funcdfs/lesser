// 频道 Mock 数据源

import '../handler/channel_handler.dart';
import '../models/channel_models.dart';
import '../handler/channel_mock_data.dart';

/// Mock 数据源
///
/// 实现 [ChannelDataSource] 接口，用于开发阶段测试。
class ChannelMockDataSource implements ChannelDataSource {
  @override
  Future<List<ChannelModel>> getChannels() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(mockChannels);
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
    await Future.delayed(const Duration(milliseconds: 50));
  }
}
