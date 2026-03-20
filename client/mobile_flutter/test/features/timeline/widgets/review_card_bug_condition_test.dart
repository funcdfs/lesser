// Bug Condition 探索性测试 - ReviewCard 布局和主题适配
//
// **重要**: 此测试在未修复的代码上应该失败 - 失败确认 bug 存在
// 测试编码了预期行为 - 修复后通过时将验证修复
//
// **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/timeline/widgets/review_card.dart';
import 'package:mobile_flutter/pkg/ui/theme/app_theme.dart';

void main() {
  group('Bug Condition 探索性测试 - ReviewCard', () {
    // 测试数据
    final testData = ReviewCardData(
      id: 'test-bug-1',
      user: UserInfo(
        name: '测试用户',
        avatar: 'https://example.com/avatar.jpg',
      ),
      publishTime: '2小时前',
      publishDate: '2024-03-20',
      movieTitle: '测试电影标题',
      moviePoster: 'https://example.com/poster.jpg',
      reviewText: '这是一段测试影评文本。' * 20,
      movieRating: 8.5,
      userRating: 9.0,
    );

    /// 辅助函数：在指定主题下构建 ReviewCard
    Widget buildReviewCardWithTheme({
      required ReviewCardData data,
      required ThemeData theme,
    }) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 400, child: ReviewCard(data: data)),
          ),
        ),
      );
    }

    testWidgets('布局结构测试: 卡片应使用 Stack 层叠布局显示全屏海报感', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 现在的设计使用 Stack 层叠布局

      // 查找 Stack
      final stackFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byType(Stack),
      );

      expect(
        stackFinder,
        findsAtLeastNWidgets(1),
        reason: '精致设计应使用 Stack 层叠布局',
      );
    });

    testWidgets('背景色测试: 内容区背景应带有毛玻璃感渐变', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 查找包含渐变的 Container
      final gradientContainerFinder = find.descendant(
        of: find.byType(ReviewCard).first,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient != null,
        ),
      );

      expect(
        gradientContainerFinder,
        findsAtLeastNWidgets(1),
        reason: '精致设计应包含背景渐变',
      );
    });

    testWidgets('文字颜色测试: 标题应使用深色以确保可读性', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 查找电影标题文本
      final movieTitleFinder = find.text(testData.movieTitle);
      expect(movieTitleFinder, findsOneWidget);

      // 获取文本样式
      final Text movieTitleWidget = tester.widget(movieTitleFinder) as Text;
      final TextStyle? style = movieTitleWidget.style;

      expect(
        style?.color,
        const Color(0xFF111827),
        reason: '电影标题应使用深色 #111827',
      );
    });

    testWidgets('文本行数测试: 影评文本应最多显示 10 行（而非当前的 2 行）', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 预期行为：影评文本应该 maxLines = 10
      // 未修复代码：maxLines = 2

      // 查找影评文本（通过样式特征识别）
      final reviewTextFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == testData.reviewText &&
              widget.maxLines != null,
        ),
      );

      expect(reviewTextFinder, findsOneWidget);

      final Text reviewTextWidget = tester.widget(reviewTextFinder) as Text;

      // 在未修复的代码上，maxLines 是 2，这个断言会失败
      expect(
        reviewTextWidget.maxLines,
        10,
        reason: '预期影评文本最多显示 10 行，但未修复的代码只显示 2 行',
      );
    });
  });
}
