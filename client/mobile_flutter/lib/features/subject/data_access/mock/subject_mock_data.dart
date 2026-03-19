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
// - mockSubjectTags: 标签列表
// - mockCurrentUser: 当前用户信息
// - mockSubjectList: 剧集列表
// - mockSubjectUIStates: 剧集 UI 状态（未读数等）
// - mockPosts: 动态列表（按 subjectId 分组）
// - mockComments: 评论根节点
// - mockReplies: 评论子节点
//
// ## 使用说明
// 这些数据由 SeriesMockDataSource 使用，后续可替换为 gRPC 数据源。
//
// =============================================================================

import '../../models/subject_comment_model.dart';
import '../../models/message_model.dart';
import '../../models/subject_model.dart';
import '../../models/subject_topic_model.dart';
import '../../models/subject_tag.dart';
import '../../models/reaction_model.dart';

// 重新导出 ReplyTarget 供外部使用
export '../../models/subject_comment_model.dart' show ReplyTarget;

// =============================================================================
// 标签数据
// =============================================================================

/// 剧集标签列表 (Types & Genres)
const mockSubjectTags = <SubjectTag>[
  // Types
  SubjectTag(id: 'official', name: '官方', icon: '📢'),
  SubjectTag(id: 'user', name: '用户', icon: '👤'),
  SubjectTag(id: 'verified', name: '认证', icon: '🌟'),
  
  // Genres
  SubjectTag(id: '1', name: '剧情', icon: '🎭'),
  SubjectTag(id: '2', name: '科幻', icon: '👽'),
  SubjectTag(id: '3', name: '动作', icon: '💥'),
  SubjectTag(id: '4', name: '喜剧', icon: '🤣'),
  SubjectTag(id: '5', name: '爱情', icon: '❤️'),
  SubjectTag(id: '6', name: '恐怖', icon: '👻'),
  SubjectTag(id: '7', name: '动画', icon: '🎨'),
  SubjectTag(id: '8', name: '纪录片', icon: '📹'),
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

/// 剧集列表 (TV Subjects / Movies)
final mockSubjectList = <SubjectModel>[
  SubjectModel(
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
  SubjectModel(
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
  SubjectModel(
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
final mockSubjectUIStates = <String, SubjectUIState>{
  'three_body': const SubjectUIState(subjectId: 'three_body', unreadCount: 2),
  'breaking_bad_fans': const SubjectUIState(subjectId: 'breaking_bad_fans', unreadCount: 5),
  'actor_review': const SubjectUIState(subjectId: 'actor_review', unreadCount: 0),
};

// =============================================================================
// 动态数据
// =============================================================================

/// 剧集动态（按 seriesId 分组）
final mockPosts = <String, List<MessageModel>>{
  'three_body': [
    MessageModel(
      id: 'ep_30',
      subjectId: 'three_body',
      topicId: 'topic_three_body_01',
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
    MessageModel(
      id: 'ep_29',
      subjectId: 'three_body',
      topicId: 'topic_three_body_01',
      authorId: 'official_tb',
      authorName: '三体官方',
      content: '第29集：古筝行动前奏\n史强制定了详细的作战计划...',
      createdAt: DateTime(2025, 1, 21, 20, 0),
      viewCount: 45000,
      commentCount: 800,
    ),
  ],
  'breaking_bad_fans': [
     MessageModel(
      id: 'bb_discussion_1',
      subjectId: 'breaking_bad_fans',
      topicId: 'topic_bb_01',
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
// 话题数据
// =============================================================================

/// 剧集话题（按 seriesId 分组）
final mockTopics = <String, List<SubjectTopicModel>>{
  'three_body': [
    SubjectTopicModel(
      id: 'topic_three_body_01',
      title: '剧情讨论专区',
      description: '关于三体电视剧每一集的详细剧情讨论',
      postCount: 2,
      lastPostTime: DateTime(2025, 1, 22, 20, 0),
      isPinned: true,
    ),
    SubjectTopicModel(
      id: 'topic_three_body_02',
      title: '原著党集合',
      description: '原著小说与电视剧的改编差异讨论',
      postCount: 0,
      lastPostTime: DateTime(2025, 1, 20, 10, 0),
    ),
  ],
  'breaking_bad_fans': [
    SubjectTopicModel(
      id: 'topic_bb_01',
      title: '经典剧集回顾',
      description: '第一季到第五季的精彩细节挖掘',
      postCount: 1,
      lastPostTime: DateTime(2025, 1, 21, 15, 30),
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
    isSubjectOwner: true,
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
final mockComments = <String, List<SubjectCommentModel>>{
  'post_1': [
    SubjectCommentModel(
      id: 'c1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u1'),
      content: '这是第一条评论，有子回复',
      createdAtMs: 1736330700000, // 2025-01-08 10:05
      replyCount: 5,
    ),
    SubjectCommentModel(
      id: 'c2',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('owner'),
      content: '感谢大家的支持！',
      createdAtMs: 1736331000000, // 2025-01-08 10:10
      isPinned: true,
    ),
    SubjectCommentModel(
      id: 'c3',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u2'),
      content: '认证用户的评论',
      createdAtMs: 1736331300000, // 2025-01-08 10:15
    ),
    SubjectCommentModel(
      id: 'c4',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u1'),
      content: '这是第一个 5 层嵌套评论的起点 (c4)',
      createdAtMs: 1737527795000,
      replyCount: 1,
    ),
    SubjectCommentModel(
      id: 'c5',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u3'),
      content: '这是第二个 5 层嵌套评论的起点 (c5)',
      createdAtMs: 1737527796000,
      replyCount: 1,
    ),
  ],
  'ep_30': [
    SubjectCommentModel(
      id: 'tb30_c1',
      postId: 'ep_30',
      subjectId: 'three_body',
      author: _getAuthor('u1'),
      content: '大结局太震撼了！古筝计划那段看得我心惊肉跳。',
      createdAtMs: 1737547200000,
      replyCount: 1,
    ),
    SubjectCommentModel(
      id: 'tb30_c2',
      postId: 'ep_30',
      subjectId: 'three_body',
      author: _getAuthor('owner'),
      content: '感谢大家陪我们走到最后，三体的故事还在继续。',
      createdAtMs: 1737547500000,
      isPinned: true,
      replyCount: 1,
    ),
  ],
  'ep_29': [
    SubjectCommentModel(
      id: 'tb29_c1',
      postId: 'ep_29',
      subjectId: 'three_body',
      author: _getAuthor('u2'),
      content: '史强果然是剧里的灵魂人物，这计谋太绝了。',
      createdAtMs: 1737460800000,
      replyCount: 1,
    ),
  ],
  'bb_discussion_1': [
    SubjectCommentModel(
      id: 'bb_c1',
      postId: 'bb_discussion_1',
      subjectId: 'breaking_bad_fans',
      author: _getAuthor('u4'),
      content: 'Ozymandias 真的是美剧史上的巅峰，汉克的谢幕太悲壮了。',
      createdAtMs: 1737444600000,
      replyCount: 1,
    ),
  ],
};

/// 子评论（按 parentId 分组）
///
/// 存储每条评论下的直接子评论列表。
/// 支持多层嵌套：c1 -> c1_r1 -> c1_r1_r1 -> ...
final mockReplies = <String, List<SubjectCommentModel>>{
  // c1 的直接回复
  'c1': [
    SubjectCommentModel(
      id: 'c1_r1',
      postId: 'post_1',
      subjectId: 'test',
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
    SubjectCommentModel(
      id: 'c1_r2',
      postId: 'post_1',
      subjectId: 'test',
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
    SubjectCommentModel(
      id: 'c1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
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
    SubjectCommentModel(
      id: 'c1_r1_r2',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u4'),
      content: '同感！',
      createdAtMs: 1736332500000, // 2025-01-08 10:35
      replyTo: const ReplyTarget(
        commentId: 'c1_r1',
        authorName: '剧集主',
        contentPreview: '谢谢支持！',
      ),
    ),
    SubjectCommentModel(
      id: 'c1_r1_r3',
      postId: 'post_1',
      subjectId: 'test',
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
    SubjectCommentModel(
      id: 'c1_r1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
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
    SubjectCommentModel(
      id: 'c1_r1_r1_r2',
      postId: 'post_1',
      subjectId: 'test',
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
    SubjectCommentModel(
      id: 'c1_r1_r1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
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
  // c4 的回复链
  'c4': [
    SubjectCommentModel(
      id: 'c4_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u2'),
      content: 'c4 的第一层回复',
      createdAtMs: 1737527800000,
      replyTo: const ReplyTarget(commentId: 'c4', authorName: '用户A', contentPreview: '这是第一个 5 层嵌套评论的起点 (c4)'),
      replyCount: 1,
    ),
  ],
  'c4_r1': [
    SubjectCommentModel(
      id: 'c4_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u3'),
      content: 'c4 的第二层回复',
      createdAtMs: 1737527810000,
      replyTo: const ReplyTarget(commentId: 'c4_r1', authorName: '用户B', contentPreview: 'c4 的第一层回复'),
      replyCount: 1,
    ),
  ],
  'c4_r1_r1': [
    SubjectCommentModel(
      id: 'c4_r1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u4'),
      content: 'c4 的第三层回复',
      createdAtMs: 1737527820000,
      replyTo: const ReplyTarget(commentId: 'c4_r1_r1', authorName: '用户C', contentPreview: 'c4 的第二层回复'),
      replyCount: 1,
    ),
  ],
  'c4_r1_r1_r1': [
    SubjectCommentModel(
      id: 'c4_r1_r1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u5'),
      content: 'c4 的第四层回复',
      createdAtMs: 1737527830000,
      replyTo: const ReplyTarget(commentId: 'c4_r1_r1_r1', authorName: '用户D', contentPreview: 'c4 的第三层回复'),
      replyCount: 1,
    ),
  ],
  'c4_r1_r1_r1_r1': [
    SubjectCommentModel(
      id: 'c4_r1_r1_r1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u6'),
      content: 'c4 的第五层回复（完结）',
      createdAtMs: 1737527840000,
      replyTo: const ReplyTarget(commentId: 'c4_r1_r1_r1_r1', authorName: '用户E', contentPreview: 'c4 的第四层回复'),
    ),
  ],
  // c5 的回复链
  'c5': [
    SubjectCommentModel(
      id: 'c5_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('owner'),
      content: 'c5 的第一层回复',
      createdAtMs: 1737527850000,
      replyTo: const ReplyTarget(commentId: 'c5', authorName: '用户C', contentPreview: '这是第二个 5 层嵌套评论的起点 (c5)'),
      replyCount: 1,
    ),
  ],
  'c5_r1': [
    SubjectCommentModel(
      id: 'c5_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u1'),
      content: 'c5 的第二层回复',
      createdAtMs: 1737527860000,
      replyTo: const ReplyTarget(commentId: 'c5_r1', authorName: '剧集主', contentPreview: 'c5 的第一层回复'),
      replyCount: 1,
    ),
  ],
  'c5_r1_r1': [
    SubjectCommentModel(
      id: 'c5_r1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u2'),
      content: 'c5 的第三层回复',
      createdAtMs: 1737527870000,
      replyTo: const ReplyTarget(commentId: 'c5_r1_r1', authorName: '用户A', contentPreview: 'c5 的第二层回复'),
      replyCount: 1,
    ),
  ],
  'c5_r1_r1_r1': [
    SubjectCommentModel(
      id: 'c5_r1_r1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u3'),
      content: 'c5 的第四层回复',
      createdAtMs: 1737527880000,
      replyTo: const ReplyTarget(commentId: 'c5_r1_r1_r1', authorName: '用户B', contentPreview: 'c5 的第三层回复'),
      replyCount: 1,
    ),
  ],
  'c5_r1_r1_r1_r1': [
    SubjectCommentModel(
      id: 'c5_r1_r1_r1_r1_r1',
      postId: 'post_1',
      subjectId: 'test',
      author: _getAuthor('u4'),
      content: 'c5 的第五层回复（完结）',
      createdAtMs: 1737527890000,
      replyTo: const ReplyTarget(commentId: 'c5_r1_r1_r1_r1', authorName: '用户C', contentPreview: 'c5 的第四层回复'),
    ),
  ],
  // tb30_c1 的 5 层回复链
  'tb30_c1': [
    SubjectCommentModel(
      id: 'tb30_c1_r1',
      postId: 'ep_30',
      subjectId: 'three_body',
      author: _getAuthor('u2'),
      content: '真的是技术奇迹，那段特效烧了不少钱吧？',
      createdAtMs: 1737547210000,
      replyTo: const ReplyTarget(commentId: 'tb30_c1', authorName: '用户A', contentPreview: '大结局太震撼了！...'),
      replyCount: 1,
    ),
  ],
  'tb30_c1_r1': [
    SubjectCommentModel(
      id: 'tb30_c1_r1_r1',
      postId: 'ep_30',
      subjectId: 'three_body',
      author: _getAuthor('u3'),
      content: '绝对是国产科幻新标杆',
      createdAtMs: 1737547220000,
      replyTo: const ReplyTarget(commentId: 'tb30_c1_r1', authorName: '用户B', contentPreview: '真的是技术奇迹...'),
      replyCount: 1,
    ),
  ],
  'tb30_c1_r1_r1': [
    SubjectCommentModel(
      id: 'tb30_c1_r1_r1_r1',
      postId: 'ep_30',
      subjectId: 'three_body',
      author: _getAuthor('u4'),
      content: '希望第二部也能保持这个水准',
      createdAtMs: 1737547230000,
      replyTo: const ReplyTarget(commentId: 'tb30_c1_r1_r1', authorName: '用户C', contentPreview: '绝对是国产科幻新标杆'),
      replyCount: 1,
    ),
  ],
  'tb30_c1_r1_r1_r1': [
    SubjectCommentModel(
      id: 'tb30_c1_r1_r1_r1_r1',
      postId: 'ep_30',
      subjectId: 'three_body',
      author: _getAuthor('u5'),
      content: '罗辑什么时候上线啊？',
      createdAtMs: 1737547240000,
      replyTo: const ReplyTarget(commentId: 'tb30_c1_r1_r1_r1', authorName: '用户D', contentPreview: '希望第二部也能保持...'),
      replyCount: 1,
    ),
  ],
  'tb30_c1_r1_r1_r1_r1': [
    SubjectCommentModel(
      id: 'tb30_c1_r1_r1_r1_r1_r1',
      postId: 'ep_30',
      subjectId: 'three_body',
      author: _getAuthor('u6'),
      content: '黑暗森林见！',
      createdAtMs: 1737547250000,
      replyTo: const ReplyTarget(commentId: 'tb30_c1_r1_r1_r1_r1', authorName: '用户E', contentPreview: '罗辑什么时候上线啊？'),
    ),
  ],
  // tb30_c2 的回复
  'tb30_c2': [
    SubjectCommentModel(
      id: 'tb30_c2_r1',
      postId: 'ep_30',
      subjectId: 'three_body',
      author: _getAuthor('u1'),
      content: '期待第二部！',
      createdAtMs: 1737547510000,
      replyTo: const ReplyTarget(commentId: 'tb30_c2', authorName: '三体官方', contentPreview: '感谢大家陪我们...'),
    ),
  ],
  // tb29_c1 的 5 层回复链
  'tb29_c1': [
    SubjectCommentModel(
      id: 'tb29_c1_r1',
      postId: 'ep_29',
      subjectId: 'three_body',
      author: _getAuthor('u3'),
      content: '大史真的浑身是戏',
      createdAtMs: 1737460810000,
      replyTo: const ReplyTarget(commentId: 'tb29_c1', authorName: '用户B', contentPreview: '史强果然是剧里的灵魂人物...'),
      replyCount: 1,
    ),
  ],
  'tb29_c1_r1': [
    SubjectCommentModel(
      id: 'tb29_c1_r1_r1',
      postId: 'ep_29',
      subjectId: 'three_body',
      author: _getAuthor('u4'),
      content: '于和伟老师演得太好了',
      createdAtMs: 1737460820000,
      replyTo: const ReplyTarget(commentId: 'tb29_c1_r1', authorName: '用户C', contentPreview: '大史真的浑身是戏'),
      replyCount: 1,
    ),
  ],
  'tb29_c1_r1_r1': [
    SubjectCommentModel(
      id: 'tb29_c1_r1_r1_r1',
      postId: 'ep_29',
      subjectId: 'three_body',
      author: _getAuthor('u5'),
      content: '这就是我心目中的史强',
      createdAtMs: 1737460830000,
      replyTo: const ReplyTarget(commentId: 'tb29_c1_r1_r1', authorName: '用户D', contentPreview: '于和伟老师演得太好了'),
      replyCount: 1,
    ),
  ],
  'tb29_c1_r1_r1_r1': [
    SubjectCommentModel(
      id: 'tb29_c1_r1_r1_r1_r1',
      postId: 'ep_29',
      subjectId: 'three_body',
      author: _getAuthor('u6'),
      content: '粗中有细，大智若愚',
      createdAtMs: 1737460840000,
      replyTo: const ReplyTarget(commentId: 'tb29_c1_r1_r1_r1', authorName: '用户E', contentPreview: '这就是我心目中的史强'),
      replyCount: 1,
    ),
  ],
  'tb29_c1_r1_r1_r1_r1': [
    SubjectCommentModel(
      id: 'tb29_c1_r1_r1_r1_r1_r1',
      postId: 'ep_29',
      subjectId: 'three_body',
      author: _getAuthor('u1'),
      content: '绝了，绝了',
      createdAtMs: 1737460850000,
      replyTo: const ReplyTarget(commentId: 'tb29_c1_r1_r1_r1_r1', authorName: '用户F', contentPreview: '粗中有细，大智若愚'),
    ),
  ],
  // bb_c1 的 5 层回复链
  'bb_c1': [
    SubjectCommentModel(
      id: 'bb_c1_r1',
      postId: 'bb_discussion_1',
      subjectId: 'breaking_bad_fans',
      author: _getAuthor('u5'),
      content: '那一集看完我整个人都傻了',
      createdAtMs: 1737444610000,
      replyTo: const ReplyTarget(commentId: 'bb_c1', authorName: '用户D', contentPreview: 'Ozymandias 真的是美剧史上的巅峰...'),
      replyCount: 1,
    ),
  ],
  'bb_c1_r1': [
    SubjectCommentModel(
      id: 'bb_c1_r1_r1',
      postId: 'bb_discussion_1',
      subjectId: 'breaking_bad_fans',
      author: _getAuthor('u6'),
      content: 'IMDb 10.0 分不是吹的',
      createdAtMs: 1737444620000,
      replyTo: const ReplyTarget(commentId: 'bb_c1_r1', authorName: '用户E', contentPreview: '那一集看完我整个人都傻了'),
      replyCount: 1,
    ),
  ],
  'bb_c1_r1_r1': [
    SubjectCommentModel(
      id: 'bb_c1_r1_r1_r1',
      postId: 'bb_discussion_1',
      subjectId: 'breaking_bad_fans',
      author: _getAuthor('u1'),
      content: '老白最后的眼神太复杂了',
      createdAtMs: 1737444630000,
      replyTo: const ReplyTarget(commentId: 'bb_c1_r1_r1', authorName: '用户F', contentPreview: 'IMDb 10.0 分不是吹的'),
      replyCount: 1,
    ),
  ],
  'bb_c1_r1_r1_r1': [
    SubjectCommentModel(
      id: 'bb_c1_r1_r1_r1_r1',
      postId: 'bb_discussion_1',
      subjectId: 'breaking_bad_fans',
      author: _getAuthor('u2'),
      content: '这一集的剪辑和配乐也是顶级',
      createdAtMs: 1737444640000,
      replyTo: const ReplyTarget(commentId: 'bb_c1_r1_r1_r1', authorName: '用户A', contentPreview: '老白最后的眼神太复杂了'),
      replyCount: 1,
    ),
  ],
  'bb_c1_r1_r1_r1_r1': [
    SubjectCommentModel(
      id: 'bb_c1_r1_r1_r1_r1_r1',
      postId: 'bb_discussion_1',
      subjectId: 'breaking_bad_fans',
      author: _getAuthor('u3'),
      content: '神作不解释',
      createdAtMs: 1737444650000,
      replyTo: const ReplyTarget(commentId: 'bb_c1_r1_r1_r1_r1', authorName: '用户B', contentPreview: '这一集的剪辑和配乐也是顶级'),
    ),
  ],
};
