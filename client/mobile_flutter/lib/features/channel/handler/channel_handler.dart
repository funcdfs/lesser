// 频道业务逻辑层

import 'package:flutter/foundation.dart';
import '../models/channel_models.dart';

/// 频道 Handler（当前使用 mock 数据）
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

    _channels = List.from(_mockChannels)
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
      return _mockChannels.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 获取频道消息（按时间升序，最新在底部）
  Future<List<ChannelPostModel>> getMessages(String channelId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final messages = List<ChannelPostModel>.from(
      _mockMessages[channelId] ?? <ChannelPostModel>[],
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

// ============================================================================
// Mock 数据
// ============================================================================

final _mockChannels = <ChannelModel>[
  ChannelModel(
    id: '1',
    name: '妙妙屋主日记',
    ownerId: 'owner1',
    subscriberCount: 62633,
    lastMessage: '感觉TG又开始新一轮的大批量频道封禁了',
    lastMessageTime: DateTime(2025, 1, 7, 0, 15),
    unreadCount: 3,
    pinnedPost: ChannelPostModel(
      id: 'pinned1',
      channelId: '1',
      authorId: 'owner1',
      content: '请先查看这里！【妙妙屋主频道】',
      createdAt: DateTime(2025, 1, 1),
    ),
  ),
  ChannelModel(
    id: '2',
    name: '科技前沿',
    ownerId: 'owner2',
    subscriberCount: 128450,
    lastMessage: 'Apple Vision Pro 2 即将发布，新增多项功能',
    lastMessageTime: DateTime(2025, 1, 6, 18, 30),
    unreadCount: 12,
  ),
  ChannelModel(
    id: '3',
    name: '设计灵感',
    ownerId: 'owner3',
    subscriberCount: 45200,
    lastMessage: '2025 年 UI 设计趋势预测',
    lastMessageTime: DateTime(2025, 1, 6, 14, 20),
    unreadCount: 0,
  ),
  ChannelModel(
    id: '4',
    name: '开发者日报',
    ownerId: 'owner4',
    subscriberCount: 89100,
    lastMessage: 'Flutter 4.0 正式发布，性能提升 50%',
    lastMessageTime: DateTime(2025, 1, 5, 22, 45),
    unreadCount: 5,
    isMuted: true,
  ),
  ChannelModel(
    id: '5',
    name: '摄影分享',
    ownerId: 'owner5',
    subscriberCount: 33800,
    lastMessage: '冬日街拍技巧分享',
    lastMessageTime: DateTime(2025, 1, 5, 10, 0),
    unreadCount: 0,
  ),
];

// Mock 头像 URL
const _mockAvatars = [
  'https://i.pravatar.cc/100?img=1',
  'https://i.pravatar.cc/100?img=2',
  'https://i.pravatar.cc/100?img=3',
  'https://i.pravatar.cc/100?img=4',
  'https://i.pravatar.cc/100?img=5',
];

final _mockMessages = <String, List<ChannelPostModel>>{
  '1': [
    ChannelPostModel(
      id: 'm1',
      channelId: '1',
      authorId: 'owner1',
      content:
          'GG，接近30w订阅的老妙妙屋严选频道的辉煌还是落幕了，频道炸了哈，不是我把你们封禁了\n\n新频道：https://t.me/miaomiaowu3311\n\n重新启航，老资源会慢慢全部恢复到新频道里\n\n（甘霖凉机掰）',
      createdAt: DateTime(2025, 1, 5, 22, 35),
      viewCount: 10020,
      commentCount: 147,
      reactionStats: const PostReactionStats(
        postId: 'm1',
        counts: {'👍': 38, '🔥': 3},
        totalCount: 41,
      ),
      linkUrl: 'https://t.me/miaomiaowu3311',
      linkTitle: '新频道',
      commentAvatars: [
        _mockAvatars[0],
        _mockAvatars[1],
        _mockAvatars[2],
        _mockAvatars[3],
        _mockAvatars[4],
      ],
    ),
    ChannelPostModel(
      id: 'm2',
      channelId: '1',
      authorId: 'owner1',
      content: '上一条的评论区呢？',
      createdAt: DateTime(2025, 1, 5, 23, 48),
      viewCount: 8670,
      commentCount: 66,
      reactionStats: const PostReactionStats(
        postId: 'm2',
        counts: {'👍': 14, '❤️': 2},
        totalCount: 16,
      ),
      commentAvatars: [_mockAvatars[3], _mockAvatars[4], _mockAvatars[0]],
    ),
    ChannelPostModel(
      id: 'm3',
      channelId: '1',
      authorId: 'owner1',
      content:
          '妙妙屋讨论群已开放发言\n下午开始逐步恢复老资源进新频道\n【点击加入妙妙屋新频道】\n这可能需要一段略微漫长的时光\n就当作带大家重温下过去的记忆吧\n感谢各位陪伴\n\n我TM将在新频道组成头部！！！',
      createdAt: DateTime(2025, 1, 6, 13, 18),
      viewCount: 6309,
      commentCount: 24,
      reactionStats: const PostReactionStats(
        postId: 'm3',
        counts: {'👍': 21, '❤️': 4},
        totalCount: 25,
      ),
      commentAvatars: [
        _mockAvatars[1],
        _mockAvatars[2],
        _mockAvatars[4],
        _mockAvatars[0],
      ],
    ),
    ChannelPostModel(
      id: 'm4',
      channelId: '1',
      authorId: 'owner1',
      content: '最近会安排一台日本的真家庭宽带，ip无敌，有需要纯净ip的可以期待一下',
      createdAt: DateTime(2025, 1, 7, 0, 15),
      viewCount: 28108,
      commentCount: 10,
      reactionStats: const PostReactionStats(
        postId: 'm4',
        counts: {'❤️': 2},
        totalCount: 2,
      ),
      myReaction: '❤️', // 当前用户点过
      commentAvatars: [_mockAvatars[0], _mockAvatars[3]],
    ),
    ChannelPostModel(
      id: 'm5',
      channelId: '1',
      authorId: 'owner1',
      content: '感觉TG又开始新一轮的大批量频道封禁了',
      createdAt: DateTime(2025, 1, 7, 1, 30),
      viewCount: 737,
      commentCount: 2,
      reactionStats: const PostReactionStats(
        postId: 'm5',
        counts: {'😢': 22, '👎': 4, '😡': 2, '💔': 1},
        totalCount: 29,
      ),
      commentAvatars: [_mockAvatars[2]],
    ),
  ],
  '2': [
    ChannelPostModel(
      id: 'm6',
      channelId: '2',
      authorId: 'owner2',
      content: 'Apple Vision Pro 2 即将发布，新增多项功能，包括更轻的重量和更长的续航时间。',
      createdAt: DateTime(2025, 1, 6, 18, 30),
      viewCount: 15420,
      commentCount: 89,
      reactionStats: const PostReactionStats(
        postId: 'm6',
        counts: {'🍎': 156, '👍': 78, '🔥': 45},
        totalCount: 279,
      ),
      commentAvatars: [_mockAvatars[0], _mockAvatars[1], _mockAvatars[2]],
    ),
  ],
};
