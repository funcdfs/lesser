// 频道 Mock 数据

import '../models/channel_comment_model.dart';
import '../models/channel_message_model.dart';
import '../models/channel_model.dart';
import '../models/channel_tag.dart';
import '../models/reaction_model.dart';

// ============================================================================
// 标签
// ============================================================================

/// 频道标签列表（参考 note.com 分类）
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

// ============================================================================
// 当前用户
// ============================================================================

const mockCurrentUserId = 'current_user';

/// 当前用户信息
const mockCurrentUser = CommentAuthor(
  id: mockCurrentUserId,
  username: 'me',
  displayName: '我',
  avatarUrl: 'https://i.pravatar.cc/100?img=20',
);

// ============================================================================
// 频道
// ============================================================================

/// 频道列表
final mockChannels = <ChannelModel>[
  ChannelModel(
    id: 'test',
    name: '测试频道',
    description: '用于测试评论功能',
    ownerId: 'owner',
    subscriberCount: 1234,
    messageCount: 1,
    lastMessage: '这是一条测试消息',
    lastMessageTime: DateTime(2025, 1, 8, 10, 0),
    unreadCount: 1,
    avatarUrl: 'https://i.pravatar.cc/100?img=1',
    isSubscribed: true,
  ),
];

// ============================================================================
// 消息
// ============================================================================

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
      commentCount: 21,
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

// ============================================================================
// 评论
// ============================================================================

/// 根评论（按 messageId 分组）
final mockComments = <String, List<ChannelCommentModel>>{
  'post_1': [
    // 频道主置顶评论
    ChannelCommentModel(
      id: 'c_pinned',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'owner',
        username: 'owner',
        displayName: '频道主',
        avatarUrl: 'https://i.pravatar.cc/100?img=1',
        isChannelOwner: true,
      ),
      content: '感谢大家的支持！',
      likeCount: 20,
      isLiked: true,
      createdAtMs: DateTime(2025, 1, 8, 10, 10).millisecondsSinceEpoch,
      isPinned: true,
    ),
    // 有子回复的评论
    ChannelCommentModel(
      id: 'c1',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u1',
        username: 'user1',
        displayName: '用户A',
        avatarUrl: 'https://i.pravatar.cc/100?img=2',
      ),
      content: '这是第一条评论，有子回复',
      replyCount: 8,
      likeCount: 5,
      createdAtMs: DateTime(2025, 1, 8, 10, 5).millisecondsSinceEpoch,
    ),
    // 认证用户评论
    ChannelCommentModel(
      id: 'c2',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u2',
        username: 'user2',
        displayName: '用户B',
        avatarUrl: 'https://i.pravatar.cc/100?img=3',
        isVerified: true,
      ),
      content: '认证用户的评论，内容很精彩！',
      likeCount: 3,
      createdAtMs: DateTime(2025, 1, 8, 10, 15).millisecondsSinceEpoch,
    ),
    // 扩充评论 c3-c20
    ...List.generate(18, (i) {
      final idx = i + 3;
      return ChannelCommentModel(
        id: 'c$idx',
        messageId: 'post_1',
        channelId: 'test',
        author: CommentAuthor(
          id: 'u$idx',
          username: 'user$idx',
          displayName: '用户${String.fromCharCode(67 + i)}', // C, D, E...
          avatarUrl: 'https://i.pravatar.cc/100?img=${4 + i}',
        ),
        content: _mockCommentContents[i % _mockCommentContents.length],
        likeCount: (i * 3 + 1) % 15,
        replyCount: i % 5 == 0 ? 2 : 0,
        createdAtMs: DateTime(
          2025,
          1,
          8,
          10,
          20 + i * 5,
        ).millisecondsSinceEpoch,
      );
    }),
  ],
};

/// 评论内容模板
const _mockCommentContents = [
  '学到了很多，感谢分享！',
  '这个功能太实用了',
  '期待更多更新！',
  '已收藏，慢慢学习',
  '写得真好，通俗易懂',
  '有没有相关的教程推荐？',
  '支持一下！',
  '这个思路很新颖',
  '请问有源码吗？',
  '太棒了，已转发',
  '学习了，感谢楼主',
  '这个方案我之前也想过',
  '干货满满！',
  '请问适用于什么场景？',
  '已关注，期待更多内容',
  '这个设计很优雅',
  '收藏了，以后慢慢看',
  '终于找到解决方案了',
];

