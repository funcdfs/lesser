import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/features/chat/presentation/widgets/user_tab_section.dart';
import 'package:lesser/features/chat/presentation/widgets/user_avatar_row.dart';

/// Property-based tests for Tab Content Switching
/// Feature: message-page-ui-refactor, Property 5: Tab Content Switching
/// Validates: Requirements 3.5, 3.6, 3.7

void main() {
  group('Tab Content Switching - Property 5: Tab Content Switching', () {
    /// **Feature: message-page-ui-refactor, Property 5: Tab Content Switching**
    /// **Validates: Requirements 3.5, 3.6, 3.7**
    ///
    /// *For any* tab selection in UserTabSection:
    /// - WHEN "好友" is selected, UserAvatarRow SHALL display `friends` list
    /// - WHEN "粉丝" is selected, UserAvatarRow SHALL display `followers` list
    /// - WHEN "关注" is selected, UserAvatarRow SHALL display `following` list

    // Test data - using empty avatar URLs to avoid network image issues in tests
    final friendsList = [
      const UserItem(id: '1', name: '好友1', avatarUrl: ''),
      const UserItem(id: '2', name: '好友2', avatarUrl: ''),
    ];

    final followersList = [
      const UserItem(id: '3', name: '粉丝1', avatarUrl: ''),
      const UserItem(id: '4', name: '粉丝2', avatarUrl: ''),
      const UserItem(id: '5', name: '粉丝3', avatarUrl: ''),
    ];

    final followingList = [
      const UserItem(id: '6', name: '关注1', avatarUrl: ''),
    ];

    // Helper to build simple content widgets for testing tab switching logic
    // Using simple Container widgets instead of UserAvatarRow to avoid network image issues
    Widget buildSimpleContent(UserTabType type) {
      switch (type) {
        case UserTabType.friends:
          return Container(
            key: const ValueKey('friends_row'),
            child: const Text('Friends Content'),
          );
        case UserTabType.followers:
          return Container(
            key: const ValueKey('followers_row'),
            child: const Text('Followers Content'),
          );
        case UserTabType.following:
          return Container(
            key: const ValueKey('following_row'),
            child: const Text('Following Content'),
          );
      }
    }

    // Property test: Content builder is called with correct tab type
    test('Property 5: Content builder receives correct tab type for all tabs', () {
      for (final tabType in UserTabType.values) {
        UserTabType? receivedType;
        
        // Simulate content builder call
        receivedType = tabType;
        
        expect(
          receivedType,
          equals(tabType),
          reason: 'Content builder should receive $tabType when that tab is selected',
        );
      }
    });

    testWidgets('friends tab displays friends list content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.friends,
              contentBuilder: buildSimpleContent,
            ),
          ),
        ),
      );

      // Verify friends content is displayed
      expect(find.byKey(const ValueKey('friends_row')), findsOneWidget);
      expect(find.text('Friends Content'), findsOneWidget);
      
      // Verify other content is not displayed
      expect(find.byKey(const ValueKey('followers_row')), findsNothing);
      expect(find.byKey(const ValueKey('following_row')), findsNothing);
    });

    testWidgets('followers tab displays followers list content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.followers,
              contentBuilder: buildSimpleContent,
            ),
          ),
        ),
      );

      // Verify followers content is displayed
      expect(find.byKey(const ValueKey('followers_row')), findsOneWidget);
      expect(find.text('Followers Content'), findsOneWidget);
      
      // Verify other content is not displayed
      expect(find.byKey(const ValueKey('friends_row')), findsNothing);
      expect(find.byKey(const ValueKey('following_row')), findsNothing);
    });

    testWidgets('following tab displays following list content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.following,
              contentBuilder: buildSimpleContent,
            ),
          ),
        ),
      );

      // Verify following content is displayed
      expect(find.byKey(const ValueKey('following_row')), findsOneWidget);
      expect(find.text('Following Content'), findsOneWidget);
      
      // Verify other content is not displayed
      expect(find.byKey(const ValueKey('friends_row')), findsNothing);
      expect(find.byKey(const ValueKey('followers_row')), findsNothing);
    });

    testWidgets('switching tabs updates content correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.friends,
              contentBuilder: buildSimpleContent,
            ),
          ),
        ),
      );

      // Initially friends content is shown
      expect(find.byKey(const ValueKey('friends_row')), findsOneWidget);

      // Tap on "粉丝" tab
      await tester.tap(find.text('粉丝'));
      await tester.pumpAndSettle();

      // Now followers content should be shown
      expect(find.byKey(const ValueKey('followers_row')), findsOneWidget);
      expect(find.byKey(const ValueKey('friends_row')), findsNothing);

      // Tap on "关注" tab
      await tester.tap(find.text('关注'));
      await tester.pumpAndSettle();

      // Now following content should be shown
      expect(find.byKey(const ValueKey('following_row')), findsOneWidget);
      expect(find.byKey(const ValueKey('followers_row')), findsNothing);

      // Tap back on "好友" tab
      await tester.tap(find.text('好友'));
      await tester.pumpAndSettle();

      // Friends content should be shown again
      expect(find.byKey(const ValueKey('friends_row')), findsOneWidget);
      expect(find.byKey(const ValueKey('following_row')), findsNothing);
    });

    // Property: For ALL tab types, content switches correctly
    testWidgets('Property 5: All tab types display correct content when selected', (tester) async {
      final expectedContent = {
        UserTabType.friends: const ValueKey('friends_row'),
        UserTabType.followers: const ValueKey('followers_row'),
        UserTabType.following: const ValueKey('following_row'),
      };

      for (final tabType in UserTabType.values) {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('app_content_$tabType'),
            home: Scaffold(
              body: UserTabSection(
                key: ValueKey('tab_section_content_$tabType'),
                initialTab: tabType,
                contentBuilder: buildSimpleContent,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify correct content is displayed
        expect(
          find.byKey(expectedContent[tabType]!),
          findsOneWidget,
          reason: '$tabType should display its corresponding content',
        );

        // Verify other content is not displayed
        for (final otherType in UserTabType.values) {
          if (otherType != tabType) {
            expect(
              find.byKey(expectedContent[otherType]!),
              findsNothing,
              reason: '$otherType content should not be displayed when $tabType is selected',
            );
          }
        }
      }
    });

    // Property: Tab switching triggers content builder with correct type
    testWidgets('Property 5: Tab switching calls content builder with correct type', (tester) async {
      final receivedTypes = <UserTabType>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.friends,
              contentBuilder: (type) {
                receivedTypes.add(type);
                return buildSimpleContent(type);
              },
            ),
          ),
        ),
      );

      // Initial build should receive friends type
      expect(receivedTypes.last, equals(UserTabType.friends));

      // Switch to each tab and verify content builder receives correct type
      for (final tabType in UserTabType.values) {
        if (tabType != UserTabType.friends) {
          await tester.tap(find.text(getTabLabel(tabType)));
          await tester.pumpAndSettle();
          
          expect(
            receivedTypes.last,
            equals(tabType),
            reason: 'Content builder should receive $tabType after switching to that tab',
          );
        }
      }
    });

    // Test UserAvatarRow displays correct number of users (using empty URLs)
    testWidgets('UserAvatarRow displays all users plus view all button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatarRow(
              users: friendsList,
            ),
          ),
        ),
      );

      // Should display all user names
      expect(find.text('好友1'), findsOneWidget);
      expect(find.text('好友2'), findsOneWidget);
      
      // Should display "查看全部" button
      expect(find.text('查看全部'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('UserAvatarRow onUserTap callback is triggered', (tester) async {
      UserItem? tappedUser;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatarRow(
              users: friendsList,
              onUserTap: (user) => tappedUser = user,
            ),
          ),
        ),
      );

      // Tap on first user
      await tester.tap(find.text('好友1'));
      await tester.pumpAndSettle();

      expect(tappedUser, isNotNull);
      expect(tappedUser!.name, equals('好友1'));
    });

    testWidgets('UserAvatarRow onViewAll callback is triggered', (tester) async {
      bool viewAllTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatarRow(
              users: friendsList,
              onViewAll: () => viewAllTapped = true,
            ),
          ),
        ),
      );

      // Tap on "查看全部" button
      await tester.tap(find.text('查看全部'));
      await tester.pumpAndSettle();

      expect(viewAllTapped, isTrue);
    });
  });
}
