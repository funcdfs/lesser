// 评论滚动控制器
//
// 管理评论页面的滚动状态和锚点：
// - 顶部/底部锚点管理
// - 未读消息计数
// - 通过 Link 系统实现跳转
//
// 设计原则：
// - 与 UI 完全分离，只处理滚动逻辑
// - 通过 Link 系统实现跳转，不直接操作 ScrollController

import 'package:flutter/widgets.dart';
import '../../link/link_parser.dart';
import '../../link/link_service.dart';

/// 评论滚动控制器
///
/// 通过 Link 系统实现跳转：
/// - 总览层：置顶 = header，置底 = 最后一条评论
/// - 子层：置顶 = root comment，置底 = 最后一条回复
class CommentScrollController extends ChangeNotifier {
  CommentScrollController({required this.channelId, required this.messageId});

  /// 频道 ID
  final String channelId;

  /// 消息 ID
  final String messageId;

  // 内部状态
  bool _disposed = false;
  int _unreadCount = 0;

  // 锚点 ID
  String? _topAnchorId;
  String? _bottomAnchorId;

  // ---------------------------------------------------------------------------
  // 公开 API
  // ---------------------------------------------------------------------------

  /// 顶部锚点 ID
  String? get topAnchorId => _topAnchorId;

  /// 底部锚点 ID
  String? get bottomAnchorId => _bottomAnchorId;

  /// 未读消息数
  int get unreadCount => _unreadCount;

  /// 是否有未读消息
  bool get hasUnread => _unreadCount > 0;

  /// 是否可以跳转到顶部
  bool get canJumpToTop => _topAnchorId != null;

  /// 是否可以跳转到底部
  bool get canJumpToBottom => _bottomAnchorId != null;

  /// 是否显示按钮
  bool get isVisible => _topAnchorId != null || _bottomAnchorId != null;

  /// 获取顶部链接 URL
  String? get topUrl {
    if (_topAnchorId == null) return null;
    // header 锚点使用 anchor 类型
    if (LinkParser.isHeaderAnchor(_topAnchorId!)) {
      final anchorId =
          LinkParser.anchorIdFromToken(_topAnchorId!) ?? _topAnchorId!;
      return LinkParser.buildAnchorUrl(channelId, messageId, anchorId);
    }
    // 普通评论使用 comment 类型
    return LinkParser.buildCommentUrl(channelId, messageId, _topAnchorId!);
  }

  /// 获取底部链接 URL
  String? get bottomUrl {
    if (_bottomAnchorId == null) return null;
    // bottom 锚点使用 anchor 类型
    if (LinkParser.isBottomAnchor(_bottomAnchorId!)) {
      final anchorId =
          LinkParser.anchorIdFromToken(_bottomAnchorId!) ?? _bottomAnchorId!;
      return LinkParser.buildAnchorUrl(channelId, messageId, anchorId);
    }
    // 普通评论使用 comment 类型
    return LinkParser.buildCommentUrl(channelId, messageId, _bottomAnchorId!);
  }

  /// 更新锚点（总览层）
  ///
  /// - 顶部：header（帖子/消息）
  /// - 底部：bottom 锚点（跳转到列表最底部）
  void updateAnchorsForOverview({String? bottomCommentId}) {
    if (_disposed) return;

    _topAnchorId = LinkParser.anchorToken(LinkParser.headerAnchor);
    // 总览层始终使用 bottom 锚点，跳转到列表最底部
    _bottomAnchorId = LinkParser.anchorToken(LinkParser.bottomAnchor);
    notifyListeners();
  }

  /// 更新锚点（子层）
  ///
  /// - 顶部：root comment
  /// - 底部：bottom 锚点（跳转到列表最底部）
  void updateAnchorsForThread({
    required String rootCommentId,
    String? bottomCommentId,
  }) {
    if (_disposed) return;

    _topAnchorId = rootCommentId;
    // 子层也使用 bottom 锚点，确保跳转到列表最底部
    // 如果没有回复或只有 root，底部锚点为空
    if (bottomCommentId != null && bottomCommentId != rootCommentId) {
      _bottomAnchorId = LinkParser.anchorToken(LinkParser.bottomAnchor);
    } else {
      _bottomAnchorId = null;
    }
    notifyListeners();
  }

  /// 新消息到达，增加未读计数
  ///
  /// 底部锚点保持为 bottom，不更新为具体评论 ID
  /// 这样点击置底按钮始终跳转到列表最底部
  void onNewMessage(String newCommentId) {
    if (_disposed) return;
    // 不更新 _bottomAnchorId，保持为 bottom 锚点
    _unreadCount++;
    notifyListeners();
  }

  /// 清除未读计数
  void clearUnread() {
    if (_disposed || _unreadCount == 0) return;
    _unreadCount = 0;
    notifyListeners();
  }

  /// 跳转到顶部
  Future<void> jumpToTop(BuildContext context) async {
    if (_disposed || _topAnchorId == null) return;

    final url = topUrl;
    if (url == null) return;

    // 注意：TapScale 已内置触感反馈，此处不再重复调用
    await LinkService.instance.navigate(
      context,
      url,
      mode: LinkNavigateMode.replace,
    );
  }

  /// 跳转到底部
  Future<void> jumpToBottom(BuildContext context) async {
    if (_disposed || _bottomAnchorId == null) return;

    clearUnread();

    final url = bottomUrl;
    if (url == null) return;

    // 注意：TapScale 已内置触感反馈，此处不再重复调用
    await LinkService.instance.navigate(
      context,
      url,
      mode: LinkNavigateMode.replace,
    );
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}
