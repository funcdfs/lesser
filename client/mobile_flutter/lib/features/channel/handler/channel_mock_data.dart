// 频道 Mock 数据
//
// 用于开发阶段，之后可替换为 gRPC 数据源

import '../models/channel_comment_model.dart';
import '../models/channel_model.dart';
import '../models/channel_post_model.dart';
import '../models/reaction_model.dart';

// ============================================================================
// Mock 头像
// ============================================================================

const mockAvatars = <String>[
  'https://i.pravatar.cc/100?img=1',
  'https://i.pravatar.cc/100?img=2',
  'https://i.pravatar.cc/100?img=3',
  'https://i.pravatar.cc/100?img=4',
  'https://i.pravatar.cc/100?img=5',
  'https://i.pravatar.cc/100?img=6',
  'https://i.pravatar.cc/100?img=7',
  'https://i.pravatar.cc/100?img=8',
  'https://i.pravatar.cc/100?img=9',
  'https://i.pravatar.cc/100?img=10',
  'https://i.pravatar.cc/100?img=11',
  'https://i.pravatar.cc/100?img=12',
  'https://i.pravatar.cc/100?img=13',
  'https://i.pravatar.cc/100?img=14',
  'https://i.pravatar.cc/100?img=15',
];

// ============================================================================
// Mock 当前用户
// ============================================================================

const mockCurrentUserId = 'current_user_123';

const mockCurrentUser = CommentAuthor(
  id: mockCurrentUserId,
  username: 'me',
  displayName: '我',
  avatarUrl: 'https://i.pravatar.cc/100?img=20',
);

// ============================================================================
// Mock 频道列表
// ============================================================================

final mockChannels = <ChannelModel>[
  // 测试频道（方便调试）
  ChannelModel(
    id: 'test',
    name: '测试频道',
    description: '用于测试评论功能的频道',
    ownerId: 'test_owner',
    subscriberCount: 100,
    postCount: 1,
    lastMessage: '这是一条测试消息',
    lastMessageTime: DateTime(2025, 1, 8, 10, 0),
    unreadCount: 1,
    avatarUrl: mockAvatars[14],
    isSubscribed: true,
  ),
  ChannelModel(
    id: '1',
    name: '妙妙屋主日记',
    description: '分享日常生活、技术心得、资源推荐',
    ownerId: 'owner1',
    subscriberCount: 62633,
    postCount: 1024,
    lastMessage: '感觉TG又开始新一轮的大批量频道封禁了',
    lastMessageTime: DateTime(2025, 1, 7, 0, 15),
    unreadCount: 3,
    avatarUrl: mockAvatars[0],
    isSubscribed: true,
  ),
  ChannelModel(
    id: '2',
    name: '科技前沿',
    description: '追踪全球科技动态，第一时间报道重大科技新闻',
    ownerId: 'owner2',
    subscriberCount: 128450,
    postCount: 3567,
    lastMessage: 'Apple Vision Pro 2 即将发布，新增多项功能',
    lastMessageTime: DateTime(2025, 1, 6, 18, 30),
    unreadCount: 12,
    avatarUrl: mockAvatars[1],
    isSubscribed: true,
  ),
  ChannelModel(
    id: '3',
    name: '设计灵感',
    description: 'UI/UX 设计趋势、优秀作品分享、设计资源',
    ownerId: 'owner3',
    subscriberCount: 45200,
    postCount: 892,
    lastMessage: '2025 年 UI 设计趋势预测',
    lastMessageTime: DateTime(2025, 1, 6, 14, 20),
    unreadCount: 0,
    avatarUrl: mockAvatars[2],
    isSubscribed: true,
  ),
  ChannelModel(
    id: '4',
    name: '开发者日报',
    description: '每日精选开发者资讯、开源项目、技术文章',
    ownerId: 'owner4',
    subscriberCount: 89100,
    postCount: 2156,
    lastMessage: 'Flutter 4.0 正式发布，性能提升 50%',
    lastMessageTime: DateTime(2025, 1, 5, 22, 45),
    unreadCount: 5,
    isMuted: true,
    avatarUrl: mockAvatars[3],
    isSubscribed: true,
  ),
  ChannelModel(
    id: '5',
    name: '摄影分享',
    description: '摄影技巧、后期教程、优秀作品欣赏',
    ownerId: 'owner5',
    subscriberCount: 33800,
    postCount: 567,
    lastMessage: '冬日街拍技巧分享',
    lastMessageTime: DateTime(2025, 1, 5, 10, 0),
    unreadCount: 0,
    avatarUrl: mockAvatars[4],
    isSubscribed: true,
  ),
  ChannelModel(
    id: '6',
    name: '独立开发者',
    description: '独立开发经验分享、产品发布、收入报告',
    ownerId: 'owner6',
    subscriberCount: 56700,
    postCount: 1234,
    lastMessage: '我的 SaaS 产品月收入突破 10k 了！',
    lastMessageTime: DateTime(2025, 1, 4, 20, 30),
    unreadCount: 8,
    avatarUrl: mockAvatars[5],
    isSubscribed: true,
  ),
  ChannelModel(
    id: '7',
    name: 'AI 前沿',
    description: 'AI/ML 最新研究、工具推荐、应用案例',
    ownerId: 'owner7',
    subscriberCount: 234500,
    postCount: 4521,
    lastMessage: 'GPT-5 内部测试版泄露，能力再次飞跃',
    lastMessageTime: DateTime(2025, 1, 4, 15, 0),
    unreadCount: 25,
    avatarUrl: mockAvatars[6],
    isSubscribed: true,
  ),
  ChannelModel(
    id: '8',
    name: '游戏资讯',
    description: '游戏新闻、评测、限免情报',
    ownerId: 'owner8',
    subscriberCount: 78900,
    postCount: 1876,
    lastMessage: 'Nintendo Switch 2 正式公布！',
    lastMessageTime: DateTime(2025, 1, 3, 22, 0),
    unreadCount: 0,
    isMuted: true,
    avatarUrl: mockAvatars[7],
    isSubscribed: true,
  ),
];

