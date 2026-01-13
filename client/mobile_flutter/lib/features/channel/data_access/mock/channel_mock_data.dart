// =============================================================================
// 频道 Mock 数据 - Channel Mock Data
// =============================================================================
//
// ## 设计目的
// 提供频道模块开发和测试所需的模拟数据，包括：
// - 标签数据（参考 note.com 分类）
// - 频道数据
// - 消息数据
// - 评论数据（基于闭包表的多叉树结构）
//
// ## 数据结构
// - mockChannelTags: 标签列表（44 个分类）
// - mockCurrentUser: 当前用户信息
// - mockChannels: 频道列表
// - mockChannelUIStates: 频道 UI 状态（未读数等）
// - mockMessages: 消息列表（按 channelId 分组）
// - mockCommentNodes: 评论节点（所有评论的扁平存储）
// - mockCommentClosure: 闭包表（祖先-后代关系）
//
// ## 闭包表设计
// 闭包表记录所有节点之间的祖先-后代关系：
// - ancestor_id: 祖先评论 ID
// - descendant_id: 后代评论 ID
// - depth: 层级深度（0 = 自身）
//
// 优势：
// - 查询某节点的所有子孙：WHERE ancestor_id = ?
// - 查询某节点的所有祖先：WHERE descendant_id = ?
// - 查询某节点的直接子节点：WHERE ancestor_id = ? AND depth = 1
//
// ## 使用说明
// 这些数据由 ChannelMockDataSource 使用，后续可替换为 gRPC 数据源。
//
// =============================================================================

import '../../models/channel_comment_model.dart';
import '../../models/channel_message_model.dart';
import '../../models/channel_model.dart';
import '../../models/channel_tag.dart';
import '../../models/reaction_model.dart';

// 重新导出 ReplyTarget 供外部使用
export '../../models/channel_comment_model.dart' show ReplyTarget;

// =============================================================================
// 标签数据
// =============================================================================

/// 频道标签列表
///
/// 参考 note.com 分类设计，涵盖娱乐、创作、技术、商业、生活等领域。
/// 每个标签包含 ID、名称和图标（emoji）。
const mockChannelTags = <ChannelTag>[
  // 娱乐
  ChannelTag(id: '1', name: 'エンタメ', icon: '🎬'),
  ChannelTag(id: '2', name: 'ゲーム', icon: '🎮'),
  ChannelTag(id: '3', name: 'マンガ', icon: '📚'),
  ChannelTag(id: '4', name: '音楽', icon: '🎵'),
  ChannelTag(id: '5', name: 'アニメ', icon: '🎌'),
  ChannelTag(id: '6', name: '映画', icon: '🎥'),
  // 创作
  ChannelTag(id: '7', name: 'コラム', icon: '✍️'),
  ChannelTag(id: '8', name: '小説', icon: '📝'),
  ChannelTag(id: '9', name: 'エッセイ', icon: '📄'),
  ChannelTag(id: '10', name: 'ポエム', icon: '🌸'),
  // 技术
  ChannelTag(id: '11', name: 'テクノロジー', icon: '💻'),
  ChannelTag(id: '12', name: 'プログラミング', icon: '⌨️'),
  ChannelTag(id: '13', name: 'AI', icon: '🤖'),
  ChannelTag(id: '14', name: 'Web3', icon: '🔗'),
  // 商业
  ChannelTag(id: '15', name: 'ビジネス', icon: '💼'),
  ChannelTag(id: '16', name: 'マーケティング', icon: '📊'),
  ChannelTag(id: '17', name: '起業', icon: '🚀'),
  ChannelTag(id: '18', name: '投資', icon: '📈'),
  // 生活
  ChannelTag(id: '19', name: 'ライフスタイル', icon: '🌿'),
  ChannelTag(id: '20', name: 'フード', icon: '🍜'),
  ChannelTag(id: '21', name: '料理', icon: '🍳'),
  ChannelTag(id: '22', name: 'カフェ', icon: '☕'),
  ChannelTag(id: '23', name: 'トラベル', icon: '✈️'),
  ChannelTag(id: '24', name: '海外生活', icon: '🌍'),
  // 运动健康
  ChannelTag(id: '25', name: 'スポーツ', icon: '⚽'),
  ChannelTag(id: '26', name: 'フィットネス', icon: '💪'),
  ChannelTag(id: '27', name: 'ランニング', icon: '🏃'),
  ChannelTag(id: '28', name: 'ヨガ', icon: '🧘'),
  // 时尚美容
  ChannelTag(id: '29', name: 'ファッション', icon: '👗'),
  ChannelTag(id: '30', name: 'コスメ', icon: '💄'),
  ChannelTag(id: '31', name: 'ネイル', icon: '💅'),
  // 艺术设计
  ChannelTag(id: '32', name: 'アート', icon: '🎨'),
  ChannelTag(id: '33', name: '写真', icon: '📷'),
  ChannelTag(id: '34', name: 'デザイン', icon: '✨'),
  ChannelTag(id: '35', name: 'イラスト', icon: '🖼️'),
  // 学习
  ChannelTag(id: '36', name: '教育', icon: '📖'),
  ChannelTag(id: '37', name: '語学', icon: '🗣️'),
  ChannelTag(id: '38', name: '資格', icon: '📜'),
  // 其他
  ChannelTag(id: '39', name: 'ペット', icon: '🐱'),
  ChannelTag(id: '40', name: 'DIY', icon: '🔧'),
  ChannelTag(id: '41', name: '子育て', icon: '👶'),
  ChannelTag(id: '42', name: '恋愛', icon: '💕'),
  ChannelTag(id: '43', name: '占い', icon: '🔮'),
  ChannelTag(id: '44', name: 'メンタル', icon: '🧠'),
];

