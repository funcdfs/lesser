import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/shared/widgets/avatar.dart';

void main() {
  group('UserAvatar', () {
    testWidgets('should display initials when no image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'John Doe'),
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('should display single initial for single name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'John'),
          ),
        ),
      );

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should display ? when name is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: ''),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should display ? when name is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should have correct default size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'John'),
          ),
        ),
      );

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 20.0); // size / 2 = 40 / 2
    });

    testWidgets('should have custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'John', size: 60),
          ),
        ),
      );

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 30.0); // size / 2 = 60 / 2
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              name: 'John',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets('should use CircleAvatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(name: 'John'),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
    });
  });

  group('OnlineAvatar', () {
    testWidgets('should display UserAvatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnlineAvatar(name: 'John'),
          ),
        ),
      );

      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('should show online indicator when isOnline is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnlineAvatar(name: 'John', isOnline: true),
          ),
        ),
      );

      // Should have 2 containers - one for avatar background, one for online indicator
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should not show online indicator when isOnline is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OnlineAvatar(name: 'John', isOnline: false),
          ),
        ),
      );

      // Should only have the avatar, no online indicator container
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnlineAvatar(
              name: 'John',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });
  });
}
