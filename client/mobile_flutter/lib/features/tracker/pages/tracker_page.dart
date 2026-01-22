import 'package:flutter/material.dart';
import '../widgets/tracker_calendar.dart';
import '../widgets/tracker_continue_watching.dart';

import '../widgets/tracker_saved_list.dart';
import '../widgets/tracker_section_header.dart';

class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Tracker'),
            floating: true,
          ),
          
          const TrackerCalendar(),

          const TrackerSectionHeader(title: "Start Watching"),
          const TrackerContinueWatching(),

          const TrackerSectionHeader(title: "Watchlist"),
          const TrackerSavedList(count: 10, labelPrefix: "Saved", baseColor: Colors.orange),
          


          // Add extra padding for bottom nav
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

