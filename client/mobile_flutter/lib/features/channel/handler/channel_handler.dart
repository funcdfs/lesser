// 频道业务逻辑层

import 'package:flutter/foundation.dart';
import '../models/channel_models.dart';
import 'channel_mock_data.dart' show mockChannels, mockMessages;

/// 频道 Handler
///
/// 当前使用 mock 数据，之后可替换为 gRPC 数据源
class ChannelHandler extends ChangeNotifier {
  List<ChannelModel> _channels = [];
  bool _isLoading = false;

  List<ChannelModel> get channels => _channels;
  bool get isLoading => _isLoading;

  /// 获取频道列表（按最后消息时间降序排序）
  Future<List<ChannelModel>> getChannels() async {
    _isLoading = true;
    notifyListeners();

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    _channels = List.from(mockChannels)
      ..sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime(1970);
        final bTime = b.lastMessageTime ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

    _isLoading = false;
    notifyListeners();
    return _channels;
  }

  /// 获取频道详情
  ChannelModel? getChannelDetail(String id) {
    try {
      return mockChannels.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 获取频道消息（按时间升序，最新在底部）
  Future<List<ChannelPostModel>> getMessages(String channelId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final messages = List<ChannelPostModel>.from(
      mockMessages[channelId] ?? <ChannelPostModel>[],
    );
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  /// 切换静音状态
  void toggleMute(String channelId) {
    final index = _channels.indexWhere((c) => c.id == channelId);
    if (index != -1) {
      _channels[index] = _channels[index].copyWith(
        isMuted: !_channels[index].isMuted,
      );
      notifyListeners();
    }
  }

  /// 刷新频道列表
  Future<void> refresh() async {
    await getChannels();
  }
}
