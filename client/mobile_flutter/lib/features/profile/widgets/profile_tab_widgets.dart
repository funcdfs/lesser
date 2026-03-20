import 'dart:math';
import 'package:flutter/material.dart';
import '../../../pkg/ui/theme/theme.dart';
import 'package:intl/intl.dart';

// ------------------------
// Mock Data
// ------------------------

class MoviePoster {

  const MoviePoster({
    required this.id,
    required this.title,
    required this.type,
    required this.rating,
    required this.cover,
  });
  final int id;
  final String title;
  final String type;
  final double rating;
  final String cover;
}

const String _picsum = 'https://picsum.photos/seed';

const List<MoviePoster> moviePosters = [
  MoviePoster(id: 1, title: '沙丘2', type: '电影', rating: 9.2, cover: '$_picsum/dune2/300/400'),
  MoviePoster(id: 2, title: '三体', type: '电视剧', rating: 8.8, cover: '$_picsum/3body/300/400'),
  MoviePoster(id: 3, title: '葬送的芙莉莲', type: '动漫', rating: 9.6, cover: '$_picsum/frieren/300/400'),
  MoviePoster(id: 4, title: '漫长的季节', type: '电视剧', rating: 9.4, cover: '$_picsum/season/300/400'),
  MoviePoster(id: 6, title: '百年孤独', type: '图书', rating: 9.5, cover: '$_picsum/book/300/400'),
];

class Playlist {

  const Playlist({
    required this.id,
    required this.title,
    required this.count,
    required this.seeds,
  });
  final int id;
  final String title;
  final int count;
  final List<String> seeds;
}

const List<Playlist> playlists = [
  Playlist(id: 1, title: '年度十佳科幻视效大片', count: 10, seeds: ['sf1', 'sf2', 'sf3', 'sf4']),
  Playlist(id: 2, title: '治愈系高分日剧推荐', count: 15, seeds: ['jp1', 'jp2', 'jp3', 'jp4']),
  Playlist(id: 3, title: '周末一口气刷完的悬疑剧', count: 8, seeds: ['mys1', 'mys2', 'mys3', 'mys4']),
  Playlist(id: 4, title: '吉卜力工作室全集', count: 24, seeds: ['ghb1', 'ghb2', 'ghb3', 'ghb4']),
];

class Review {

  const Review({
    required this.id,
    required this.movie,
    required this.year,
    required this.type,
    required this.cover,
    required this.rating,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.time,
  });
  final int id;
  final String movie;
  final String year;
  final String type;
  final String cover;
  final int rating;
  final String title;
  final String content;
  final int likes;
  final int comments;
  final int reposts;
  final String time;
}

const List<Review> reviews = [
  Review(
    id: 1,
    movie: '沙丘2 Dune: Part Two',
    year: '2024',
    type: '电影',
    cover: '$_picsum/dune2/100/140',
    rating: 5,
    title: '极致的太空歌剧，视听语言的狂欢',
    content: '维伦纽瓦再次证明了他对庞大科幻架构的驾驭能力。从厄拉科斯的漫天黄沙到哈克南母星的黑白死寂，每一帧都可以作为壁纸。汉斯·季默的配乐更是直击灵魂...',
    likes: 342,
    comments: 56,
    reposts: 12,
    time: '2小时前',
  ),
  Review(
    id: 2,
    movie: '漫长的季节',
    year: '2023',
    type: '电视剧',
    cover: '$_picsum/season/100/140',
    rating: 5,
    title: '打响指吧，吹口哨吧',
    content: '这不仅仅是一部悬疑剧，更是一首时代的挽歌。范伟、秦昊、陈明昊的演技令人叹服，东北下岗潮的时代背景下，小人物的命运交响曲让人唏嘘不已。往前看，别回头。',
    likes: 1205,
    comments: 142,
    reposts: 89,
    time: '昨天',
  ),
];

// ------------------------
// Widgets
// ------------------------

class ProfileReviewCard extends StatelessWidget {

