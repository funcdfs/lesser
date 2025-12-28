import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/pages/conversations_page.dart';
import '../../../feeds/presentation/pages/feeds_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../widgets/bottom_nav_bar.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FeedsPage(),
    SearchPage(),
    SizedBox(), // Placeholder for create post (handled differently)
    NotificationsPage(),
    ProfilePage(),
  ];

  void _onTabSelected(int index) {
    if (index == 2) {
      // Create post - navigate to create post page
      context.push(RouteConstants.createPost);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Load unread notification count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex >= 2 ? _currentIndex - 1 : _currentIndex,
        children: [
          _pages[0], // Feeds
          _pages[1], // Search
          _pages[3], // Notifications
          _pages[4], // Profile
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        notificationBadge: notificationState.unreadCount,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => context.push(RouteConstants.createPost),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
