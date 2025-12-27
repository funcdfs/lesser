import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lesser/shared/widgets/autocomplete.dart';

void main() {
  group('AppAutocomplete', () {
    const testItems = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];

    testWidgets('renders correctly with basic parameters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppAutocomplete(items: testItems)),
        ),
      );

      // 验证组件是否存在
      expect(find.byType(AppAutocomplete), findsOneWidget);

      // 验证 Flutter 的 Autocomplete 组件是否被正确渲染
      expect(find.byType(Autocomplete<String>), findsOneWidget);
    });

    testWidgets('renders with hint text', (WidgetTester tester) async {
      const hintText = 'Search fruits...';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAutocomplete(items: testItems, hint: hintText),
          ),
        ),
      );

      // 验证提示文本是否存在
      expect(find.text(hintText), findsOneWidget);
    });

    testWidgets('renders with label', (WidgetTester tester) async {
      const labelText = 'Fruit Selection';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAutocomplete(
              items: testItems,
              label: const Text(labelText),
            ),
          ),
        ),
      );

      // 验证标签是否存在
      expect(find.text(labelText), findsOneWidget);
    });

    testWidgets('renders in disabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAutocomplete(items: testItems, enabled: false),
          ),
        ),
      );

      // 验证组件是否处于禁用状态
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('calls onChanged when text changes', (
      WidgetTester tester,
    ) async {
      String? capturedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAutocomplete(
              items: testItems,
              onChanged: (value) => capturedValue = value,
            ),
          ),
        ),
      );

      // 找到输入框并输入文本
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'Ap');
      await tester.pump();

      // 验证 onChanged 回调是否被调用
      expect(capturedValue, isNotNull);
      expect(capturedValue, 'Ap');
    });

    testWidgets('shows filtered options when typing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAutocomplete(items: testItems),
          ),
        ),
      );

      // 输入文本以触发选项显示
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'A');
      await tester.pumpAndSettle();

      // 验证过滤后的选项是否显示
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('calls onSelected when option is selected', (
      WidgetTester tester,
    ) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAutocomplete(
              items: testItems,
              onSelected: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      // 输入文本以触发选项显示
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'App');
      await tester.pumpAndSettle();

      // 点击选项
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      // 验证 onSelected 回调是否被调用
      expect(selectedValue, 'Apple');
    });
  });
}
