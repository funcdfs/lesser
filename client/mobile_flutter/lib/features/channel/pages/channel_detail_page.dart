// =============================================================================
// 频道详情页 - Channel Detail Page
// =============================================================================
//
// ## 设计目的
// 展示单个频道的消息列表，支持消息浏览、评论入口、置顶消息等功能。
// 支持深层链接导航，可直接跳转到指定消息并高亮显示。
//
// ## 页面结构
// - AppBar: 毛玻璃效果，显示频道信息和操作按钮
// - PinnedBanner: 置顶消息横幅（可关闭）
// - MessageList: 消息列表（支持日期分隔、高亮定位）
//
// ## 状态管理
// 使用 _DetailPageState 类封装页面状态，通过 copyWith 实现不可变更新。
// 状态包括：频道数据、消息列表、加载状态、UI 状态等。
//
// ## 深层链接支持
// - highlightMessageId: 需要高亮的消息 ID
// - 页面加载完成后自动滚动到目标消息并高亮显示
// - 高亮动画完成后自动清除高亮状态
//
// ## 生命周期处理
// - 异步操作后检查 mounted，防止 setState 调用已销毁的 State
// - Future.delayed 回调中也需要检查 mounted
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../data_access/channel_mock_data_source.dart';
import '../handler/channel_handler.dart';
import '../models/channel_models.dart';
import '../widgets/channel_constants.dart';
import '../widgets/channel_message.dart' show ChannelMessageMenuAction;
import '../widgets/detail_app_bar.dart';
import '../widgets/message_list_controller.dart';
import '../widgets/message_list_view.dart';
import '../widgets/pinned_message_banner.dart';
import '../../../pkg/utils/copy_with_utils.dart';
import 'channel_comment_page.dart';

/// 频道详情页状态
///
/// 使用不可变数据类封装页面状态，通过 copyWith 实现状态更新。
/// 这种模式便于状态追踪和调试，也更符合 Flutter 的声明式 UI 理念。
class _DetailPageState {
  _DetailPageState({
    this.channel,
    this.messages = const [],
    this.isLoading = true,
    this.showPinnedBanner = true,
    this.isMuted = false,
    this.showMessages = false,
    this.highlightedMessageId,
  });

  final ChannelModel? channel;
  final List<ChannelMessageModel> messages;
  final bool isLoading;
  final bool showPinnedBanner;
  final bool isMuted;
  final bool showMessages;
  final String? highlightedMessageId;

  /// 复制并修改指定字段
  ///
  /// 对于 highlightedMessageId 使用哨兵值模式：
  /// - 不传参：保留原值
  /// - 传入 null：清除该字段
  /// - 传入具体值：更新为新值
  _DetailPageState copyWith({
    ChannelModel? channel,
    List<ChannelMessageModel>? messages,
    bool? isLoading,
    bool? showPinnedBanner,
    bool? isMuted,
    bool? showMessages,
    Object? highlightedMessageId = sentinel,
  }) {
    return _DetailPageState(
      channel: channel ?? this.channel,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      showPinnedBanner: showPinnedBanner ?? this.showPinnedBanner,
      isMuted: isMuted ?? this.isMuted,
      showMessages: showMessages ?? this.showMessages,
      highlightedMessageId: highlightedMessageId == sentinel
          ? this.highlightedMessageId
          : castOrNull<String>(highlightedMessageId),
    );
  }
}

/// 频道详情页
///
/// ## 参数说明
/// - [channelId]: 频道 ID（必需）
/// - [initialChannel]: 初始频道数据（可选，用于 Hero 动画过渡）
/// - [highlightMessageId]: 需要高亮的消息 ID（可选，深层链接导航）
class ChannelDetailPage extends StatefulWidget {
  const ChannelDetailPage({
    super.key,
    required this.channelId,
    this.initialChannel,
    this.highlightMessageId,
  });

  final String channelId;
  final ChannelModel? initialChannel;
  final String? highlightMessageId; // 需要高亮的消息 ID（深层链接导航）

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  late final ChannelHandler _handler;
  late final MessageListController _listController;
  late final HighlightController _highlightController;
  final _scrollController = ScrollController();
  final _moreButtonKey = GlobalKey();

  late _DetailPageState _state;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _handler = ChannelHandler(ChannelMockDataSource());
    _listController = MessageListController();
    _highlightController = HighlightController(
      scrollController: _scrollController,
      onHighlightChanged: (id) {
        if (!_isDisposed && mounted) {
          setState(() {
            _state = _state.copyWith(highlightedMessageId: id);
          });
        }
      },
    );

    // 初始化状态（isMuted 从 handler 的 UI 状态获取）
    _state = _DetailPageState(
      channel: widget.initialChannel,
      isMuted: false, // 将在 _loadData 中更新
      isLoading: widget.initialChannel == null,
    );