// =============================================================================
// 当前用户
// =============================================================================

/// 当前用户 ID（用于判断评论所有权、点赞状态等）
const mockCurrentUserId = 'current_user';

/// 当前用户信息
///
/// 用于评论发布时的作者信息。
/// 生产环境应从认证服务获取。
const mockCurrentUser = CommentAuthor(
  id: mockCurrentUserId,
  username: 'me',
  displayName: '我',
  avatarUrl: 'https://i.pravatar.cc/100?img=20',
);

// =============================================================================
// 频道数据
// =============================================================================

/// 频道列表
final mockChannels = <ChannelModel>[
  ChannelModel(
    id: 'test',
    name: 'test_channel',
    displayName: '测试频道',
    description: '用于测试评论功能',
    ownerId: 'owner',
    subscriberCount: 1234,
    messageCount: 1,
    lastMessagePreview: '这是一条测试消息',
    lastMessageTime: DateTime(2025, 1, 8, 10, 0),
    avatarUrl: 'https://i.pravatar.cc/100?img=1',
    isSubscribed: true,
    link: 'https://lesser.app/c/test_channel',
  ),
];

/// 频道 UI 状态
final mockChannelUIStates = <String, ChannelUIState>{
  'test': const ChannelUIState(channelId: 'test', unreadCount: 1),
};

// =============================================================================
// 消息数据
// =============================================================================

/// 频道消息（按 channelId 分组）
final mockMessages = <String, List<ChannelMessageModel>>{
  'test': [
    ChannelMessageModel(
      id: 'post_1',
      channelId: 'test',
      authorId: 'owner',
      authorName: '频道主',
      content: '这是一条测试帖子，点击下方评论区查看评论。',
      createdAt: DateTime(2025, 1, 8, 10, 0),
      viewCount: 100,
      commentCount: 15,
      reactionStats: const ReactionStats(
        counts: {'👍': 10, '❤️': 5},
        totalCount: 15,
      ),
      commentAvatars: const [
        'https://i.pravatar.cc/100?img=2',
        'https://i.pravatar.cc/100?img=3',
      ],
    ),
  ],
};

// =============================================================================
// 评论数据 - 基于闭包表的多叉树结构
// =============================================================================

/// 评论作者预定义
const _authors = <String, CommentAuthor>{
  'owner': CommentAuthor(
    id: 'owner',
    username: 'owner',
    displayName: '频道主',
    avatarUrl: 'https://i.pravatar.cc/100?img=1',
    isChannelOwner: true,
  ),
  'u1': CommentAuthor(
    id: 'u1',
    username: 'user1',
    displayName: '用户A',
    avatarUrl: 'https://i.pravatar.cc/100?img=2',
  ),
  'u2': CommentAuthor(
    id: 'u2',
    username: 'user2',
    displayName: '用户B',
    avatarUrl: 'https://i.pravatar.cc/100?img=3',
    isVerified: true,
  ),
  'u3': CommentAuthor(
    id: 'u3',
    username: 'user3',
    displayName: '用户C',
    avatarUrl: 'https://i.pravatar.cc/100?img=4',
  ),
  'u4': CommentAuthor(
    id: 'u4',
    username: 'user4',
    displayName: '用户D',
    avatarUrl: 'https://i.pravatar.cc/100?img=5',
  ),
  'u5': CommentAuthor(
    id: 'u5',
    username: 'user5',
    displayName: '用户E',
    avatarUrl: 'https://i.pravatar.cc/100?img=6',
  ),
  'u6': CommentAuthor(
    id: 'u6',
    username: 'user6',
    displayName: '用户F',
    avatarUrl: 'https://i.pravatar.cc/100?img=7',
  ),
};

