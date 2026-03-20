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
      userName: '测试用户',
      userAvatar: 'https://example.com/avatar.jpg',
      timeAgo: '2小时前',
      filmTitle: '测试电影标题',
      filmPoster: 'https://example.com/poster.jpg',
      reviewText: '这是一段测试影评文本。' * 20, // 生成长文本用于测试行数限制
      rating: 8.5,
      likeCount: 1234,
      isLiked: false,
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

    testWidgets('布局结构测试: 卡片应使用顶部封面区 + 底部内容区的布局（而非海报全屏背景）', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 预期行为：卡片应该有一个 Column 布局，包含封面区和内容区
      // 未修复代码：使用 Stack 将所有内容叠加在海报背景上

      // 查找 Column 作为主要布局结构（修复后应该存在）
      final columnFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byWidgetPredicate(
          (widget) => widget is Column && widget.children.length >= 2,
        ),
      );

      // 在未修复的代码上，这个断言会失败，因为当前使用 Stack 布局
      expect(
        columnFinder,
        findsOneWidget,
        reason:
            '预期卡片使用 Column 布局（顶部封面区 + 底部内容区），'
            '但未修复的代码使用 Stack 将内容叠加在海报背景上',
      );
    });

    testWidgets('主题适配测试: 在深色主题下，内容区背景色应为 surfaceElevated', (
      WidgetTester tester,
    ) async {
      // Arrange
      const darkColors = AppColors.dark;
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildDarkTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 预期行为：内容区应该有一个 Container，背景色为 surfaceElevated
      // 未修复代码：内容区没有独立背景，直接叠加在海报上

      // 查找使用 surfaceElevated 背景色的 Container
      final contentContainerFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  darkColors.surfaceElevated,
        ),
      );

      // 在未修复的代码上，这个断言会失败
      expect(
        contentContainerFinder,
        findsAtLeastNWidgets(1),
        reason:
            '预期内容区使用 surfaceElevated 背景色 (${darkColors.surfaceElevated})，'
            '但未修复的代码没有独立的内容区背景',
      );
    });

    testWidgets('文字可读性测试: 内容区文字颜色应使用主题系统颜色（而非硬编码白色）', (
      WidgetTester tester,
    ) async {
      // Arrange
      const lightColors = AppColors.light;
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 预期行为：电影标题应使用 textPrimary 颜色
      // 未修复代码：所有文字都硬编码为白色

      // 查找电影标题文本
      final filmTitleFinder = find.text(testData.filmTitle);
      expect(filmTitleFinder, findsOneWidget);

      // 获取文本样式
      final Text filmTitleWidget = tester.widget(filmTitleFinder) as Text;
      final TextStyle? style = filmTitleWidget.style;

      // 在亮色主题下，文字应该是深色（textPrimary），而不是白色
      expect(
        style?.color,
        lightColors.textPrimary,
        reason:
            '预期电影标题使用主题系统颜色 textPrimary (${lightColors.textPrimary})，'
            '但未修复的代码硬编码为白色 (Colors.white)',
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