  const ProfileReviewCard({super.key, required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? colors.surfaceElevated 
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1740252117027-4275d3f84385?w=100'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '影迷小张',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      review.time,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < review.rating ? Colors.amber : colors.divider,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Text(
            review.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review.content,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Movie Reference (Quote Block Style)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colors.surfaceBase
                  : const Color(0xFFF8FAFC),
              border: Border(
                left: BorderSide(
                  color: colors.accent.withValues(alpha: 0.8),
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    review.cover,
                    width: 32,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.movie,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${review.year} · ${review.type}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Bar
          const Divider(height: 1),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionItem(icon: Icons.thumb_up_outlined, count: review.likes),
                _ActionItem(icon: Icons.chat_bubble_outline_rounded, count: review.comments),
                _ActionItem(icon: Icons.repeat_rounded, count: review.reposts),
                Icon(
                  Icons.share_outlined,
                  size: 18,
                  color: colors.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {

  const _ActionItem({required this.icon, required this.count});
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colors.textSecondary.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class ProfileMediaGrid extends StatelessWidget {
  const ProfileMediaGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
      ),
      itemCount: moviePosters.length,
      itemBuilder: (context, index) {
        final movie = moviePosters[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        movie.cover,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 10, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            movie.rating.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              movie.type,
              style: TextStyle(
                fontSize: 10,
                color: colors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProfilePlaylistGrid extends StatelessWidget {
  const ProfilePlaylistGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 28,
        childAspectRatio: 0.75,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4-Quadrant Cover
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GridView.count(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                        children: List.generate(4, (i) {
                          return Image.network(
                            '$_picsum/${playlist.seeds[i]}/200/200',
                            fit: BoxFit.cover,
                          );
                        }),
                      ),
                    ),
                  ),
                  // Play Button Overlay
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Info
            Text(
              playlist.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.bookmark_outline_rounded,
                  size: 12,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${playlist.count} 部作品',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ------------------------
// Activity Heatmap Implementation (1:1 with TSX)
// ------------------------

class Activity {

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.time,
  });
  final String id;
  final String type; // 'review', 'rate', 'list'
  final String title;
  final String time;
}

class DayData {

  const DayData({
    required this.date,
    required this.count,
    required this.activities,
  });
  final DateTime date;
  final int count;
  final List<Activity> activities;
}

class ProfileActivityHeatmap extends StatefulWidget {
  const ProfileActivityHeatmap({super.key});

  @override
  State<ProfileActivityHeatmap> createState() => _ProfileActivityHeatmapState();
}

class _ProfileActivityHeatmapState extends State<ProfileActivityHeatmap> {
  late List<DayData> _data;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _data = _generateMockData();
    _selectedDate = _data.last.date;
  }

  List<DayData> _generateMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = <DayData>[];

    for (int i = 104; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final count = Random().nextInt(5);
      final activities = <Activity>[];

      if (count > 0) {
        final types = ['review', 'rate', 'list'];
        final titles = ['肖申克的救赎', '霸王别姬', '阿甘正传', '流浪地球2', '星际穿越', '沙丘2'];
        for (int j = 0; j < count; j++) {
          activities.add(Activity(
            id: '${date.year}-${date.month}-${date.day}-$j',
            type: types[Random().nextInt(types.length)],
            title: titles[Random().nextInt(titles.length)],
            time: "${Random().nextInt(24).toString().padLeft(2, '0')}:${Random().nextInt(60).toString().padLeft(2, '0')}",
          ));
        }
      }
      activities.sort((a, b) => a.time.compareTo(b.time));
      days.add(DayData(date: date, count: count, activities: activities));
    }
    return days;
  }

  Color _getColor(int count, AppColorScheme colors) {
    if (count == 0) return Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9);
    if (count == 1) return const Color(0xFFBBF7D0);
    if (count == 2) return const Color(0xFF4ADE80);
    if (count == 3) return const Color(0xFF16A34A);
    return const Color(0xFF166534);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final selectedData = _data.firstWhere((d) => _isSameDay(d.date, _selectedDate));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(
                        '我的最近活动',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '过去 105 天',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Heatmap Graph
              SizedBox(
                height: 140,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // Days labels (Simpler in Flutter than TSX grid)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _labelCell('Mon'),
                          _labelCell('Wed'),
                          _labelCell('Fri'),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // The Grid (constructed column by column)
                      Row(
                        children: List.generate(15, (weekIdx) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Column(
                              children: List.generate(7, (dayIdx) {
                                final totalIdx = weekIdx * 7 + dayIdx;
                                if (totalIdx >= _data.length) return const SizedBox(width: 14, height: 14);
                                final day = _data[totalIdx];
                                final isSelected = _isSameDay(day.date, _selectedDate);
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedDate = day.date),
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: _getColor(day.count, colors),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                        color: isSelected ? Colors.indigo : Colors.black.withValues(alpha: 0.05),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('少', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                  const SizedBox(width: 8),
                  ...[0, 1, 2, 3, 4].map((c) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: _getColor(c, colors),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text('多', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        // Selected Day Detail
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.divider.withValues(alpha: 0.3))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(_selectedDate)} 活动记录",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${selectedData.count} 项',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (selectedData.count == 0) 
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(Icons.access_time_rounded, size: 32, color: colors.textDisabled.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text('今日休息，没有观影活动', style: TextStyle(fontSize: 14, color: colors.textDisabled)),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              else 
                Column(
                  children: List.generate(selectedData.activities.length, (i) {
                    final act = selectedData.activities[i];
                    return _ActivityTimelineItem(
                      activity: act,
                      isLast: i == selectedData.activities.length - 1,
                    );
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labelCell(String label) {
    return SizedBox(
      height: 14,
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}

class _ActivityTimelineItem extends StatelessWidget {

  const _ActivityTimelineItem({required this.activity, required this.isLast});
  final Activity activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Color typeColor;
    String typeText;
    IconData typeIcon;
    switch (activity.type) {
      case 'review':
        typeColor = Colors.blue;
        typeText = '发布影评';
        typeIcon = Icons.chat_bubble_outline_rounded;
        break;
      case 'rate':
        typeColor = Colors.amber;
        typeText = '评价电影';
        typeIcon = Icons.star_outline_rounded;
        break;
      default:
        typeColor = Colors.purple;
        typeText = '更新片单';
        typeIcon = Icons.access_time_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline logic
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: colors.divider.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? colors.surfaceElevated 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.divider.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surfaceBase,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            activity.time,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: typeColor.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            typeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(typeIcon, size: 16, color: typeColor),
                        const SizedBox(width: 8),
                        Text(
                          '《${activity.title}》',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
