import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lesser/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LesserApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pump();

    // Verify that the MaterialApp is rendered
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