// ============================================================================
// Mock 频道消息（Post）
// ============================================================================

final mockMessages = <String, List<ChannelPostModel>>{
  // 测试频道的消息
  'test': [
    ChannelPostModel(
      id: 'test_post_1',
      channelId: 'test',
      authorId: 'test_owner',
      authorName: '测试频道主',
      content: '这是一条测试帖子，用于测试评论功能。\n\n点击下方评论区查看评论。',
      createdAt: DateTime(2025, 1, 8, 10, 0),
      viewCount: 100,
      commentCount: 5,
      reactionStats: const ReactionStats(
        counts: {'👍': 10, '❤️': 5, '🔥': 3},
        totalCount: 18,
      ),
      commentAvatars: [mockAvatars[0], mockAvatars[1], mockAvatars[2]],
    ),
  ],
  '1': [
    ChannelPostModel(
      id: 'm1',
      channelId: '1',
      authorId: 'owner1',
      authorName: '妙妙屋主',
      content:
          'GG，接近30w订阅的老妙妙屋严选频道的辉煌还是落幕了，频道炸了哈，不是我把你们封禁了\n\n新频道：https://t.me/miaomiaowu3311\n\n重新启航，老资源会慢慢全部恢复到新频道里',
      createdAt: DateTime(2025, 1, 5, 22, 35),
      viewCount: 10020,
      commentCount: 147,
      reactionStats: const ReactionStats(
        counts: {'👍': 38, '🔥': 3},
        totalCount: 41,
      ),
      linkUrl: 'https://t.me/miaomiaowu3311',
      linkTitle: '新频道',
      commentAvatars: [
        mockAvatars[0],
        mockAvatars[1],
        mockAvatars[2],
        mockAvatars[3],
        mockAvatars[4],
      ],
    ),
    ChannelPostModel(
      id: 'm2',
      channelId: '1',
      authorId: 'owner1',
      authorName: '妙妙屋主',
      content: '上一条的评论区呢？',
      createdAt: DateTime(2025, 1, 5, 23, 48),
      viewCount: 8670,
      commentCount: 66,
      reactionStats: const ReactionStats(
        counts: {'👍': 14, '❤️': 2},
        totalCount: 16,
      ),
      commentAvatars: [mockAvatars[3], mockAvatars[4], mockAvatars[0]],
    ),
    ChannelPostModel(
      id: 'm3',
      channelId: '1',
      authorId: 'owner1',
      authorName: '妙妙屋主',
      content: '妙妙屋讨论群已开放发言\n下午开始逐步恢复老资源进新频道\n【点击加入妙妙屋新频道】',
      createdAt: DateTime(2025, 1, 6, 13, 18),
      viewCount: 6309,
      commentCount: 24,
      reactionStats: const ReactionStats(
        counts: {'👍': 21, '❤️': 4},
        totalCount: 25,
      ),
      commentAvatars: [
        mockAvatars[1],
        mockAvatars[2],
        mockAvatars[4],
        mockAvatars[0],
      ],
    ),
    ChannelPostModel(
      id: 'm4',
      channelId: '1',
      authorId: 'owner1',
      authorName: '妙妙屋主',
      content: '最近会安排一台日本的真家庭宽带，ip无敌，有需要纯净ip的可以期待一下',
      createdAt: DateTime(2025, 1, 7, 0, 15),
      viewCount: 28108,
      commentCount: 10,
      reactionStats: const ReactionStats(counts: {'❤️': 2}, totalCount: 2),
      myReaction: '❤️',
      commentAvatars: [mockAvatars[0], mockAvatars[3]],
    ),
    ChannelPostModel(
      id: 'm5',
      channelId: '1',
      authorId: 'owner1',
      authorName: '妙妙屋主',
      content: '感觉TG又开始新一轮的大批量频道封禁了',
      createdAt: DateTime(2025, 1, 7, 1, 30),
      viewCount: 737,
      commentCount: 2,
      reactionStats: const ReactionStats(
        counts: {'😢': 22, '👎': 4, '😡': 2, '💔': 1},
        totalCount: 29,
      ),
      commentAvatars: [mockAvatars[2]],
    ),
  ],
  '2': [
    ChannelPostModel(
      id: 'm6',
      channelId: '2',
      authorId: 'owner2',
      authorName: '科技前沿',
      content: 'Apple Vision Pro 2 即将发布，新增多项功能，包括更轻的重量和更长的续航时间。',
      createdAt: DateTime(2025, 1, 6, 18, 30),
      viewCount: 15420,
      commentCount: 89,
      reactionStats: const ReactionStats(
        counts: {'🍎': 156, '👍': 78, '🔥': 45},
        totalCount: 279,
      ),
      commentAvatars: [mockAvatars[0], mockAvatars[1], mockAvatars[2]],
    ),
    ChannelPostModel(
      id: 'm7',
      channelId: '2',
      authorId: 'owner2',
      authorName: '科技前沿',
      content: 'Google 发布 Gemini 2.0，多模态能力大幅提升，支持实时视频理解。',
      createdAt: DateTime(2025, 1, 6, 14, 0),
      viewCount: 23100,
      commentCount: 156,
      reactionStats: const ReactionStats(
        counts: {'🤖': 234, '👍': 123, '🔥': 89},
        totalCount: 446,
      ),
      commentAvatars: [mockAvatars[5], mockAvatars[6], mockAvatars[7]],
    ),
  ],
  '4': [
    ChannelPostModel(
      id: 'm11',
      channelId: '4',
      authorId: 'owner4',
      authorName: '开发者日报',
      content:
          'Flutter 4.0 正式发布！\n\n主要更新：\n• Impeller 渲染引擎全平台支持\n• 热重载速度提升 40%\n• Dart 4.0 带来更强的类型系统\n• 全新的 DevTools 调试体验',
      createdAt: DateTime(2025, 1, 5, 22, 45),
      viewCount: 45600,
      commentCount: 234,
      reactionStats: const ReactionStats(
        counts: {'💙': 567, '🔥': 234, '👍': 189},
        totalCount: 990,
      ),
      commentAvatars: [mockAvatars[10], mockAvatars[11], mockAvatars[12]],
    ),
    ChannelPostModel(
      id: 'm12',
      channelId: '4',
      authorId: 'owner4',
      authorName: '开发者日报',
      content: 'Rust 2.0 发布预告，async/await 语法将迎来重大改进。',
      createdAt: DateTime(2025, 1, 5, 18, 0),
      viewCount: 12300,
      commentCount: 78,
      reactionStats: const ReactionStats(
        counts: {'🦀': 123, '👍': 67},
        totalCount: 190,
      ),
      commentAvatars: [mockAvatars[8], mockAvatars[9]],
    ),
  ],
  '6': [
    ChannelPostModel(
      id: 'm13',
      channelId: '6',
      authorId: 'owner6',
      authorName: '独立开发者',
      content:
          '我的 SaaS 产品月收入突破 \$10k 了！\n\n分享一下这一年的心路历程：\n• 从 0 到 1 用了 3 个月\n• 第一个付费用户来自 Product Hunt\n• SEO 是最稳定的获客渠道\n• 客户反馈是最好的产品经理',
      createdAt: DateTime(2025, 1, 4, 20, 30),
      viewCount: 34500,
      commentCount: 189,
      reactionStats: const ReactionStats(
        counts: {'🎉': 345, '👍': 234, '💰': 123},
        totalCount: 702,
      ),
      commentAvatars: [mockAvatars[0], mockAvatars[1], mockAvatars[5]],
    ),
  ],
  '7': [
    ChannelPostModel(
      id: 'm14',
      channelId: '7',
      authorId: 'owner7',
      authorName: 'AI 前沿',
      content:
          'GPT-5 内部测试版泄露，能力再次飞跃\n\n据可靠消息：\n• 推理能力接近人类专家水平\n• 支持 100 万 tokens 上下文\n• 多模态理解更加自然\n• 预计 Q2 正式发布',
      createdAt: DateTime(2025, 1, 4, 15, 0),
      viewCount: 89000,
      commentCount: 567,
      reactionStats: const ReactionStats(
        counts: {'🤖': 890, '🔥': 456, '👍': 345},
        totalCount: 1691,
      ),
      commentAvatars: [mockAvatars[2], mockAvatars[3], mockAvatars[4]],
    ),
  ],
};

