import 'package:flutter/material.dart';

import '../widgets/tracker_heatmap.dart';
import '../widgets/tracker_stats_cards.dart';
import '../widgets/tracker_timeline.dart';
import '../widgets/tracker_playlists.dart';

class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('My Tracker'),
            floating: true,
            automaticallyImplyLeading: false,
          ),

          // 1. 想看 / 看过（立体书架效果）
          TrackerStatsCards(),

          // 2. 活跃度热力图
          TrackerHeatmap(),

          // 3. 播放列表
          TrackerPlaylists(),

          // 4. 最近活动（移至最末）
          TrackerTimeline(),

          // 底部导航栏预留间距
          SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
