// 频道 Mock 数据源
//
// 实现 ChannelDataSource 接口，用于开发阶段

import '../handler/channel_handler.dart';
import '../models/channel_models.dart';
import '../handler/channel_mock_data.dart';

/// Mock 数据源实现
class ChannelMockDataSource implements ChannelDataSource {
  @override
  Future<List<ChannelModel>> getChannels() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(mockChannels);
  }

  @override
  Future<ChannelModel?> getChannelDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return mockChannels.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ChannelMessageModel>> getMessages(String channelId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(mockMessages[channelId] ?? <ChannelMessageModel>[]);
  }

  @override
  Future<void> toggleMute(String channelId, bool muted) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock: 直接成功
  }
}