// ============================================================================
// 子评论
// ============================================================================

/// 子评论（按 parentCommentId 分组，支持多层嵌套）
final mockReplies = <String, List<ChannelCommentModel>>{
  'c1': [
    ChannelCommentModel(
      id: 'c1_r1',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'owner',
        username: 'owner',
        displayName: '频道主',
        avatarUrl: 'https://i.pravatar.cc/100?img=1',
        isChannelOwner: true,
      ),
      content: '谢谢支持！',
      replyTo: const ReplyTarget(
        commentId: 'c1',
        authorName: '用户A',
        contentPreview: '这是第一条评论，有子回复',
      ),
      likeCount: 10,
      replyCount: 3,
      createdAtMs: DateTime(2025, 1, 8, 10, 8).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c1_r2',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u3',
        username: 'user3',
        displayName: '用户C',
        avatarUrl: 'https://i.pravatar.cc/100?img=4',
      ),
      content: '频道主回复了！',
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '频道主',
        contentPreview: '谢谢支持！',
      ),
      likeCount: 5,
      createdAtMs: DateTime(2025, 1, 8, 10, 9).millisecondsSinceEpoch,
    ),
  ],
  // 第三层嵌套
  'c1_r1': [
    ChannelCommentModel(
      id: 'c1_r1_r1',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u1',
        username: 'user1',
        displayName: '用户A',
        avatarUrl: 'https://i.pravatar.cc/100?img=2',
      ),
      content: '频道主太棒了！继续加油！',
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '频道主',
        contentPreview: '谢谢支持！',
      ),
      likeCount: 8,
      replyCount: 2,
      createdAtMs: DateTime(2025, 1, 8, 10, 12).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c1_r1_r2',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u4',
        username: 'user4',
        displayName: '用户D',
        avatarUrl: 'https://i.pravatar.cc/100?img=5',
      ),
      content: '同感！',
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '频道主',
        contentPreview: '谢谢支持！',
      ),
      likeCount: 2,
      createdAtMs: DateTime(2025, 1, 8, 10, 13).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c1_r1_r3',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'owner',
        username: 'owner',
        displayName: '频道主',
        avatarUrl: 'https://i.pravatar.cc/100?img=1',
        isChannelOwner: true,
      ),
      content: '感谢大家的喜爱～',
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1',
        authorName: '用户A',
        contentPreview: '频道主太棒了！继续加油！',
      ),
      likeCount: 15,
      createdAtMs: DateTime(2025, 1, 8, 10, 15).millisecondsSinceEpoch,
    ),
  ],
  // 第四层嵌套
  'c1_r1_r1': [
    ChannelCommentModel(
      id: 'c1_r1_r1_r1',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u5',
        username: 'user5',
        displayName: '用户E',
        avatarUrl: 'https://i.pravatar.cc/100?img=6',
      ),
      content: '楼上说得对！',
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1',
        authorName: '用户A',
        contentPreview: '频道主太棒了！继续加油！',
      ),
      likeCount: 3,
      replyCount: 1,
      createdAtMs: DateTime(2025, 1, 8, 10, 20).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c1_r1_r1_r2',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u6',
        username: 'user6',
        displayName: '用户F',
        avatarUrl: 'https://i.pravatar.cc/100?img=7',
      ),
      content: '+1',
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1',
        authorName: '用户A',
        contentPreview: '频道主太棒了！继续加油！',
      ),
      likeCount: 1,
      createdAtMs: DateTime(2025, 1, 8, 10, 22).millisecondsSinceEpoch,
    ),
  ],
  // 第五层嵌套
  'c1_r1_r1_r1': [
    ChannelCommentModel(
      id: 'c1_r1_r1_r1_r1',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u1',
        username: 'user1',
        displayName: '用户A',
        avatarUrl: 'https://i.pravatar.cc/100?img=2',
      ),
      content: '哈哈谢谢支持！',
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1_r1',
        authorName: '用户E',
        contentPreview: '楼上说得对！',
      ),
      likeCount: 0,
      createdAtMs: DateTime(2025, 1, 8, 10, 25).millisecondsSinceEpoch,
    ),
  ],
};
