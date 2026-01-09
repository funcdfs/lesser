// 频道 Mock 数据（精简版）
//
// 用于开发阶段，之后可替换为 gRPC 数据源

import '../models/channel_comment_model.dart';
import '../models/channel_message_model.dart';
import '../models/channel_model.dart';
import '../models/reaction_model.dart';

// ============================================================================
// Mock 当前用户
// ============================================================================

const mockCurrentUserId = 'current_user';

const mockCurrentUser = CommentAuthor(
  id: mockCurrentUserId,
  username: 'me',
  displayName: '我',
  avatarUrl: 'https://i.pravatar.cc/100?img=20',
);

// ============================================================================
// Mock 频道
// ============================================================================

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
// Mock 帖子
// ============================================================================

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
      commentCount: 6,
      reactionStats: const ReactionStats(
        counts: {'👍': 10, '❤️': 5},
        totalCount: 15,
      ),
      commentAvatars: [
        'https://i.pravatar.cc/100?img=2',
        'https://i.pravatar.cc/100?img=3',
      ],
    ),
  ],
};

// ============================================================================
// Mock 评论
// ============================================================================

final mockComments = <String, List<ChannelCommentModel>>{
  'post_1': [
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
      replyCount: 2,
      likeCount: 5,
      createdAtMs: DateTime(2025, 1, 8, 10, 5).millisecondsSinceEpoch,
    ),
    // 频道主置顶评论
    ChannelCommentModel(
      id: 'c2',
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
    // 认证用户评论
    ChannelCommentModel(
      id: 'c3',
      messageId: 'post_1',
      channelId: 'test',
      author: const CommentAuthor(
        id: 'u2',
        username: 'user2',
        displayName: '用户B',
        avatarUrl: 'https://i.pravatar.cc/100?img=3',
        isVerified: true,
      ),
      content: '认证用户的评论',
      likeCount: 3,
      createdAtMs: DateTime(2025, 1, 8, 10, 15).millisecondsSinceEpoch,
    ),
  ],
};

// ============================================================================
// 子评论（增加更深嵌套层级）
// ============================================================================

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
