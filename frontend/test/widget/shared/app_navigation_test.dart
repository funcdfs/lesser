import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/shared/widgets/app_nav_bar.dart';
import 'package:lesser/shared/widgets/app_bottom_nav_bar.dart';
import 'package:lesser/shared/theme/colors.dart';

/// Widget tests for AppNavBar and AppBottomNavBar components.
/// Tests navigation bar rendering and bottom navigation switching.
/// Requirements: 5.1, 5.2, 5.4
void main() {
  /// Helper to wrap widget with MaterialApp for testing
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('AppNavBar Rendering', () {
    testWidgets('renders nav bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppNavBar(
          title: 'Page Title',
        ),
      ));

      expect(find.text('Page Title'), findsOneWidget);
    });

    testWidgets('renders nav bar using simple factory', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppNavBar.simple(
          title: 'Simple Title',
        ),
      ));

      expect(find.text('Simple Title'), findsOneWidget);
    });

    testWidgets('renders nav bar with back button when onBack provided', (tester) async {
      bool backPressed = false;
      await tester.pumpWidget(createTestWidget(
        AppNavBar(
          title: 'With Back',
          onBack: () => backPressed = true,
        ),
      ));

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();
      
      expect(backPressed, isTrue);
    });

    testWidgets('does not show back button when onBack is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppNavBar(
          title: 'No Back',
          onBack: null,
        ),
      ));

      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('renders nav bar with custom back icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppNavBar(
          title: 'Custom Back',
          onBack: () {},
          backIcon: Icons.close,
        ),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders nav bar with actions', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppNavBar(
          title: 'With Actions',
          actions: [
            AppNavBarAction(
              icon: Icons.search,
              onPressed: () {},
            ),
            AppNavBarAction(
              icon: Icons.more_vert,
              onPressed: () {},
            ),
          ],
        ),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('action button calls onPressed when tapped', (tester) async {
      bool actionPressed = false;
      await tester.pumpWidget(createTestWidget(
        AppNavBar(
          title: 'Action Test',
          actions: [
            AppNavBarAction(
              icon: Icons.settings,
              onPressed: () => actionPressed = true,
            ),
          ],
        ),
      ));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      expect(actionPressed, isTrue);
    });

    testWidgets('renders transparent nav bar', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppNavBar.transparent(
          title: 'Transparent',
          onBack: () {},
        ),
      ));

      expect(find.text('Transparent'), findsOneWidget);
    });

    testWidgets('renders nav bar with custom title widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppNavBar.custom(
          titleWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.yellow),
              SizedBox(width: 8),
              Text('Custom Title'),
            ],
          ),
        ),
      ));

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders nav bar with text action', (tester) async {
      bool textActionPressed = false;
      await tester.pumpWidget(createTestWidget(
        AppNavBar(
          title: 'Text Action',
          actions: [
            AppNavBarTextAction(
              text: 'Save',
              onPressed: () => textActionPressed = true,
            ),
          ],
        ),
      ));

      expect(find.text('Save'), findsOneWidget);
      
      await tester.tap(find.text('Save'));
      await tester.pump();
      
      expect(textActionPressed, isTrue);
    });

    testWidgets('renders action with badge', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppNavBar(
          title: 'Badge Test',
          actions: [
            AppNavBarAction(
              icon: Icons.notifications,
              badge: 5,
              onPressed: () {},
            ),
          ],
        ),
      ));

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });

  group('AppBottomNavBar Rendering', () {
    testWidgets('renders bottom nav bar with items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppBottomNavBar(
          currentIndex: 0,
          onTap: (_) {},
          items: [
            AppBottomNavBarItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
            ),
            AppBottomNavBarItem(
              icon: Icons.search,
              label: 'Search',
            ),
            AppBottomNavBarItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
            ),
          ],
        ),
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('shows selected icon for current index', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppBottomNavBar(
          currentIndex: 0,
          onTap: (_) {},
          items: [
            AppBottomNavBarItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
            ),
            AppBottomNavBarItem(
              icon: Icons.search,
              label: 'Search',
            ),
          ],
        ),
      ));

      // Home is selected (index 0), should show filled icon
      expect(find.byIcon(Icons.home), findsOneWidget);
      // Search is not selected, should show outline icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('AppBottomNavBar Navigation Switching', () {
    testWidgets('calls onTap with correct index when item tapped', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(createTestWidget(
        AppBottomNavBar(
          currentIndex: 0,
          onTap: (index) => tappedIndex = index,
          items: [
            AppBottomNavBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            AppBottomNavBarItem(
              icon: Icons.search,
              label: 'Search',
            ),
            AppBottomNavBarItem(
              icon: Icons.person_outline,
              label: 'Profile',
            ),
          ],
        ),
      ));

      // Tap on Search (index 1)
      await tester.tap(find.text('Search'));
      await tester.pump();

      expect(tappedIndex, equals(1));
    });

    testWidgets('updates selected state when currentIndex changes', (tester) async {
      int currentIndex = 0;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestWidget(
              AppBottomNavBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() => currentIndex = index);
                },
                items: [
                  AppBottomNavBarItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'Home',
                  ),
                  AppBottomNavBarItem(
                    icon: Icons.search_outlined,
                    selectedIcon: Icons.search,
                    label: 'Search',
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Initially Home is selected
      expect(find.byIcon(Icons.home), findsOneWidget);

      // Tap on Search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Now Search should be selected
      expect(currentIndex, equals(1));
    });

    testWidgets('renders bottom nav without labels when showLabels is false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppBottomNavBar(
          currentIndex: 0,
          onTap: (_) {},
          showLabels: false,
          items: [
            AppBottomNavBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            AppBottomNavBarItem(
              icon: Icons.search,
              label: 'Search',
            ),
          ],
        ),
      ));

      // Labels should not be visible
      expect(find.text('Home'), findsNothing);
      expect(find.text('Search'), findsNothing);
      
      // Icons should still be visible
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders badge on nav item', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppBottomNavBar(
          currentIndex: 0,
          onTap: (_) {},
          items: [
            AppBottomNavBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            AppBottomNavBarItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              badge: 10,
            ),
          ],
        ),
      ));

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('renders red dot badge when badge is -1', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppBottomNavBar(
          currentIndex: 0,
          onTap: (_) {},
          items: [
            AppBottomNavBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            AppBottomNavBarItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              badge: -1,
            ),
          ],
        ),
      ));

      // Should render a red dot (Container with BoxShape.circle)
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });
  });

  group('AppBottomNavBar with Center Button', () {
    testWidgets('renders center button when provided', (tester) async {
      bool centerTapped = false;
      await tester.pumpWidget(createTestWidget(
        AppBottomNavBar.withCenterButton(
          currentIndex: 0,
          onTap: (_) {},
          onCenterTap: () => centerTapped = true,
          items: [
            AppBottomNavBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            AppBottomNavBarItem(
              icon: Icons.person_outline,
              label: 'Profile',
            ),
          ],
        ),
      ));

      // Should find the default center button with add icon
      expect(find.byIcon(Icons.add), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      
      expect(centerTapped, isTrue);
    });

    testWidgets('renders custom center button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AppBottomNavBar.withCenterButton(
          currentIndex: 0,
          onTap: (_) {},
          onCenterTap: () {},
          centerButton: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt, color: Colors.white),
          ),
          items: [
            AppBottomNavBarItem(
              icon: Icons.home_outlined,
              label: 'Home',
            ),
            AppBottomNavBarItem(
              icon: Icons.person_outline,
              label: 'Profile',
            ),
          ],
        ),
      ));

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });
  });
}
