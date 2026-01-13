// 深层链接 Mock 数据源
//
// 用于开发和测试的模拟数据源

import 'link_resolver.dart';

/// Mock 数据源实现
///
/// 提供模拟数据用于开发和测试
class LinkMockDataSource implements LinkResolverDataSource {
  // 模拟频道数据
  static final _channels = <String, ChannelInfo>{
    'channel_1': const ChannelInfo(
      id: 'channel_1',
      name: '科技前沿',
      description: '分享最新科技资讯和深度分析',
      subscriberCount: 12500,
      isSubscribed: true,
    ),
    'channel_2': const ChannelInfo(
      id: 'channel_2',
      name: '设计灵感',
      description: 'UI/UX 设计分享与讨论',
      subscriberCount: 8300,
      isSubscribed: false,
    ),
    'test': const ChannelInfo(
      id: 'test',
      name: '测试频道',
      description: '用于测试评论功能',
      subscriberCount: 1234,
      isSubscribed: true,
    ),
  };

  // 模拟消息数据
  static final _messages = <String, MessageInfo>{
    'msg_1': const MessageInfo(
      id: 'msg_1',
      channelId: 'channel_1',
      channelName: '科技前沿',
      content: 'Flutter 3.0 正式发布，带来了全新的渲染引擎和性能优化...',
      authorName: '科技前沿',
    ),
    'msg_2': const MessageInfo(
      id: 'msg_2',
      channelId: 'channel_2',
      channelName: '设计灵感',
      content: '今天分享一组优秀的 App 设计案例，希望能给大家带来灵感...',
      authorName: '设计灵感',
    ),
    'post_1': const MessageInfo(
      id: 'post_1',
      channelId: 'test',
      channelName: '测试频道',
      content: '这是一条测试帖子，点击下方评论区查看评论。',
      authorName: '频道主',
    ),
  };

  // 模拟评论数据（包含嵌套关系）
  // 格式：commentId -> (rootId, channelId, channelName, messageId, content, authorName)
  static final _comments = <String, CommentInfo>{
    // ========== 根评论 ==========
    'c1': const CommentInfo(
      id: 'c1',
      rootId: null,
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '这是第一条评论，有子回复',
      authorName: '用户A',
    ),
    'c2': const CommentInfo(
      id: 'c2',
      rootId: null,
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '感谢大家的支持！',
      authorName: '频道主',
    ),
    'c3': const CommentInfo(
      id: 'c3',
      rootId: null,
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '认证用户的评论',
      authorName: '用户B',
    ),

    // ========== 第二层回复（回复 c1）==========
    'c1_r1': const CommentInfo(
      id: 'c1_r1',
      rootId: 'c1',
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '谢谢支持！',
      authorName: '频道主',
    ),
    'c1_r2': const CommentInfo(
      id: 'c1_r2',
      rootId: 'c1',
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '频道主回复了！',
      authorName: '用户C',
    ),

    // ========== 第三层回复（回复 c1_r1，但根节点仍是 c1）==========
    'c1_r1_r1': const CommentInfo(
      id: 'c1_r1_r1',
      rootId: 'c1',
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '频道主太棒了！继续加油！',
      authorName: '用户A',
    ),
    'c1_r1_r2': const CommentInfo(
      id: 'c1_r1_r2',
      rootId: 'c1',
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '同感！',
      authorName: '用户D',
    ),
    'c1_r1_r3': const CommentInfo(
      id: 'c1_r1_r3',
      rootId: 'c1',
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '感谢大家的喜爱～',
      authorName: '频道主',
    ),

    // ========== 第四层回复 ==========
    'c1_r1_r1_r1': const CommentInfo(
      id: 'c1_r1_r1_r1',
      rootId: 'c1',
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '楼上说得对！',
      authorName: '用户E',
    ),
    'c1_r1_r1_r2': const CommentInfo(
      id: 'c1_r1_r1_r2',
      rootId: 'c1',
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '+1',
      authorName: '用户F',
    ),

    // ========== 第五层回复 ==========
    'c1_r1_r1_r1_r1': const CommentInfo(
      id: 'c1_r1_r1_r1_r1',
      rootId: 'c1',
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '哈哈谢谢支持！',
      authorName: '用户A',
    ),

    // ========== 用于 Link 跳转测试的特殊评论 ==========
    // 顶部评论（用于测试跳转到顶部）
    'top_comment': const CommentInfo(
      id: 'top_comment',
      rootId: null,
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '🔝 这是顶部评论，用于测试 Link 跳转到顶部功能',
      authorName: '系统测试',
    ),
    // 底部评论（用于测试跳转到底部）
    'bottom_comment': const CommentInfo(
      id: 'bottom_comment',
      rootId: null,
      channelId: 'test',
      channelName: '测试频道',
      messageId: 'post_1',
      content: '🔻 这是底部评论，用于测试 Link 跳转到底部功能',
      authorName: '系统测试',
    ),
  };

  // 模拟用户数据
  static final _users = <String, UserInfo>{
    'user_1': const UserInfo(
      id: 'user_1',
      username: 'tech_lover',
      displayName: '科技爱好者',
    ),
    'user_2': const UserInfo(
      id: 'user_2',
      username: 'designer_pro',
      displayName: '设计师小王',
    ),
  };

  @override
  Future<ChannelInfo?> getChannelInfo(String channelId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));
    return _channels[channelId];
  }

  @override
  Future<MessageInfo?> getMessageInfo(
    String channelId,
    String messageId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final msg = _messages[messageId];
    if (msg != null && msg.channelId == channelId) {
      return msg;
    }
    return null;
  }

  @override
  Future<CommentInfo?> getCommentInfo(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _comments[commentId];
  }

  @override
  Future<UserInfo?> getUserInfo(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _users[userId];
  }

  @override
  Future<PostInfo?> getPostInfo(String postId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // 暂无帖子数据
    return null;
  }

  @override
  Future<String?> getCommentRootId(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final comment = _comments[commentId];
    if (comment == null) return null;

    // 如果是根评论，返回自身 ID
    if (comment.isRoot) return comment.id;

    // 否则返回根评论 ID
    return comment.rootId;
  }

  /// 获取所有测试评论 ID 列表
  ///
  /// 用于 Link 跳转测试
  static List<String> get testCommentIds => _comments.keys.toList();

  /// 获取顶部测试评论 ID
  static String get topTestCommentId => 'top_comment';

  /// 获取底部测试评论 ID
  static String get bottomTestCommentId => 'bottom_comment';

  /// 获取测试频道 ID
  static String get testChannelId => 'test';

  /// 获取测试消息 ID
  static String get testMessageId => 'post_1';
}