/// 获取作者（带默认值）
CommentAuthor _getAuthor(String id) => _authors[id] ?? CommentAuthor.deleted;

// =============================================================================
// 评论数据 - 根评论和子评论
// =============================================================================

/// 根评论（按 messageId 分组）
///
/// 存储每条消息下的根评论列表。
final mockComments = <String, List<ChannelCommentModel>>{
  'post_1': [
    ChannelCommentModel(
      id: 'c1',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('u1'),
      content: '这是第一条评论，有子回复',
      createdAtMs: DateTime(2025, 1, 8, 10, 5).millisecondsSinceEpoch,
      replyCount: 5,
    ),
    ChannelCommentModel(
      id: 'c2',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('owner'),
      content: '感谢大家的支持！',
      createdAtMs: DateTime(2025, 1, 8, 10, 10).millisecondsSinceEpoch,
      isPinned: true,
    ),
    ChannelCommentModel(
      id: 'c3',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('u2'),
      content: '认证用户的评论',
      createdAtMs: DateTime(2025, 1, 8, 10, 15).millisecondsSinceEpoch,
    ),
  ],
};

/// 子评论（按 parentId 分组）
///
/// 存储每条评论下的直接子评论列表。
/// 支持多层嵌套：c1 -> c1_r1 -> c1_r1_r1 -> ...
final mockReplies = <String, List<ChannelCommentModel>>{
  // c1 的直接回复
  'c1': [
    ChannelCommentModel(
      id: 'c1_r1',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('owner'),
      content: '谢谢支持！',
      createdAtMs: DateTime(2025, 1, 8, 10, 20).millisecondsSinceEpoch,
      replyTo: const ReplyTarget(
        commentId: 'c1',
        authorName: '用户A',
        contentPreview: '这是第一条评论，有子回复',
      ),
      replyCount: 3,
    ),
    ChannelCommentModel(
      id: 'c1_r2',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('u3'),
      content: '频道主回复了！',
      createdAtMs: DateTime(2025, 1, 8, 10, 25).millisecondsSinceEpoch,
      replyTo: const ReplyTarget(
        commentId: 'c1',
        authorName: '用户A',
        contentPreview: '这是第一条评论，有子回复',
      ),
    ),
  ],
  // c1_r1 的回复（第三层）
  'c1_r1': [
    ChannelCommentModel(
      id: 'c1_r1_r1',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('u1'),
      content: '频道主太棒了！继续加油！',
      createdAtMs: DateTime(2025, 1, 8, 10, 30).millisecondsSinceEpoch,
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '频道主',
        contentPreview: '谢谢支持！',
      ),
      replyCount: 2,
    ),
    ChannelCommentModel(
      id: 'c1_r1_r2',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('u4'),
      content: '同感！',
      createdAtMs: DateTime(2025, 1, 8, 10, 35).millisecondsSinceEpoch,
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '频道主',
        contentPreview: '谢谢支持！',
      ),
    ),
    ChannelCommentModel(
      id: 'c1_r1_r3',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('owner'),
      content: '感谢大家的喜爱～',
      createdAtMs: DateTime(2025, 1, 8, 10, 40).millisecondsSinceEpoch,
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '频道主',
        contentPreview: '谢谢支持！',
      ),
    ),
  ],
  // c1_r1_r1 的回复（第四层）
  'c1_r1_r1': [
    ChannelCommentModel(
      id: 'c1_r1_r1_r1',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('u5'),
      content: '楼上说得对！',
      createdAtMs: DateTime(2025, 1, 8, 10, 45).millisecondsSinceEpoch,
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1',
        authorName: '用户A',
        contentPreview: '频道主太棒了！继续加油！',
      ),
      replyCount: 1,
    ),
    ChannelCommentModel(
      id: 'c1_r1_r1_r2',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('u6'),
      content: '+1',
      createdAtMs: DateTime(2025, 1, 8, 10, 50).millisecondsSinceEpoch,
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1',
        authorName: '用户A',
        contentPreview: '频道主太棒了！继续加油！',
      ),
    ),
  ],
  // c1_r1_r1_r1 的回复（第五层）
  'c1_r1_r1_r1': [
    ChannelCommentModel(
      id: 'c1_r1_r1_r1_r1',
      messageId: 'post_1',
      channelId: 'test',
      author: _getAuthor('u1'),
      content: '哈哈谢谢支持！',
      createdAtMs: DateTime(2025, 1, 8, 10, 55).millisecondsSinceEpoch,
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1_r1',
        authorName: '用户E',
        contentPreview: '楼上说得对！',
      ),
    ),
  ],
};
