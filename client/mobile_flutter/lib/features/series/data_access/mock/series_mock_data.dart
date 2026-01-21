// =============================================================================
// 剧集 Mock 数据 - Series Mock Data
// =============================================================================
//
// ## 设计目的
// 提供剧集模块开发和测试所需的模拟数据，包括：
// - 标签数据（Series Tags）
// - 剧集数据（Series List）
// - 动态数据（Posts）
// - 评论数据（基于闭包表的多叉树结构）
//
// ## 数据结构
// - mockSeriesTags: 标签列表
// - mockCurrentUser: 当前用户信息
// - mockSeriesList: 剧集列表
// - mockSeriesUIStates: 剧集 UI 状态（未读数等）
// - mockPosts: 动态列表（按 seriesId 分组）
// - mockComments: 评论根节点
// - mockReplies: 评论子节点
//
// ## 使用说明
// 这些数据由 SeriesMockDataSource 使用，后续可替换为 gRPC 数据源。
//
// =============================================================================

import '../../models/series_comment_model.dart';
import '../../models/series_post_model.dart';
import '../../models/series_model.dart';
import '../../models/series_tag.dart';
import '../../models/reaction_model.dart';

// 重新导出 ReplyTarget 供外部使用
export '../../models/series_comment_model.dart' show ReplyTarget;

// =============================================================================
// 标签数据
// =============================================================================

/// 剧集标签列表 (Types & Genres)
const mockSeriesTags = <SeriesTag>[
  // Types
  SeriesTag(id: 'official', name: '官方', icon: '📢'),
  SeriesTag(id: 'user', name: '用户', icon: '👤'),
  SeriesTag(id: 'verified', name: '认证', icon: '🌟'),
  
  // Genres
  SeriesTag(id: '1', name: '剧情', icon: '🎭'),
  SeriesTag(id: '2', name: '科幻', icon: '👽'),
  SeriesTag(id: '3', name: '动作', icon: '💥'),
  SeriesTag(id: '4', name: '喜剧', icon: '🤣'),
  SeriesTag(id: '5', name: '爱情', icon: '❤️'),
  SeriesTag(id: '6', name: '恐怖', icon: '👻'),
  SeriesTag(id: '7', name: '动画', icon: '🎨'),
  SeriesTag(id: '8', name: '纪录片', icon: '📹'),
];

// =============================================================================
// 当前用户
// =============================================================================

/// 当前用户 ID（用于判断评论所有权、点赞状态等）
const mockCurrentUserId = 'current_user';

/// 当前用户信息
///
/// 用于评论发布时的作者信息。
const mockCurrentUser = CommentAuthor(
  id: mockCurrentUserId,
  username: 'me',
  displayName: '我',
  avatarUrl: 'https://i.pravatar.cc/100?img=20',
);

// =============================================================================
// 剧集数据
// =============================================================================

/// 剧集列表 (TV Series / Movies)
final mockSeriesList = <SeriesModel>[
  SeriesModel(
    id: 'three_body',
    name: 'three_body',
    title: '三体 (Three Body)',
    description: '三体电视剧官方讨论组',
    ownerId: 'official_tb',
    subscriberCount: 54000,
    postCount: 30,
    lastPostPreview: '第30集：大结局详细解读，高能预警！',
    lastPostTime: DateTime(2025, 1, 22, 20, 0),
    coverUrl: 'https://m.media-amazon.com/images/M/MV5BODVmMmIyNzktYWNhNC00MjU5LWFkMDYtMTNhYTkzMjFmYDY4XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg', // Placeholder
    isSubscribed: true,
    isOfficial: true,
    tags: ['official', '2'], // Official, Sci-Fi
    link: 'https://lesser.app/s/three_body',
  ),
  SeriesModel(
    id: 'breaking_bad_fans',
    name: 'breaking_bad_fans',
    title: '绝命毒师 (粉丝组)',
    description: '绝命毒师深度解析与细节挖掘',
    ownerId: 'fan_leader',
    subscriberCount: 1200,
    postCount: 62,
    lastPostPreview: 'E14: Ozymandias 依然是神作！',
    lastPostTime: DateTime(2025, 1, 21, 15, 30),
    coverUrl: 'https://m.media-amazon.com/images/M/MV5BMjhiMzgxZTctNDc1Ni00OTIxLTlhMTYtZTA3ZWFkODRkNmE2XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg',
    isSubscribed: true,
    isPublic: true,
    tags: ['user', '1'], // User, Drama
    link: 'https://lesser.app/s/breaking_bad_fans',
  ),
  SeriesModel(
    id: 'actor_review',
    name: 'actor_review',
    title: '专业影评人组',
    description: '资深影评人对近期热剧的点评',
    ownerId: 'critic_vip',
    subscriberCount: 8900,
    postCount: 5,
    lastPostPreview: '本周新片红黑榜',
    lastPostTime: DateTime(2025, 1, 20, 10, 0),
    coverUrl: 'https://i.pravatar.cc/100?img=50',
    isSubscribed: false,
    isVerified: true,
    tags: ['verified', '1'], // Verified, Drama
    link: 'https://lesser.app/s/actor_review',
  ),
];

/// 剧集 UI 状态
final mockSeriesUIStates = <String, SeriesUIState>{
  'three_body': const SeriesUIState(seriesId: 'three_body', unreadCount: 2),
  'breaking_bad_fans': const SeriesUIState(seriesId: 'breaking_bad_fans', unreadCount: 5),
  'actor_review': const SeriesUIState(seriesId: 'actor_review', unreadCount: 0),
};

// =============================================================================
// 动态数据
// =============================================================================

