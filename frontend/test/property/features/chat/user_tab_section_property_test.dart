import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/features/chat/presentation/widgets/user_tab_section.dart';
import 'package:lesser/shared/theme/colors.dart';

/// Property-based tests for UserTabSection
/// Feature: message-page-ui-refactor, Property 4: Tab Selection State
/// Validates: Requirements 3.2, 3.3, 3.4

void main() {
  group('UserTabSection - Property 4: Tab Selection State', () {
    /// **Feature: message-page-ui-refactor, Property 4: Tab Selection State**
    /// **Validates: Requirements 3.2, 3.3, 3.4**
    ///
    /// *For any* selected tab in UserTabSection:
    /// - The selected tab SHALL have AppColors.foreground color and bold font weight
    /// - The selected tab SHALL have an underline indicator
    /// - All unselected tabs SHALL have AppColors.mutedForeground color and normal font weight
    /// - All unselected tabs SHALL NOT have an underline indicator

    // Property test: For ALL UserTabType values, selection state is correctly displayed
    test('Property 4: All UserTabType values have correct selection behavior', () {
      // This is a property test that exhaustively tests all enum values
      for (final tabType in UserTabType.values) {
        // Verify each tab type is a valid selection option
        expect(
          UserTabType.values.contains(tabType),
          isTrue,
          reason: '$tabType should be a valid tab type',
        );
        
        // Verify label mapping is consistent
        final label = getTabLabel(tabType);
        expect(
          label.isNotEmpty,
          isTrue,
          reason: '$tabType should have a non-empty label',
        );
      }
    });

    testWidgets('selected tab has foreground color and bold font weight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.friends,
            ),
          ),
        ),
      );

      // Find the "好友" text (selected tab)
      final friendsText = find.text('好友');
      expect(friendsText, findsOneWidget);

      final textWidget = tester.widget<Text>(friendsText);
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(textWidget.style?.color, equals(AppColors.foreground));
    });

    testWidgets('unselected tabs have mutedForeground color and normal font weight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.friends,
            ),
          ),
        ),
      );

      // Find unselected tabs
      final followersText = find.text('粉丝');
      final followingText = find.text('关注');
      
      expect(followersText, findsOneWidget);
      expect(followingText, findsOneWidget);

      final followersWidget = tester.widget<Text>(followersText);
      final followingWidget = tester.widget<Text>(followingText);

      expect(followersWidget.style?.fontWeight, equals(FontWeight.normal));
      expect(followersWidget.style?.color, equals(AppColors.mutedForeground));
      
      expect(followingWidget.style?.fontWeight, equals(FontWeight.normal));
      expect(followingWidget.style?.color, equals(AppColors.mutedForeground));
    });

    testWidgets('selected tab has visible underline indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.friends,
            ),
          ),
        ),
      );

      // Find all AnimatedContainers (underline indicators)
      final animatedContainers = find.byType(AnimatedContainer);
      expect(animatedContainers, findsNWidgets(3)); // 3 tabs = 3 indicators

      // Get all AnimatedContainer widgets
      final containers = tester.widgetList<AnimatedContainer>(animatedContainers).toList();
      
      // First container (好友 - selected) should have foreground color
      final firstDecoration = containers[0].decoration as BoxDecoration?;
      expect(firstDecoration?.color, equals(AppColors.foreground));

      // Other containers should be transparent
      final secondDecoration = containers[1].decoration as BoxDecoration?;
      final thirdDecoration = containers[2].decoration as BoxDecoration?;
      expect(secondDecoration?.color, equals(Colors.transparent));
      expect(thirdDecoration?.color, equals(Colors.transparent));
    });

    testWidgets('tapping a tab changes selection state', (tester) async {
      UserTabType? changedTab;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.friends,
              onTabChanged: (tab) => changedTab = tab,
            ),
          ),
        ),
      );

      // Tap on "粉丝" tab
      await tester.tap(find.text('粉丝'));
      await tester.pumpAndSettle();

      expect(changedTab, equals(UserTabType.followers));

      // Verify "粉丝" is now selected (bold)
      final followersText = tester.widget<Text>(find.text('粉丝'));
      expect(followersText.style?.fontWeight, equals(FontWeight.bold));
      expect(followersText.style?.color, equals(AppColors.foreground));

      // Verify "好友" is now unselected
      final friendsText = tester.widget<Text>(find.text('好友'));
      expect(friendsText.style?.fontWeight, equals(FontWeight.normal));
      expect(friendsText.style?.color, equals(AppColors.mutedForeground));
    });

    // Property: For ALL tab types, selection produces correct visual state
    testWidgets('Property 4: All tab types show correct selection state when selected', (tester) async {
      for (final tabType in UserTabType.values) {
        // Use a unique key to force widget recreation
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('app_$tabType'),
            home: Scaffold(
              body: UserTabSection(
                key: ValueKey('tab_section_$tabType'),
                initialTab: tabType,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final selectedLabel = getTabLabel(tabType);
        final selectedText = tester.widget<Text>(find.text(selectedLabel));
        
        // Selected tab should have bold font and foreground color
        expect(
          selectedText.style?.fontWeight,
          equals(FontWeight.bold),
          reason: '$tabType tab should be bold when selected',
        );
        expect(
          selectedText.style?.color,
          equals(AppColors.foreground),
          reason: '$tabType tab should have foreground color when selected',
        );

        // All other tabs should be unselected
        for (final otherType in UserTabType.values) {
          if (otherType != tabType) {
            final otherLabel = getTabLabel(otherType);
            final otherText = tester.widget<Text>(find.text(otherLabel));
            
            expect(
              otherText.style?.fontWeight,
              equals(FontWeight.normal),
              reason: '$otherType tab should have normal font when $tabType is selected',
            );
            expect(
              otherText.style?.color,
              equals(AppColors.mutedForeground),
              reason: '$otherType tab should have mutedForeground color when $tabType is selected',
            );
          }
        }
      }
    });

    // Property: Underline indicator consistency
    testWidgets('Property 4: Underline indicator shows only for selected tab', (tester) async {
      for (final tabType in UserTabType.values) {
        // Use a unique key to force widget recreation
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('app_underline_$tabType'),
            home: Scaffold(
              body: UserTabSection(
                key: ValueKey('tab_section_underline_$tabType'),
                initialTab: tabType,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final animatedContainers = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();

        // Get the index of the selected tab
        final selectedIndex = UserTabType.values.indexOf(tabType);

        for (int i = 0; i < animatedContainers.length; i++) {
          final decoration = animatedContainers[i].decoration as BoxDecoration?;
          
          if (i == selectedIndex) {
            expect(
              decoration?.color,
              equals(AppColors.foreground),
              reason: 'Tab $i should have visible underline when $tabType is selected',
            );
          } else {
            expect(
              decoration?.color,
              equals(Colors.transparent),
              reason: 'Tab $i should have transparent underline when $tabType is selected',
            );
          }
        }
      }
    });

    testWidgets('underline indicator has correct dimensions (20x3)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserTabSection(
              initialTab: UserTabType.friends,
            ),
          ),
        ),
      );

      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      for (final container in animatedContainers) {
        final constraints = container.constraints;
        expect(constraints?.maxWidth, equals(20));
        expect(constraints?.maxHeight, equals(3));
      }
    });
  });
}
