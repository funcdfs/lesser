// 频道业务逻辑层

import 'package:flutter/foundation.dart';
import '../models/channel_models.dart';

/// 频道数据源接口
///
/// 抽象数据获取逻辑，便于切换 Mock/gRPC 实现
abstract class ChannelDataSource {
  /// 获取频道列表
  Future<List<ChannelModel>> getChannels();

  /// 获取频道详情
  Future<ChannelModel?> getChannelDetail(String id);

  /// 获取频道消息
  Future<List<ChannelMessageModel>> getMessages(String channelId);

  /// 切换静音状态
  Future<void> toggleMute(String channelId, bool muted);
}

/// 频道 Handler
class ChannelHandler extends ChangeNotifier {
  ChannelHandler(this._dataSource);

  final ChannelDataSource _dataSource;

  List<ChannelModel> _channels = [];
  bool _isLoading = false;
  String? _error;

  List<ChannelModel> get channels => _channels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取频道列表（按最后消息时间降序排序）
  Future<List<ChannelModel>> getChannels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final list = await _dataSource.getChannels();
      _channels = List.from(list)
        ..sort((a, b) {
          final aTime = a.lastMessageTime ?? DateTime(1970);
          final bTime = b.lastMessageTime ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _channels;
  }

  /// 获取频道详情
  Future<ChannelModel?> getChannelDetail(String id) async {
    return _dataSource.getChannelDetail(id);
  }

  /// 获取频道消息（按时间升序，最新在底部）
  Future<List<ChannelMessageModel>> getMessages(String channelId) async {
    final messages = await _dataSource.getMessages(channelId);
    return List.from(messages)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// 切换静音状态（乐观更新）
  Future<void> toggleMute(String channelId) async {
    final index = _channels.indexWhere((c) => c.id == channelId);
    if (index == -1) return;

    final original = _channels[index];
    final newMuted = !original.isMuted;

    // 乐观更新
    _channels[index] = original.copyWith(isMuted: newMuted);
    notifyListeners();

    try {
      await _dataSource.toggleMute(channelId, newMuted);
    } catch (e) {
      // 回滚
      _channels[index] = original;
      notifyListeners();
      rethrow;
    }
  }

  /// 刷新频道列表
  Future<void> refresh() async {
    await getChannels();
  }
}
