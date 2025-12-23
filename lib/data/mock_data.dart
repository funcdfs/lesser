import '../models/post.dart';

// --- Users Data from HomeFeed.tsx ---
class User {
  final int id;
  final String name;
  final String username;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
  });
}

// Using a simple map for avatars for now as we don't have the DiceBear API setup in Flutter directly
// without a network call, but we can accept strings.
final List<User> mockFollowingUsers = [
  User(
    id: 1,
    name: 'Sarah Chen',
    username: '@sarahchen',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
  ),
  User(
    id: 2,
    name: 'Alex Rivera',
    username: '@alexrivera',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
  ),
  User(
    id: 3,
    name: 'Maya Patel',
    username: '@mayapatel',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maya',
  ),
  User(
    id: 4,
    name: 'David Kim',
    username: '@davidkim',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=David',
  ),
  User(
    id: 5,
    name: 'Emma Wilson',
    username: '@emmawilson',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emma',
  ),
  User(
    id: 6,
    name: 'James Anderson',
    username: '@jamesanderson',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=James',
  ),
  User(
    id: 7,
    name: 'Lisa Park',
    username: '@lisapark',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lisa',
  ),
  User(
    id: 8,
    name: 'Nina Rodriguez',
    username: '@ninarodriguez',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Nina',
  ),
];