// ============================================================================
// Mock 评论数据
// ============================================================================

final mockComments = <String, List<ChannelCommentModel>>{
  // 测试帖子的评论
  'test_post_1': [
    ChannelCommentModel(
      id: 'test_c1',
      postId: 'test_post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'test_u1',
        username: 'test_user_1',
        displayName: '测试用户1',
        avatarUrl: 'https://i.pravatar.cc/100?img=1',
      ),
      content: '这是第一条测试评论',
      replyCount: 2,
      reactionStats: const ReactionStats(counts: {'👍': 5}, totalCount: 5),
      createdAtMs: DateTime(2025, 1, 8, 10, 5).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'test_c2',
      postId: 'test_post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'test_owner',
        username: 'test_channel',
        displayName: '测试频道主',
        avatarUrl: 'https://i.pravatar.cc/100?img=15',
        isChannelOwner: true,
      ),
      content: '感谢评论！这是频道主的回复',
      replyTo: const ReplyTarget(
        commentId: 'test_c1',
        authorName: '测试用户1',
        contentPreview: '这是第一条测试评论',
      ),
      reactionStats: const ReactionStats(
        counts: {'❤️': 8, '👍': 3},
        totalCount: 11,
      ),
      createdAtMs: DateTime(2025, 1, 8, 10, 10).millisecondsSinceEpoch,
      isPinned: true,
    ),
    ChannelCommentModel(
      id: 'test_c3',
      postId: 'test_post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'test_u2',
        username: 'test_user_2',
        displayName: '测试用户2',
        avatarUrl: 'https://i.pravatar.cc/100?img=2',
        isVerified: true,
      ),
      content: '这是一条认证用户的评论',
      reactionStats: const ReactionStats(counts: {'👍': 3}, totalCount: 3),
      createdAtMs: DateTime(2025, 1, 8, 10, 15).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'test_c4',
      postId: 'test_post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'test_admin',
        username: 'test_admin',
        displayName: '测试管理员',
        avatarUrl: 'https://i.pravatar.cc/100?img=3',
        isChannelAdmin: true,
      ),
      content: '这是管理员的评论',
      reactionStats: const ReactionStats(counts: {'👍': 2}, totalCount: 2),
      createdAtMs: DateTime(2025, 1, 8, 10, 20).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'test_c5',
      postId: 'test_post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'test_u3',
        username: 'test_user_3',
        displayName: '测试用户3',
        avatarUrl: 'https://i.pravatar.cc/100?img=4',
      ),
      content: '这是最后一条测试评论，用于测试滚动',
      reactionStats: const ReactionStats(counts: {'🔥': 1}, totalCount: 1),
      createdAtMs: DateTime(2025, 1, 8, 10, 25).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'nested_root',
      postId: 'test_post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'user_root',
        username: 'root_user',
        displayName: 'Root User',
        avatarUrl: 'https://i.pravatar.cc/100?img=10',
      ),
      content: '【Level 1】This is the root of a deep thread.',
      replyCount: 1, 
      reactionStats: ReactionStats.empty,
      createdAtMs: 1736337600000, 
    ),
  ],
  'm1': [
    ChannelCommentModel(
      id: 'c1',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'u1',
        username: 'test_user',
        displayName: '测试用户',
        avatarUrl: mockAvatars[0],
      ),
      content: '频道主加油！一直支持你',
      replyCount: 3,
      reactionStats: const ReactionStats(
        counts: {'👍': 12, '❤️': 5},
        totalCount: 17,
      ),
      createdAtMs: DateTime(2025, 1, 5, 22, 40).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c2',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'u2',
        username: 'flutter_dev',
        displayName: 'Flutter 开发者',
        avatarUrl: mockAvatars[1],
        isVerified: true,
      ),
      content: '新频道已关注，期待恢复',
      reactionStats: const ReactionStats(counts: {'👍': 8}, totalCount: 8),
      createdAtMs: DateTime(2025, 1, 5, 22, 45).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c3',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'owner1',
        username: 'miaomiao',
        displayName: '妙妙屋主',
        avatarUrl: mockAvatars[2],
        isChannelOwner: true,
      ),
      content: '感谢大家的支持！会尽快恢复的',
      replyTo: const ReplyTarget(
        commentId: 'c1',
        authorName: '测试用户',
        contentPreview: '频道主加油！一直支持你',
      ),
      reactionStats: const ReactionStats(
        counts: {'❤️': 25, '👍': 10},
        totalCount: 35,
      ),
      createdAtMs: DateTime(2025, 1, 5, 23, 0).millisecondsSinceEpoch,
      isPinned: true,
    ),
    ChannelCommentModel(
      id: 'c4',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'u3',
        username: 'random_guy',
        displayName: '路人甲',
        avatarUrl: mockAvatars[3],
      ),
      content: 'TG 封禁太频繁了，希望新频道能长久',
      reactionStats: const ReactionStats(
        counts: {'😢': 6, '👍': 3},
        totalCount: 9,
      ),
      createdAtMs: DateTime(2025, 1, 5, 23, 15).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c5',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'u4',
        username: 'admin_helper',
        displayName: '管理员小助手',
        avatarUrl: mockAvatars[4],
        isChannelAdmin: true,
      ),
      content: '大家有问题可以在群里反馈，我们会尽快处理',
      reactionStats: const ReactionStats(counts: {'👍': 15}, totalCount: 15),
      createdAtMs: DateTime(2025, 1, 6, 10, 0).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c8',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'u6',
        username: 'old_fan',
        displayName: '老粉丝',
        avatarUrl: mockAvatars[5],
      ),
      content: '从第一天就关注了，一路走来不容易啊',
      replyCount: 1,
      reactionStats: const ReactionStats(
        counts: {'❤️': 18, '👍': 12},
        totalCount: 30,
      ),
      createdAtMs: DateTime(2025, 1, 5, 22, 50).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c9',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'u7',
        username: 'tech_lover',
        displayName: '技术爱好者',
        avatarUrl: mockAvatars[6],
      ),
      content: '建议做个备份机制，防止再次被封',
      reactionStats: const ReactionStats(
        counts: {'👍': 45, '💡': 12},
        totalCount: 57,
      ),
      createdAtMs: DateTime(2025, 1, 5, 23, 30).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c10',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'owner1',
        username: 'miaomiao',
        displayName: '妙妙屋主',
        avatarUrl: mockAvatars[2],
        isChannelOwner: true,
      ),
      content: '好建议！已经在考虑多平台同步了',
      replyTo: const ReplyTarget(
        commentId: 'c9',
        authorName: '技术爱好者',
        contentPreview: '建议做个备份机制，防止再次被封',
      ),
      reactionStats: const ReactionStats(counts: {'👍': 23}, totalCount: 23),
      createdAtMs: DateTime(2025, 1, 5, 23, 35).millisecondsSinceEpoch,
    ),
  ],
  'm2': [
    ChannelCommentModel(
      id: 'c6',
      postId: 'm2',
      channelId: '1',
      author: CommentAuthor(
        id: 'u5',
        username: 'curious_cat',
        displayName: '好奇猫',
        avatarUrl: mockAvatars[7],
      ),
      content: '评论区被清空了吗？',
      replyCount: 2,
      reactionStats: const ReactionStats(counts: {'🤔': 8}, totalCount: 8),
      createdAtMs: DateTime(2025, 1, 5, 23, 50).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c7',
      postId: 'm2',
      channelId: '1',
      author: CommentAuthor(
        id: 'owner1',
        username: 'miaomiao',
        displayName: '妙妙屋主',
        avatarUrl: mockAvatars[2],
        isChannelOwner: true,
      ),
      content: '是的，频道被封后评论区数据丢失了',
      replyTo: const ReplyTarget(
        commentId: 'c6',
        authorName: '好奇猫',
        contentPreview: '评论区被清空了吗？',
      ),
      reactionStats: const ReactionStats(
        counts: {'😢': 12, '👍': 5},
        totalCount: 17,
      ),
      createdAtMs: DateTime(2025, 1, 6, 0, 5).millisecondsSinceEpoch,
    ),
  ],
  'm6': [
    ChannelCommentModel(
      id: 'c11',
      postId: 'm6',
      channelId: '2',
      author: CommentAuthor(
        id: 'u8',
        username: 'apple_fan',
        displayName: 'Apple 粉',
        avatarUrl: mockAvatars[8],
      ),
      content: '终于等到了！希望价格能降一点',
      replyCount: 5,
      reactionStats: const ReactionStats(
        counts: {'🍎': 34, '👍': 23},
        totalCount: 57,
      ),
      createdAtMs: DateTime(2025, 1, 6, 18, 35).millisecondsSinceEpoch,
    ),
  ],
};

