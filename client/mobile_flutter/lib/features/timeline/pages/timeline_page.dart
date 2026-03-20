import 'package:flutter/material.dart';
import '../widgets/review_card.dart';

/// Timeline 页面 - 推荐流（影评社区）
///
/// 设计特点：
/// - 1:1 复刻 UIdemo 精致影评卡片
/// - 紫罗兰色调配色
/// - 电影海报作为卡片背景，渐变遮罩
/// - 精致的用户标签和评分展示
/// - 流畅的交互动画
class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF9FAFB),
            const Color(0xFFF3E8FF).withOpacity(0.3),
            const Color(0xFFFAF5FF).withOpacity(0.2),
          ],
        ),
      ),
      child: CustomScrollView(
        slivers: [

          // 影评列表
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ReviewCard(
                    data: _getMockData(index),
                    onExpand: () {
                      // TODO: 导航到详情页
                    },
                  ),
                );
              }, childCount: 20),
            ),
          ),

          // 底部留白（为底部导航栏预留空间）
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  /// 获取模拟数据
  ReviewCardData _getMockData(int index) {
    final mockReviews = [
      const ReviewCardData(
        id: '1',
        movieTitle: '银翼杀手2049',
        moviePoster:
            'https://images.unsplash.com/photo-1761502479994-3a5e07ec243e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjaW5lbWElMjBzY3JlZW4lMjBkYXJrJTIwdGhlYXRlcnxlbnwxfHx8fDE3NzM5MzA0NTV8MA&ixlib=rb-4.1.0&q=80&w=1080',
        movieRating: 8.5,
        userRating: 9.2,
        user: UserInfo(
          name: '电影迷小王',
          avatar:
              'https://images.unsplash.com/photo-1554765345-6ad6a5417cde?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYW4lMjBwb3J0cmFpdCUyMHByb2Zlc3Npb25hbHxlbnwxfHx8fDE3NzM5MDc3NzF8MA&ixlib=rb-4.1.0&q=80&w=1080',
          badges: ['VIP', '影评人'],
        ),
        publishTime: '2小时前',
        publishDate: '2026-03-19 14:30',
        reviewText:
            '这部电影是视觉艺术的巅峰之作。维伦纽瓦以其独特的导演手法，将迪克的经典科幻小说搬上银幕，呈现出一个令人窒息的未来世界。罗杰·迪金斯的摄影美得令人心碎，每一帧都可以作为壁纸。高斯林的表演克制而有力，完美诠释了一个在寻找自我认同的复制人。电影探讨了何为人性、何为记忆、何为真实的深刻哲学命题。配乐同样出色，汉斯·季默和本杰明·沃尔菲什创造的音景与画面完美融合。这不仅仅是一部续集，更是对原作的致检和超越。尽管节奏较慢，但每一个镜头都经过精心设计，值得反复观看和品味。',
        shareCount: 89,
        repostCount: 156,
      ),
      const ReviewCardData(
        id: '2',
        movieTitle: '沙丘',
        moviePoster:
            'https://images.unsplash.com/photo-1764258559704-0b7f0f02cae0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxuZW9uJTIwcHVycGxlJTIwbGlnaHRzJTIwY3liZXJwdW5rfGVufDF8fHx8MTc3MzkzMDQ1NXww&ixlib=rb-4.1.0&q=80&w=1080',
        movieRating: 7.9,
        userRating: 8.8,
        user: UserInfo(
          name: 'Sarah Chen',
          avatar:
              'https://images.unsplash.com/photo-1631885628966-a14af9faaa9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHByb2ZpbGUlMjBwb3J0cmFpdHxlbnwxfHx8fDE3NzM4NTY1NTR8MA&ixlib=rb-4.1.0&q=80&w=1080',
          badges: ['活跃'],
        ),
        publishTime: '5小时前',
        publishDate: '2026-03-19 11:30',
        reviewText:
            '维伦纽瓦终于将这部"不可能拍摄"的小说成功搬上大银幕。壮观的沙漠景观、宏大的世界观构建、精湛的视觉效果，每一个元素都堪称完美。提莫西·查拉梅展现了超越年龄的成熟演技，将保罗这个复杂角色演绎得入木三分。影片在保持原著精神的同时，也做出了适合电影的改编。汉斯·季默的配乐气势磅礴，为整部影片增添了史诗般的质感。虽然作为上部曲稍显未完成，但已经展现出了成为科幻经典的潜质。',
        shareCount: 43,
        repostCount: 72,
      ),
      const ReviewCardData(
        id: '3',
        movieTitle: '星际穿越',
        moviePoster:
            'https://images.unsplash.com/photo-1761701391167-863560b27f5e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx2aW50YWdlJTIwZmlsbSUyMGNhbWVyYSUyMGNpbmVtYXRpY3xlbnwxfHx8fDE3NzM5MzA0NTV8MA&ixlib=rb-4.1.0&q=80&w=1080',
        movieRating: 9.3,
        userRating: 9.5,
        user: UserInfo(
          name: '星空观察者',
          avatar:
              'https://images.unsplash.com/photo-1552888836-acc121da4b59?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwc21pbGUlMjBhc2lhbnxlbnwxfHx8fDE3NzM5MzA0NTJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
          badges: ['VIP', '影评人', '活跃'],
        ),
        publishTime: '1天前',
        publishDate: '2026-03-18 09:15',
        reviewText:
            '诺兰用这部作品证明了科幻电影可以既有硬核的科学理论，又有动人的情感内核。影片对时间膨胀、黑洞、五维空间等概念的视觉化呈现令人叹为观止。马修·麦康纳的表演细腻感人，尤其是观看孩子成长视频那场戏，催人泪下。IMAX的观影体验更是无与伦比，宇宙的浩瀚和人类的渺小形成强烈对比。汉斯·季默的管风琴配乐恢弘大气，完美烘托了影片的情感氛围。这是一部需要用心感受的电影，每次重看都能发现新的细节和感悟。诺兰将父女之爱与拯救人类的宏大叙事完美结合，创造出了一部永恒的科幻杰作。',
        shareCount: 234,
        repostCount: 389,
      ),
    ];

    return mockReviews[index % mockReviews.length];
  }
}
