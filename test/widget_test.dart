import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/app/lesser_app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LesserApp());

    // Verify that the title shows up.
    expect(find.text('Lesser'), findsOneWidget);
  });
}
