// =============================================================================
// 剧集组件统一导出
// =============================================================================
//
// 本文件作为剧集模块所有 UI 组件的统一入口。
//
// ## 组件分类
//
// ### 列表组件
// - `SeriesItem` - 剧集列表项
// - `SeriesTagDrawer` - 标签筛选抽屉
//
// ### 动态组件
// - `SeriesPost` - 动态气泡（完整版）
// - `SeriesPostBubble` - 动态气泡（仅内容部分）
// - `DateSeparator` - 日期分隔符
// - `PinnedPostBanner` - 置顶动态横幅
//
// ### 详情页组件
// - `DetailAppBar` - 详情页毛玻璃导航栏
// - `PostListView` - 动态列表视图
// - `PostListController` - 动态列表控制器
// - `HighlightController` - 高亮控制器
//
// ### 评论页组件
// - `CommentPageScaffold` - 评论页脚手架
//
// ### 常量
// - `series_constants.dart` - 布局常量定义

export 'series_constants.dart';
export 'series_item.dart';
export 'series_post.dart';
export 'series_tag_drawer.dart';
export 'comment_page_scaffold.dart';
export 'date_separator.dart';
export 'detail_app_bar.dart';
export 'post_list_controller.dart';
export 'post_list_view.dart';
export 'pinned_post_banner.dart';