/// 剧集动态（按 seriesId 分组）
final mockPosts = <String, List<SeriesPostModel>>{
  'three_body': [
    SeriesPostModel(
      id: 'ep_30',
      seriesId: 'three_body',
      authorId: 'official_tb',
      authorName: '三体官方',
      content: '第30集：大结局详细解读，高能预警！\n本集主要讲述了古筝计划的实施以及叶文洁的最终审判...',
      createdAt: DateTime(2025, 1, 22, 20, 0),
      viewCount: 50000,
      commentCount: 1200,
      reactionStats: const ReactionStats(
        counts: {'🔥': 500, '👍': 200},
        totalCount: 700,
      ),
    ),
    SeriesPostModel(
      id: 'ep_29',
      seriesId: 'three_body',
      authorId: 'official_tb',
      authorName: '三体官方',
      content: '第29集：古筝行动前奏\n史强制定了详细的作战计划...',
      createdAt: DateTime(2025, 1, 21, 20, 0),
      viewCount: 45000,
      commentCount: 800,
    ),
  ],
  'breaking_bad_fans': [
     SeriesPostModel(
      id: 'bb_discussion_1',
      seriesId: 'breaking_bad_fans',
      authorId: 'fan_leader',
      authorName: '老白迷弟',
      content: 'E14: Ozymandias 依然是神作！\n昨晚重温了一遍，汉克死的时候心都碎了。',
      createdAt: DateTime(2025, 1, 21, 15, 30),
      viewCount: 300,
      commentCount: 45,
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
    displayName: '剧集主',
    avatarUrl: 'https://i.pravatar.cc/100?img=1',
    isSeriesOwner: true,
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

/// 根评论（按 postId 分组）
///
/// 存储每条动态下的根评论列表。
final mockComments = <String, List<SeriesCommentModel>>{
  'post_1': [
    SeriesCommentModel(
      id: 'c1',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('u1'),
      content: '这是第一条评论，有子回复',
      createdAtMs: 1736330700000, // 2025-01-08 10:05
      replyCount: 5,
    ),
    SeriesCommentModel(
      id: 'c2',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('owner'),
      content: '感谢大家的支持！',
      createdAtMs: 1736331000000, // 2025-01-08 10:10
      isPinned: true,
    ),
    SeriesCommentModel(
      id: 'c3',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('u2'),
      content: '认证用户的评论',
      createdAtMs: 1736331300000, // 2025-01-08 10:15
    ),
  ],
};

/// 子评论（按 parentId 分组）
///
/// 存储每条评论下的直接子评论列表。
/// 支持多层嵌套：c1 -> c1_r1 -> c1_r1_r1 -> ...
final mockReplies = <String, List<SeriesCommentModel>>{
  // c1 的直接回复
  'c1': [
    SeriesCommentModel(
      id: 'c1_r1',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('owner'),
      content: '谢谢支持！',
      createdAtMs: 1736331600000, // 2025-01-08 10:20
      replyTo: const ReplyTarget(
        commentId: 'c1',
        authorName: '用户A',
        contentPreview: '这是第一条评论，有子回复',
      ),
      replyCount: 3,
    ),
    SeriesCommentModel(
      id: 'c1_r2',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('u3'),
      content: '剧集主回复了！',
      createdAtMs: 1736331900000, // 2025-01-08 10:25
      replyTo: const ReplyTarget(
        commentId: 'c1',
        authorName: '用户A',
        contentPreview: '这是第一条评论，有子回复',
      ),
    ),
  ],
  // c1_r1 的回复（第三层）
  'c1_r1': [
    SeriesCommentModel(
      id: 'c1_r1_r1',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('u1'),
      content: '剧集主太棒了！继续加油！',
      createdAtMs: 1736332200000, // 2025-01-08 10:30
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '剧集主',
        contentPreview: '谢谢支持！',
      ),
      replyCount: 2,
    ),
    SeriesCommentModel(
      id: 'c1_r1_r2',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('u4'),
      content: '同感！',
      createdAtMs: 1736332500000, // 2025-01-08 10:35
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '剧集主',
        contentPreview: '谢谢支持！',
      ),
    ),
    SeriesCommentModel(
      id: 'c1_r1_r3',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('owner'),
      content: '感谢大家的喜爱～',
      createdAtMs: 1736332800000, // 2025-01-08 10:40
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '剧集主',
        contentPreview: '谢谢支持！',
      ),
    ),
  ],
  // c1_r1_r1 的回复（第四层）
  'c1_r1_r1': [
    SeriesCommentModel(
      id: 'c1_r1_r1_r1',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('u5'),
      content: '楼上说得对！',
      createdAtMs: 1736333100000, // 2025-01-08 10:45
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1',
        authorName: '用户A',
        contentPreview: '剧集主太棒了！继续加油！',
      ),
      replyCount: 1,
    ),
    SeriesCommentModel(
      id: 'c1_r1_r1_r2',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('u6'),
      content: '+1',
      createdAtMs: 1736333400000, // 2025-01-08 10:50
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1',
        authorName: '用户A',
        contentPreview: '剧集主太棒了！继续加油！',
      ),
    ),
  ],
  // c1_r1_r1_r1 的回复（第五层）
  'c1_r1_r1_r1': [
    SeriesCommentModel(
      id: 'c1_r1_r1_r1_r1',
      postId: 'post_1',
      seriesId: 'test',
      author: _getAuthor('u1'),
      content: '哈哈谢谢支持！',
      createdAtMs: 1736333700000, // 2025-01-08 10:55
      replyTo: const ReplyTarget(
        commentId: 'c1_r1_r1_r1',
        authorName: '用户E',
        contentPreview: '楼上说得对！',
      ),
    ),
  ],
};