    _loadData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    _listController.dispose();
    _highlightController.dispose(); // 清理高亮控制器
    _handler.dispose();
    super.dispose();
  }

  /// 加载频道数据和消息列表
  ///
  /// 加载流程：
  /// 1. 获取频道详情（如果没有初始数据）
  /// 2. 获取消息列表
  /// 3. 更新 UI 状态
  /// 4. 延迟显示消息（配合淡入动画）
  /// 5. 滚动到目标消息并高亮（如果有 highlightMessageId）
  Future<void> _loadData() async {
    if (_isDisposed) return;

    try {
      final channel =
          _state.channel ?? await _handler.getChannelDetail(widget.channelId);

      // 异步操作后检查是否已销毁
      if (_isDisposed) return;

      final messages = await _handler.getMessages(widget.channelId);

      // 再次检查，防止竞态条件
      if (_isDisposed) return;

      // 合并状态更新
      setState(() {
        _state = _state.copyWith(
          channel: channel,
          messages: messages,
          isMuted: _handler.getUIState(widget.channelId)?.isMuted ?? false,
          isLoading: false,
        );
      });

      // 更新缓存
      _listController.updateCache(messages);

      // 延迟显示消息
      Future.delayed(AnimDurations.medium, () {
        // Future.delayed 回调中必须检查是否已销毁
        if (_isDisposed) return;
        setState(() => _state = _state.copyWith(showMessages: true));
        // 消息显示后，尝试滚动到目标消息
        _highlightController.scrollToMessageAndHighlight(
          targetMessageId: widget.highlightMessageId,
          listController: _listController,
        );
      });
    } catch (e) {
      if (_isDisposed) return;
      setState(() {
        _state = _state.copyWith(isLoading: false);
      });
      _showSnackBar('加载失败，请稍后重试');
    }
  }

  void _onClosePinnedBanner() {
    setState(() => _state = _state.copyWith(showPinnedBanner: false));
  }

  void _openCommentPage(ChannelMessageModel message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelCommentPage(
          messageId: message.id,
          channelId: widget.channelId,
          message: message,
        ),
      ),
    );
  }

  void _showMoreMenu() {
    showPopupMenu(
      context: context,
      anchorKey: _moreButtonKey,
      items: [
        const PopupMenuItemData(
          icon: Icons.search_rounded,
          label: '搜索',
          value: 'search',
        ),
        PopupMenuItemData(
          icon: _state.isMuted
              ? Icons.notifications_rounded
              : Icons.notifications_off_rounded,
          label: _state.isMuted ? '取消静音' : '静音',
          value: 'mute',
        ),
        const PopupMenuItemData(
          icon: Icons.settings_rounded,
          label: '设置',
          value: 'settings',
        ),
      ],
      onSelected: (value) {
        if (value == 'mute') {
          setState(() => _state = _state.copyWith(isMuted: !_state.isMuted));
        }
      },
    );
  }

  void _handleMessageMenuAction(
    ChannelMessageMenuAction action,
    ChannelMessageModel message,
  ) {
    switch (action) {
      case ChannelMessageMenuAction.save:
        _showSnackBar('消息已保存');
        break;
      case ChannelMessageMenuAction.forward:
        _showSnackBar('转发功能开发中');
        break;
      case ChannelMessageMenuAction.detail:
        _showSnackBar('详情功能开发中');
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToDate(DateTime date) {
    final targetIndex = _state.messages.indexWhere((m) {
      final msgDate = DateTime(
        m.createdAt.year,
        m.createdAt.month,
        m.createdAt.day,
      );
      return msgDate == date;
    });

    if (targetIndex == -1) return;

    // 使用 HighlightController 滚动到目标位置
    final itemKey = _highlightController.getKeyForIndex(targetIndex);
    final keyContext = itemKey.currentContext;

    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        alignment: ChannelLayoutConstants.scrollAlignment,
        duration: ChannelLayoutConstants.scrollDuration,
        curve: Curves.easeOut,
      );
    } else {
      // 降级处理：当 context 不可用时，使用估算位置滚动
      if (!_scrollController.hasClients) return;
      final targetOffset =
          targetIndex * ChannelLayoutConstants.estimatedItemHeight;
      final maxExtent = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, maxExtent),
        duration: ChannelLayoutConstants.scrollDuration,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasPinnedMessage = _state.channel?.pinnedMessage != null;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      extendBodyBehindAppBar: true,
      appBar: DetailAppBar(
        channel: _state.channel,
        channelId: widget.channelId,
        moreButtonKey: _moreButtonKey,
        onBack: () => Navigator.of(context).pop(),
        onMoreTap: _showMoreMenu,
      ),
      body: _state.isLoading
          ? const _LoadingView()
          : Stack(
              children: [
                Positioned.fill(
                  child: _buildMessageList(colors, hasPinnedMessage),
                ),
                if (_state.showPinnedBanner && hasPinnedMessage)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                    left: 0,
                    right: 0,
                    child: PinnedMessageBanner(
                      message: _state.channel!.pinnedMessage!.content,
                      onClose: _onClosePinnedBanner,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMessageList(AppColorScheme colors, bool hasPinnedMessage) {
    if (!_state.showMessages) {
      return const SizedBox.shrink();
    }

    final topPadding =
        MediaQuery.paddingOf(context).top +
        kToolbarHeight +
        (_state.showPinnedBanner && hasPinnedMessage
            ? ChannelLayoutConstants.pinnedBannerHeight
            : ChannelLayoutConstants.defaultTopPadding);

    return MessageListView(
      listController: _listController,
      scrollController: _scrollController,
      highlightController: _highlightController,
      highlightedMessageId: _state.highlightedMessageId,
      topPadding: topPadding,
      onHighlightComplete: _highlightController.onHighlightComplete,
      onCommentTap: _openCommentPage,
      onMenuAction: _handleMessageMenuAction,
      onReactionTap: (emoji) {},
      onDateSelected: _scrollToDate,
    );
  }
}

/// 加载中视图
///
/// 居中显示加载指示器，使用主题色。
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: colors.textTertiary,
      ),
    );
  }
}
