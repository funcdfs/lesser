// Preservation 属性测试 - ReviewCard 交互功能和视觉效果
//
// **重要**: 此测试在未修复的代码上应该通过 - 通过确认要保留的基线行为
// 这些测试验证修复后所有现有功能保持不变
//
// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/features/timeline/widgets/review_card.dart';
import 'package:mobile_flutter/pkg/ui/theme/app_theme.dart';
import 'package:mobile_flutter/pkg/ui/effects/tap_scale.dart';

void main() {
  group('Preservation 属性测试 - ReviewCard', () {
    // 测试数据
    const testData = ReviewCardData(
      userName: '测试用户',
      userAvatar: 'https://example.com/avatar.jpg',
      timeAgo: '2小时前',
      filmTitle: '测试电影',
      filmPoster: 'https://example.com/poster.jpg',
      reviewText: '这是一段测试影评文本',
      rating: 8.5,
      likeCount: 1234,
      isLiked: false,
    );

    /// 辅助函数：在指定主题下构建 ReviewCard
    Widget buildReviewCardWithTheme({
      required ReviewCardData data,
      required ThemeData theme,
      VoidCallback? onTap,
      VoidCallback? onLike,
      VoidCallback? onShare,
      VoidCallback? onRepost,
      VoidCallback? onBookmark,
    }) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: ReviewCard(
                data: data,
                onTap: onTap,
                onLike: onLike,
                onShare: onShare,
                onRepost: onRepost,
                onBookmark: onBookmark,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('回调函数保留测试: 点击卡片应触发 onTap 回调', (WidgetTester tester) async {
      // Arrange
      bool cardTapped = false;
      await tester.pumpWidget(
        buildReviewCardWithTheme(
          data: testData,
          theme: buildLightTheme(),
          onTap: () => cardTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      // 点击卡片（通过点击 ReviewCard 的 TapScale 组件）
      final tapScaleFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byType(TapScale),
      );
      expect(tapScaleFinder, findsWidgets);

      // 点击第一个 TapScale（卡片本身）
      await tester.tap(tapScaleFinder.first);
      await tester.pumpAndSettle();

      // Assert
      expect(cardTapped, true, reason: '点击卡片应触发 onTap 回调，这是导航到详情页的关键功能');
    });

    testWidgets('回调函数保留测试: 点击点赞按钮应触发 onLike 回调', (WidgetTester tester) async {
      // Arrange
      bool likeTapped = false;
      await tester.pumpWidget(
        buildReviewCardWithTheme(
          data: testData,
          theme: buildLightTheme(),
          onLike: () => likeTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      // 查找点赞按钮（通过图标识别）
      final likeButtonFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.favorite_border),
      );
      expect(likeButtonFinder, findsOneWidget);

      await tester.tap(likeButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(likeTapped, true, reason: '点击点赞按钮应触发 onLike 回调');
    });

    testWidgets('回调函数保留测试: 点击分享按钮应触发 onShare 回调', (WidgetTester tester) async {
      // Arrange
      bool shareTapped = false;
      await tester.pumpWidget(
        buildReviewCardWithTheme(
          data: testData,
          theme: buildLightTheme(),
          onShare: () => shareTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final shareButtonFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.share_outlined),
      );
      expect(shareButtonFinder, findsOneWidget);

      await tester.tap(shareButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(shareTapped, true, reason: '点击分享按钮应触发 onShare 回调');
    });

    testWidgets('回调函数保留测试: 点击转发按钮应触发 onRepost 回调', (WidgetTester tester) async {
      // Arrange
      bool repostTapped = false;
      await tester.pumpWidget(
        buildReviewCardWithTheme(
          data: testData,
          theme: buildLightTheme(),
          onRepost: () => repostTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final repostButtonFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.repeat),
      );
      expect(repostButtonFinder, findsOneWidget);

      await tester.tap(repostButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(repostTapped, true, reason: '点击转发按钮应触发 onRepost 回调');
    });

    testWidgets('回调函数保留测试: 点击收藏按钮应触发 onBookmark 回调', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool bookmarkTapped = false;
      await tester.pumpWidget(
        buildReviewCardWithTheme(
          data: testData,
          theme: buildLightTheme(),
          onBookmark: () => bookmarkTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      final bookmarkButtonFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.bookmark_border),
      );
      expect(bookmarkButtonFinder, findsOneWidget);

      await tester.tap(bookmarkButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(bookmarkTapped, true, reason: '点击收藏按钮应触发 onBookmark 回调');
    });

    testWidgets('TapScale 动画保留测试: 卡片应使用 TapScale 包裹以提供缩放动画', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 验证 ReviewCard 使用 TapScale 包裹
      final tapScaleFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byType(TapScale),
      );

      expect(
        tapScaleFinder,
        findsWidgets,
        reason: 'ReviewCard 应使用 TapScale 组件提供点击缩放动画效果',
      );
    });

    testWidgets('紫罗兰色调保留测试: 评分徽章应使用紫罗兰色调', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 查找评分星标图标
      final starIconFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.star),
      );
      expect(starIconFinder, findsOneWidget);

      // 获取星标图标的颜色
      final Icon starIcon = tester.widget(starIconFinder) as Icon;

      // 验证星标使用紫罗兰色调（#d2bbff）
      expect(
        starIcon.color,
        const Color(0xFFd2bbff),
        reason: '评分徽章的星标应使用紫罗兰色调 #d2bbff',
      );
    });

    testWidgets('紫罗兰色调保留测试: VIEW MOVIE 按钮应使用紫罗兰色调背景', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 查找 VIEW MOVIE 按钮文本
      final viewMovieTextFinder = find.text('VIEW MOVIE');
      expect(viewMovieTextFinder, findsOneWidget);

      // 查找包含该文本的 Container
      final containerFinder = find.ancestor(
        of: viewMovieTextFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color != null,
        ),
      );
      expect(containerFinder, findsOneWidget);

      final Container container = tester.widget(containerFinder) as Container;
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      // 验证背景色使用紫罗兰色调（#6c49b2 with alpha 0.4）
      expect(
        decoration.color,
        const Color(0xFF6c49b2).withValues(alpha: 0.4),
        reason: 'VIEW MOVIE 按钮应使用紫罗兰色调背景 #6c49b2',
      );
    });

    testWidgets('图片加载保留测试: 海报加载失败时应显示占位图标', (WidgetTester tester) async {
      // Arrange
      // 使用无效的图片 URL 触发错误
      final dataWithInvalidPoster = ReviewCardData(
        userName: testData.userName,
        userAvatar: testData.userAvatar,
        timeAgo: testData.timeAgo,
        filmTitle: testData.filmTitle,
        filmPoster: 'https://invalid-url-that-will-fail.com/poster.jpg',
        reviewText: testData.reviewText,
        rating: testData.rating,
        likeCount: testData.likeCount,
        isLiked: testData.isLiked,
      );

      await tester.pumpWidget(
        buildReviewCardWithTheme(
          data: dataWithInvalidPoster,
          theme: buildLightTheme(),
        ),
      );

      // 等待图片加载失败
      await tester.pumpAndSettle();

      // Act & Assert
      // 验证显示电影图标作为占位符
      final movieIconFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.movie),
      );

      expect(
        movieIconFinder,
        findsOneWidget,
        reason: '海报加载失败时应显示 Icons.movie 占位图标',
      );
    });

    testWidgets('图片加载保留测试: 头像加载失败时应显示默认头像图标', (WidgetTester tester) async {
      // Arrange
      // 使用无效的头像 URL 触发错误
      final dataWithInvalidAvatar = ReviewCardData(
        userName: testData.userName,
        userAvatar: 'https://invalid-url-that-will-fail.com/avatar.jpg',
        timeAgo: testData.timeAgo,
        filmTitle: testData.filmTitle,
        filmPoster: testData.filmPoster,
        reviewText: testData.reviewText,
        rating: testData.rating,
        likeCount: testData.likeCount,
        isLiked: testData.isLiked,
      );

      await tester.pumpWidget(
        buildReviewCardWithTheme(
          data: dataWithInvalidAvatar,
          theme: buildLightTheme(),
        ),
      );

      // 等待图片加载失败
      await tester.pumpAndSettle();

      // Act & Assert
      // 验证显示人物图标作为占位符
      final personIconFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.person),
      );

      expect(
        personIconFinder,
        findsOneWidget,
        reason: '头像加载失败时应显示 Icons.person 默认头像图标',
      );
    });

    testWidgets('数字格式化保留测试: 点赞数应正确格式化（1234 -> 1.2k）', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 验证点赞数显示为 "1.2k"
      final likeCountFinder = find.text('1.2k');

      expect(likeCountFinder, findsOneWidget, reason: '点赞数 1234 应格式化为 "1.2k"');
    });

    testWidgets('数字格式化保留测试: 小于 1000 的点赞数应直接显示', (WidgetTester tester) async {
      // Arrange
      final dataWithSmallLikeCount = ReviewCardData(
        userName: testData.userName,
        userAvatar: testData.userAvatar,
        timeAgo: testData.timeAgo,
        filmTitle: testData.filmTitle,
        filmPoster: testData.filmPoster,
        reviewText: testData.reviewText,
        rating: testData.rating,
        likeCount: 42,
        isLiked: false,
      );

      await tester.pumpWidget(
        buildReviewCardWithTheme(
          data: dataWithSmallLikeCount,
          theme: buildLightTheme(),
        ),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 验证点赞数直接显示为 "42"
      final likeCountFinder = find.text('42');

      expect(likeCountFinder, findsOneWidget, reason: '小于 1000 的点赞数应直接显示原始数字');
    });

    testWidgets('点赞状态保留测试: isLiked 为 true 时应显示实心爱心图标', (
      WidgetTester tester,
    ) async {
      // Arrange
      final likedData = ReviewCardData(
        userName: testData.userName,
        userAvatar: testData.userAvatar,
        timeAgo: testData.timeAgo,
        filmTitle: testData.filmTitle,
        filmPoster: testData.filmPoster,
        reviewText: testData.reviewText,
        rating: testData.rating,
        likeCount: testData.likeCount,
        isLiked: true,
      );

      await tester.pumpWidget(
        buildReviewCardWithTheme(data: likedData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 验证显示实心爱心图标
      final likedIconFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.favorite),
      );

      expect(
        likedIconFinder,
        findsOneWidget,
        reason: 'isLiked 为 true 时应显示实心爱心图标 Icons.favorite',
      );
    });

    testWidgets('点赞状态保留测试: isLiked 为 false 时应显示空心爱心图标', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 验证显示空心爱心图标
      final unlikedIconFinder = find.descendant(
        of: find.byType(ReviewCard),
        matching: find.byIcon(Icons.favorite_border),
      );

      expect(
        unlikedIconFinder,
        findsOneWidget,
        reason: 'isLiked 为 false 时应显示空心爱心图标 Icons.favorite_border',
      );
    });

    testWidgets('圆角保留测试: 卡片应使用 24px 圆角', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        buildReviewCardWithTheme(data: testData, theme: buildLightTheme()),
      );
      await tester.pumpAndSettle();

      // Act & Assert
      // 查找卡片最外层的 Container（带有 BoxShadow 的那个）
      final containerFinder = find.descendant(
        of: find.byType(TapScale).first,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).boxShadow != null &&
              (widget.decoration as BoxDecoration).borderRadius != null,
        ),
      );

      expect(containerFinder, findsOneWidget);

      final Container container = tester.widget(containerFinder) as Container;
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      final BorderRadius? borderRadius =
          decoration.borderRadius as BorderRadius?;

      expect(borderRadius?.topLeft.x, 24.0, reason: '卡片应使用 24px 圆角');
    });
  });
}