// --- Posts Data from HomeFeed.tsx (Adapting to Post model) ---
final List<Post> mockPosts = [
  Post(
    id: '1',
    author: 'Sarah Chen',
    authorHandle: '@sarahchen',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
    content: '刚发布了我的新 React 设计系统！🎨 快来看看，告诉我你的想法。专为无障碍访问和高性能打造。',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    likesCount: 2345, // 2.3千
    commentsCount: 45,
    repostsCount: 12,
    bookmarksCount: 8,
    sharesCount: 3,
    title: '', // Not used in this view
    location: '上海, 中国',
    imageUrls: [
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&auto=format',
      'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&auto=format',
      'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&auto=format',
    ],
  ),
  Post(
    id: '2',
    author: 'Alex Rivera',
    authorHandle: '@alexrivera',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
    content:
        '暴论：最好的代码就是没有代码。简单 > 复杂，永远如此。\n\n我们在构建软件时，经常陷入"为了做而做"的陷阱。我们引入复杂的架构、分层、模式，却忘了软件的本质是解决问题。\n\n每一行你写的代码，都是未来的技术债务。它需要被阅读、被理解、被测试、被维护。\n\n保持简单 (KISS) 不仅仅是一个原则，它是一种生存策略。当你的系统变得过于复杂，没人能完全理解它时，你就失去了对它的控制。\n\n所以，在写下一行代码之前，问问自己：真的需要吗？有没有更简单的方法？能不能复用现有的东西？\n\n少即是多。LESS IS MORE.',
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    likesCount: 12500, // 1.3万
    commentsCount: 156,
    repostsCount: 78,
    bookmarksCount: 45,
    sharesCount: 12,
    title: '',
    location: 'San Francisco, CA',
    // Long text to test expandable text widget
  ),
  Post(
    id: '3',
    author: 'Maya Patel',
    authorHandle: '@mayapatel',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maya',
    content: '正在写一篇关于现代 Web 应用状态管理模式的新文章。大家有什么特别想看的话题吗？',
    timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    likesCount: 123456789, // 1.2亏
    commentsCount: 8900,
    repostsCount: 23,
    bookmarksCount: 156,
    sharesCount: 34,
    title: '',
    location: 'London, UK',
    imageUrls: [
      'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&auto=format',
    ],
  ),
  Post(
    id: '4',
    author: 'David Kim',
    authorHandle: '@davidkim',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=David',
    content: 'Web 开发的未来一片光明！WebAssembly、边缘计算和 AI 驱动的工具正在改变一切。',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    likesCount: 567,
    commentsCount: 92,
    repostsCount: 45,
    bookmarksCount: 23,
    sharesCount: 8,
    title: '',
    location: 'Seoul, Korea',
    imageUrls: [
      'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&auto=format',
      'https://images.unsplash.com/photo-1504639725590-34d0984388bd?w=800&auto=format',
      'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&auto=format',
      'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?w=800&auto=format',
      'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800&auto=format',
    ],
  ),
  Post(
    id: '5',
    author: 'Emma Wilson',
    authorHandle: '@emmawilson',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emma',
    content: '刘读完一篇很棒的 CSS Grid 文章。都 2025 年了我还在学新技巧！学无止境 📚',
    timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    likesCount: 312,
    commentsCount: 34,
    repostsCount: 18,
    bookmarksCount: 12,
    sharesCount: 5,
    title: '',
    location: 'Sydney, Australia',
  ),
  Post(
    id: '6',
    author: 'Lucas Garcia',
    authorHandle: '@lucas_g',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Lucas',
    content: '周末去爬山了，风景真不错！🏔️ 强烈推荐大家多出去走走，呀吸新鲜空气。',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    likesCount: 56,
    commentsCount: 8,
    repostsCount: 1,
    bookmarksCount: 2,
    sharesCount: 1,
    title: '',
    location: 'Yosemite, USA',
  ),
  Post(
    id: '7',
    author: 'Yuki Tanaka',
    authorHandle: '@yuki_dev',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Yuki',
    content:
        'Flutter 3.x is amazing! The performance improvements are noticeable. 🚀 #Flutter #MobileDev',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    likesCount: 1205, // 1.2k
    commentsCount: 230,
    repostsCount: 89,
    bookmarksCount: 67,
    sharesCount: 23,
    title: '',
    location: 'Tokyo, Japan',
  ),
  Post(
    id: '8',
    author: 'Oliver Smith',
    authorHandle: '@oli_smith',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Oliver',
    content:
        'Just tried the new coffee shop downtown. Their latte art is on point! ☕️',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    likesCount: 89,
    commentsCount: 12,
    repostsCount: 5,
    bookmarksCount: 3,
    sharesCount: 1,
    title: '',
    location: 'Seattle, WA',
  ),
  Post(
    id: '9',
    author: 'Zara Khan',
    authorHandle: '@zara_k',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Zara',
    content:
        'Thinking about switching from VS Code to Zed. Has anyone tried it extensively for Python development? 🤔',
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 10)),
    likesCount: 45,
    commentsCount: 34,
    repostsCount: 2,
    bookmarksCount: 5,
    sharesCount: 2,
    title: '',
    location: 'Berlin, Germany',
  ),
  Post(
    id: '10',
    author: 'Chen Wei',
    authorHandle: '@wei_chen',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chen',
    content: '今天尝试做了一下红烧肉，虽然卖相一般，但是味道还可以！📖 下次继续努力。',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    likesCount: 23,
    commentsCount: 4,
    repostsCount: 0,
    bookmarksCount: 1,
    sharesCount: 0,
    title: '',
    location: 'Beijing, China',
  ),
  Post(
    id: '11',
    author: 'Isabella Ross',
    authorHandle: '@bella_ross',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Isabella',
    content:
        'Designing a new logo for a client. Minimalist style is always challenging but rewarding. ✍️',
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
    likesCount: 678,
    commentsCount: 45,
    repostsCount: 12,
    bookmarksCount: 34,
    sharesCount: 8,
    title: '',
    location: 'Paris, France',
  ),
  Post(
    id: '12',
    author: 'Mohammed Al-Fayed',
    authorHandle: '@mo_fayed',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Mohammed',
    content: 'The sunset today was breathtaking. 🌅',
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
    likesCount: 89000, // 8.9万
    commentsCount: 1200,
    repostsCount: 5600,
    bookmarksCount: 234,
    sharesCount: 89,
    title: '',
    location: 'Cairo, Egypt',
  ),
  Post(
    id: '13',
    author: 'Sophia Nilsson',
    authorHandle: '@sophia_n',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia',
    content: 'Reading "The Pragmatic Programmer" again. It never gets old. 📚',
    timestamp: DateTime.now().subtract(const Duration(days: 6)),
    likesCount: 234,
    commentsCount: 23,
    repostsCount: 11,
    bookmarksCount: 45,
    sharesCount: 12,
    title: '',
    location: 'Stockholm, Sweden',
  ),
  Post(
    id: '14',
    author: 'Rajesh Kumar',
    authorHandle: '@raj_k',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rajesh',
    content:
        'AI is evolving so fast! It\'s hard to keep up with all the new papers coming out every week. 🤖',
    timestamp: DateTime.now().subtract(const Duration(days: 7)),
    likesCount: 567,
    commentsCount: 89,
    repostsCount: 34,
    bookmarksCount: 78,
    sharesCount: 23,
    title: '',
    location: 'Bangalore, India',
  ),
  Post(
    id: '15',
    author: 'Emily Davis',
    authorHandle: '@emily_d',
    authorAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emily2',
    content:
        'Does anyone have recommendations for good sci-fi movies on Netflix right now? 📽',
    timestamp: DateTime.now().subtract(const Duration(days: 9)),
    likesCount: 12,
    commentsCount: 45,
    repostsCount: 0,
    bookmarksCount: 8,
    sharesCount: 2,
    title: '',
    location: 'Toronto, Canada',
  ),
];

// --- Articles Data from ArticlesSection.tsx ---
class Article {
  final int id;
  final String title;
  final String excerpt;
  final String author;
  final String avatar;
  final String coverImage;
  final String readTime;
  final int likes;
  final int comments;
  final List<String> tags;
  final String category;
  final String publishedAt;

  Article({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.avatar,
    required this.coverImage,
    required this.readTime,
    required this.likes,
    required this.comments,
    required this.tags,
    required this.category,
    required this.publishedAt,
  });
}

