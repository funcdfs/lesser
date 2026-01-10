// =============================================================================
// 频道组件统一导出
// =============================================================================
//
// 本文件作为频道模块所有 UI 组件的统一入口。
//
// ## 组件分类
//
// ### 列表组件
// - `ChannelItem` - 频道列表项
// - `ChannelTagDrawer` - 标签筛选抽屉
//
// ### 消息组件
// - `ChannelMessage` - 消息气泡（完整版）
// - `ChannelMessageBubble` - 消息气泡（仅内容部分）
// - `DateSeparator` - 日期分隔符
// - `PinnedMessageBanner` - 置顶消息横幅
//
// ### 详情页组件
// - `DetailAppBar` - 详情页毛玻璃导航栏
// - `MessageListView` - 消息列表视图
// - `MessageListController` - 消息列表控制器
// - `HighlightController` - 高亮控制器
//
// ### 评论页组件
// - `CommentPageScaffold` - 评论页脚手架
//
// ### 常量
// - `channel_constants.dart` - 布局常量定义

export 'channel_constants.dart';
export 'channel_item.dart';
export 'channel_message.dart';
export 'channel_tag_drawer.dart';
export 'comment_page_scaffold.dart';
export 'date_separator.dart';
export 'detail_app_bar.dart';
export 'message_list_controller.dart';
export 'message_list_view.dart';
export 'pinned_message_banner.dart';
