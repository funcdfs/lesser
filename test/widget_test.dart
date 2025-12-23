import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InviteFeedApp());

    // Verify that the title shows up.
    expect(find.text('Invitation Feed'), findsOneWidget);
  });
}