// ============================================================================
// 子评论（按父评论 ID 索引）
// ============================================================================

/// 子评论 mock 数据
/// key: 父评论 ID, value: 子评论列表
final mockReplies = <String, List<ChannelCommentModel>>{
  // test_c1 的回复
  'test_c1': [
    ChannelCommentModel(
      id: 'test_c1_r1',
      postId: 'test_post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'test_u4',
        username: 'reply_user_1',
        displayName: '回复用户1',
        avatarUrl: 'https://i.pravatar.cc/100?img=5',
      ),
      content: '同意楼上的观点！',
      replyTo: const ReplyTarget(
        commentId: 'test_c1',
        authorName: '测试用户1',
        contentPreview: '这是第一条测试评论',
      ),
      reactionStats: const ReactionStats(counts: {'👍': 2}, totalCount: 2),
      createdAtMs: DateTime(2025, 1, 8, 10, 8).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'test_c1_r2',
      postId: 'test_post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'test_u5',
        username: 'reply_user_2',
        displayName: '回复用户2',
        avatarUrl: 'https://i.pravatar.cc/100?img=6',
      ),
      content: '我也觉得说得很好',
      replyTo: const ReplyTarget(
        commentId: 'test_c1',
        authorName: '测试用户1',
        contentPreview: '这是第一条测试评论',
      ),
      reactionStats: const ReactionStats(counts: {'❤️': 1}, totalCount: 1),
      createdAtMs: DateTime(2025, 1, 8, 10, 9).millisecondsSinceEpoch,
    ),
  ],
  // c1 的回复（频道主加油那条）
  'c1': [
    ChannelCommentModel(
      id: 'c1_r1',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'owner1',
        username: 'miaomiao',
        displayName: '妙妙屋主',
        avatarUrl: mockAvatars[2],
        isChannelOwner: true,
      ),
      content: '谢谢支持！会继续努力的',
      replyTo: const ReplyTarget(
        commentId: 'c1',
        authorName: '测试用户',
        contentPreview: '频道主加油！一直支持你',
      ),
      reactionStats: const ReactionStats(counts: {'❤️': 15}, totalCount: 15),
      createdAtMs: DateTime(2025, 1, 5, 22, 45).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c1_r2',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'u6',
        username: 'fan_2',
        displayName: '忠实粉丝',
        avatarUrl: mockAvatars[5],
      ),
      content: '频道主回复了！好激动',
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '妙妙屋主',
        contentPreview: '谢谢支持！会继续努力的',
      ),
      reactionStats: const ReactionStats(
        counts: {'😂': 8, '👍': 3},
        totalCount: 11,
      ),
      createdAtMs: DateTime(2025, 1, 5, 22, 50).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c1_r3',
      postId: 'm1',
      channelId: '1',
      author: CommentAuthor(
        id: 'u7',
        username: 'new_follower',
        displayName: '新关注',
        avatarUrl: mockAvatars[6],
      ),
      content: '刚关注，感觉这个频道很有意思',
      reactionStats: const ReactionStats(counts: {'👍': 5}, totalCount: 5),
      createdAtMs: DateTime(2025, 1, 5, 23, 0).millisecondsSinceEpoch,
    ),
  ],
  // c6 的回复
  'c6': [
    ChannelCommentModel(
      id: 'c6_r1',
      postId: 'm2',
      channelId: '1',
      author: CommentAuthor(
        id: 'owner1',
        username: 'miaomiao',
        displayName: '妙妙屋主',
        avatarUrl: mockAvatars[2],
        isChannelOwner: true,
      ),
      content: '是的，之前的评论都没了，大家重新来过吧',
      replyTo: const ReplyTarget(
        commentId: 'c6',
        authorName: '好奇猫',
        contentPreview: '评论区被清空了吗？',
      ),
      reactionStats: const ReactionStats(counts: {'😢': 20}, totalCount: 20),
      createdAtMs: DateTime(2025, 1, 5, 23, 55).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c6_r2',
      postId: 'm2',
      channelId: '1',
      author: CommentAuthor(
        id: 'u8',
        username: 'old_member',
        displayName: '老成员',
        avatarUrl: mockAvatars[7],
      ),
      content: '太可惜了，之前有很多精彩的讨论',
      replyTo: const ReplyTarget(
        commentId: 'c6_r1',
        authorName: '妙妙屋主',
        contentPreview: '是的，之前的评论都没了',
      ),
      reactionStats: const ReactionStats(
        counts: {'😢': 12, '👍': 5},
        totalCount: 17,
      ),
      createdAtMs: DateTime(2025, 1, 6, 0, 5).millisecondsSinceEpoch,
    ),
  ],
  // c11 的回复（Apple 粉那条）
  'c11': [
    ChannelCommentModel(
      id: 'c11_r1',
      postId: 'm6',
      channelId: '2',
      author: CommentAuthor(
        id: 'u9',
        username: 'tech_reviewer',
        displayName: '科技测评',
        avatarUrl: mockAvatars[0],
        isVerified: true,
      ),
      content: '价格应该不会便宜，毕竟是 Pro 系列',
      replyTo: const ReplyTarget(
        commentId: 'c11',
        authorName: 'Apple 粉',
        contentPreview: '终于等到了！希望价格能降一点',
      ),
      reactionStats: const ReactionStats(counts: {'👍': 18}, totalCount: 18),
      createdAtMs: DateTime(2025, 1, 6, 18, 40).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c11_r2',
      postId: 'm6',
      channelId: '2',
      author: CommentAuthor(
        id: 'u10',
        username: 'budget_buyer',
        displayName: '预算党',
        avatarUrl: mockAvatars[1],
      ),
      content: '等 SE 系列吧，Pro 太贵了',
      reactionStats: const ReactionStats(
        counts: {'😂': 10, '👍': 8},
        totalCount: 18,
      ),
      createdAtMs: DateTime(2025, 1, 6, 18, 45).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c11_r3',
      postId: 'm6',
      channelId: '2',
      author: CommentAuthor(
        id: 'u11',
        username: 'android_user',
        displayName: '安卓用户',
        avatarUrl: mockAvatars[3],
      ),
      content: '安卓不香吗？',
      reactionStats: const ReactionStats(
        counts: {'😂': 25, '👎': 5},
        totalCount: 30,
      ),
      createdAtMs: DateTime(2025, 1, 6, 18, 50).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c11_r4',
      postId: 'm6',
      channelId: '2',
      author: CommentAuthor(
        id: 'u8',
        username: 'apple_fan',
        displayName: 'Apple 粉',
        avatarUrl: mockAvatars[8],
      ),
      content: '各有所爱吧，我就是喜欢 iOS 生态',
      replyTo: const ReplyTarget(
        commentId: 'c11_r3',
        authorName: '安卓用户',
        contentPreview: '安卓不香吗？',
      ),
      reactionStats: const ReactionStats(
        counts: {'👍': 15, '❤️': 8},
        totalCount: 23,
      ),
      createdAtMs: DateTime(2025, 1, 6, 18, 55).millisecondsSinceEpoch,
    ),
    ChannelCommentModel(
      id: 'c11_r5',
      postId: 'm6',
      channelId: '2',
      author: CommentAuthor(
        id: 'owner2',
        username: 'tech_daily',
        displayName: '科技日报',
        avatarUrl: mockAvatars[4],
        isChannelOwner: true,
      ),
      content: '大家理性讨论，不要引战哦',
      reactionStats: const ReactionStats(counts: {'👍': 30}, totalCount: 30),
      createdAtMs: DateTime(2025, 1, 6, 19, 0).millisecondsSinceEpoch,
    ),
  ],
  'nested_root': [
    const ChannelCommentModel(
      id: 'nested_l2',
      postId: 'test_post_1',
      channelId: 'test',
      author: CommentAuthor(
        id: 'user_l2',
        username: 'l2_user',
        displayName: 'Level 2 User',
        avatarUrl: 'https://i.pravatar.cc/100?img=11',
      ),
      content: '【Level 2】Reply to Root. Click "View Replies" to go deeper.',
      replyTo: ReplyTarget(
        commentId: 'nested_root',
        authorName: 'Root User',
        contentPreview: '【Level 1】This is the root of a deep thread.',
      ),
      replyCount: 1,
      createdAtMs: 1736337660000,
    ),
  ],

  'nested_l2': [
    const ChannelCommentModel(
      id: 'nested_l3',
      postId: 'test_post_1',
      channelId: 'test',
      author: CommentAuthor(
        id: 'user_l3',
        username: 'l3_user',
        displayName: 'Level 3 User',
        avatarUrl: 'https://i.pravatar.cc/100?img=12',
      ),
      content: '【Level 3】We are getting deeper.',
      replyTo: ReplyTarget(
        commentId: 'nested_l2',
        authorName: 'Level 2 User',
        contentPreview: '【Level 2】Reply to Root.',
      ),
      replyCount: 1,
      createdAtMs: 1736337720000,
    ),
  ],

  'nested_l3': [
    const ChannelCommentModel(
      id: 'nested_l4',
      postId: 'test_post_1',
      channelId: 'test',
      author: CommentAuthor(
        id: 'user_l4',
        username: 'l4_user',
        displayName: 'Level 4 User',
        avatarUrl: 'https://i.pravatar.cc/100?img=13',
      ),
      content: '【Level 4】Still going down.',
      replyTo: ReplyTarget(
        commentId: 'nested_l3',
        authorName: 'Level 3 User',
        contentPreview: '【Level 3】We are getting deeper.',
      ),
      replyCount: 1,
      createdAtMs: 1736337780000,
    ),
  ],

  'nested_l4': [
    const ChannelCommentModel(
      id: 'nested_l5',
      postId: 'test_post_1',
      channelId: 'test',
      author: CommentAuthor(
        id: 'user_l5',
        username: 'l5_user',
        displayName: 'Level 5 User',
        avatarUrl: 'https://i.pravatar.cc/100?img=14',
      ),
      content: '【Level 5】Almost there.',
      replyTo: ReplyTarget(
        commentId: 'nested_l4',
        authorName: 'Level 4 User',
        contentPreview: '【Level 4】Still going down.',
      ),
      replyCount: 1,
      createdAtMs: 1736337840000,
    ),
  ],

  'nested_l5': [
    const ChannelCommentModel(
      id: 'nested_l6',
      postId: 'test_post_1',
      channelId: 'test',
      author: CommentAuthor(
        id: 'user_l6',
        username: 'l6_user',
        displayName: 'Level 6 User',
        avatarUrl: 'https://i.pravatar.cc/100?img=15',
      ),
      content: '【Level 6】This is level 6.',
      replyTo: ReplyTarget(
        commentId: 'nested_l5',
        authorName: 'Level 5 User',
        contentPreview: '【Level 5】Almost there.',
      ),
      replyCount: 1,
       createdAtMs: 1736337900000,
    ),
  ],
  
  'nested_l6': [
      const ChannelCommentModel(
      id: 'nested_l7',
      postId: 'test_post_1',
      channelId: 'test',
      author: CommentAuthor(
        id: 'user_l7',
        username: 'l7_user',
        displayName: 'Level 7 User',
        avatarUrl: 'https://i.pravatar.cc/100?img=16',
      ),
      content: '【Level 7】Bottom of the ocean.',
      replyTo: ReplyTarget(
        commentId: 'nested_l6',
        authorName: 'Level 6 User',
        contentPreview: '【Level 6】This is level 6.',
      ),
      replyCount: 0,
       createdAtMs: 1736337960000,
    ),
  ]
};