final List<Map<String, String>> articleCategories = [
  {'id': 'daily', 'label': '日常生活'},
  {'id': 'family', 'label': '家庭'},
  {'id': 'food', 'label': '食物'},
  {'id': 'lifestyle', 'label': '生活方式'},
  {'id': 'shopping', 'label': '购物'},
  {'id': 'childcare', 'label': '儿童保育'},
  {'id': 'health', 'label': '健康'},
  {'id': 'travel', 'label': '旅行和郊游'},
  {'id': 'pets', 'label': '宠物'},
  {'id': 'columns', 'label': '专栏和文章'},
  {'id': 'beauty', 'label': '美容'},
  {'id': 'fashion', 'label': '时尚'},
  {'id': 'diy', 'label': 'DIY'},
  {'id': 'styling', 'label': '造形'},
  {'id': 'craft', 'label': '手芸'},
  {'id': 'outdoor', 'label': '户外的'},
  {'id': 'learning', 'label': '学习'},
  {'id': 'education', 'label': '教育'},
  {'id': 'reading', 'label': '阅读'},
  {'id': 'design', 'label': '设计'},
  {'id': 'humanities', 'label': '人文学'},
  {'id': 'science', 'label': '科学'},
  {'id': 'qualification', 'label': '资格'},
];

final List<Article> mockArticles = [
  Article(
    id: 1,
    title: '简单又健康的早餐食谱合集',
    excerpt: '每天早上不知道吃什么？这里有10个快速又营养的早餐食谱，让你精力充沛开始新的一天。',
    author: 'Sarah Chen',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
    coverImage:
        'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=800&auto=format',
    readTime: '5 min read',
    likes: 1256,
    comments: 89,
    tags: ['早餐', '食谱', '健康'],
    category: 'food',
    publishedAt: '2天前',
  ),
  Article(
    id: 2,
    title: '家居收纳技巧大公开',
    excerpt: '小户型也能井井有条！学习这些收纳技巧，让你的家变得更加整洁舒适。',
    author: 'Alex Rivera',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Alex',
    coverImage:
        'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&auto=format',
    readTime: '8 min read',
    likes: 2341,
    comments: 156,
    tags: ['收纳', '家居', '整理'],
    category: 'daily',
    publishedAt: '3天前',
  ),
  Article(
    id: 3,
    title: '亲子旅行目的地推荐',
    excerpt: '带孩子去哪里玩？为你推荐最适合家庭出游的旅行地点，让全家都能享受美好时光。',
    author: 'Maya Patel',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maya',
    coverImage:
        'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=800&auto=format',
    readTime: '10 min read',
    likes: 3456,
    comments: 234,
    tags: ['旅行', '亲子', '家庭'],
    category: 'travel',
    publishedAt: '5天前',
  ),
  Article(
    id: 4,
    title: '护肤步骤详解：从清洁到保养',
    excerpt: '正确的护肤步骤能让你的皮肤更健康。这篇文章详细讲解每个步骤的要点和产品推荐。',
    author: 'Emma Wilson',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Emma',
    coverImage:
        'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=800&auto=format',
    readTime: '7 min read',
    likes: 1890,
    comments: 145,
    tags: ['护肤', '美容', '保养'],
    category: 'beauty',
    publishedAt: '1周前',
  ),
  Article(
    id: 5,
    title: 'DIY手工：制作个性化笔记本',
    excerpt: '跟着步骤图，轻松制作属于自己的手工笔记本。送礼自用都很棒！',
    author: 'David Kim',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=David',
    coverImage:
        'https://images.unsplash.com/photo-1517842645767-c639042777db?w=800&auto=format',
    readTime: '12 min read',
    likes: 987,
    comments: 67,
    tags: ['DIY', '手工', '创意'],
    category: 'diy',
    publishedAt: '1周前',
  ),
];

// --- Stories Data ---
class Story {
  final String id;
  final String imageUrl;
  final String? videoUrl; // For future video support
  final DateTime timestamp;
  final bool isSeen;

  Story({
    required this.id,
    required this.imageUrl,
    this.videoUrl,
    required this.timestamp,
    this.isSeen = false,
  });
}

final Map<int, List<Story>> mockStories = {
  1: [
    // Sarah Chen
    Story(
      id: 's1-1',
      imageUrl:
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&auto=format',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Story(
      id: 's1-2',
      imageUrl:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&auto=format',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ],
  2: [
    // Alex Rivera
    Story(
      id: 's2-1',
      imageUrl:
          'https://images.unsplash.com/photo-1492633423870-43d1cd2775eb?w=800&auto=format',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ],
  3: [
    // Maya Patel
    Story(
      id: 's3-1',
      imageUrl:
          'https://images.unsplash.com/photo-1517404215738-15263e9f9178?w=800&auto=format',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ],
  4: [
    // David Kim
    Story(
      id: 's4-1',
      imageUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ],
};
