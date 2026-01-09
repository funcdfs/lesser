// 频道详情页

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../data_access/channel_mock_data_source.dart';
import '../handler/channel_handler.dart';
import '../models/channel_models.dart';
import '../widgets/channel_message.dart';
import '../widgets/date_separator.dart';
import '../widgets/pinned_message_banner.dart';
import 'channel_comment_page.dart';

/// 频道详情页
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
  ChannelModel? _channel;
  List<ChannelMessageModel> _messages = [];
  bool _isLoading = true;
  bool _showPinnedBanner = true;
  bool _isMuted = false;
  bool _showMessages = false;

  // 高亮状态
  String? _highlightedMessageId;
  bool _hasScrolledToTarget = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 使用 Mock 数据源
    _handler = ChannelHandler(ChannelMockDataSource());
    if (widget.initialChannel != null) {
      _channel = widget.initialChannel;
      _isMuted = widget.initialChannel!.isMuted;
      _isLoading = false;
    }
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final channel =
        _channel ?? await _handler.getChannelDetail(widget.channelId);
    final messages = await _handler.getMessages(widget.channelId);

    if (mounted) {
      setState(() {
        _channel = channel;
        _messages = messages;
        _isMuted = channel?.isMuted ?? false;
        _isLoading = false;
      });

      Future.delayed(AnimDurations.medium, () {
        if (mounted) {
          setState(() => _showMessages = true);
          // 消息显示后，尝试滚动到目标消息
          _tryScrollToTargetMessage();
        }
      });
    }
  }

  /// 尝试滚动到目标消息并高亮
  void _tryScrollToTargetMessage() {
    if (_hasScrolledToTarget) return;
    if (widget.highlightMessageId == null) return;

    final targetId = widget.highlightMessageId!;
    final items = _buildListItems();

    // 查找目标消息的索引
    int? targetIndex;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item is ChannelMessageModel && item.id == targetId) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex != null) {
      _hasScrolledToTarget = true;
      // 延迟执行滚动，确保列表已渲染
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndexAndHighlight(targetIndex!, targetId);
      });
    }
  }

  /// 滚动到指定索引并高亮
  void _scrollToIndexAndHighlight(int index, String messageId) {
    // 估算每个消息项的高度（约 120-180 像素）
    const estimatedItemHeight = 150.0;
    final targetOffset = index * estimatedItemHeight;

    // 滚动到目标位置
    _scrollController
        .animateTo(
          targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        )
        .then((_) {
          // 滚动完成后设置高亮
          if (mounted) {
            setState(() {
              _highlightedMessageId = messageId;
            });
          }
        });
  }

  /// 高亮动画完成回调
  void _onHighlightComplete() {
    if (mounted) {
      setState(() {
        _highlightedMessageId = null;
      });
    }
  }

  void _onClosePinnedBanner() {
    setState(() => _showPinnedBanner = false);
  }

  final _moreButtonKey = GlobalKey();

  /// 打开评论页面
  void _openCommentPage(ChannelMessageModel message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChannelCommentPage(
          messageId: message.id,
          channelId: widget.channelId,
          message: message, // 传递完整消息，用于显示消息头部
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
          icon: _isMuted
              ? Icons.notifications_rounded
              : Icons.notifications_off_rounded,
          label: _isMuted ? '取消静音' : '静音',
          value: 'mute',
        ),
        const PopupMenuItemData(
          icon: Icons.settings_rounded,
          label: '设置',
          value: 'settings',
        ),
      ],
      onSelected: (value) {
        if (value == 'mute') setState(() => _isMuted = !_isMuted);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      extendBodyBehindAppBar: true,
      appBar: _buildFrostedAppBar(colors),
      body: _isLoading
          ? _buildLoading(colors)
          : Stack(
              children: [
                Positioned.fill(child: _buildMessageList(colors)),
                if (_showPinnedBanner && _channel?.pinnedMessage != null)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                    left: 0,
                    right: 0,
                    child: PinnedMessageBanner(
                      message: _channel!.pinnedMessage!.content,
                      onClose: _onClosePinnedBanner,
                    ),
                  ),
              ],
            ),
    );
  }

  /// 毛玻璃 AppBar
  PreferredSizeWidget _buildFrostedAppBar(AppColorScheme colors) {
    return FrostedAppBar(
      blur: 20,
      opacity: 0.8,
      border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          size: 22,
          color: colors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: _channel == null
          ? null
          : Row(
              children: [
                Hero(
                  tag: 'channel_avatar_${widget.channelId}',
                  // 使用 placeholderBuilder 避免动画结束时的闪动
                  placeholderBuilder: (context, heroSize, child) {
                    return SizedBox(
                      width: heroSize.width,
                      height: heroSize.height,
                      child: child,
                    );
                  },
                  flightShuttleBuilder:
                      (context, anim, direction, fromCtx, toCtx) {
                        // 使用目标 widget 作为飞行 shuttle，配合 FadeTransition 平滑过渡
                        return FadeTransition(
                          opacity: anim,
                          child: Material(
                            color: Colors.transparent,
                            child: AvatarButton(
                              imageUrl: _channel!.avatarUrl,
                              size: 40,
                              placeholder: _channel!.name.isNotEmpty
                                  ? _channel!.name[0]
                                  : '#',
                            ),
                          ),
                        );
                      },
                  child: AvatarButton(
                    imageUrl: _channel!.avatarUrl,
                    size: 40,
                    placeholder: _channel!.name.isNotEmpty
                        ? _channel!.name[0]
                        : '#',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'channel_name_${widget.channelId}',
                        // 使用 placeholderBuilder 避免动画结束时的闪动
                        placeholderBuilder: (context, heroSize, child) {
                          return SizedBox(
                            width: heroSize.width,
                            height: heroSize.height,
                            child: child,
                          );
                        },
                        flightShuttleBuilder:
                            (context, anim, direction, fromCtx, toCtx) {
                              // 使用目标 widget 作为飞行 shuttle，配合 FadeTransition 平滑过渡
                              return FadeTransition(
                                opacity: anim,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    _channel!.name,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            },
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            _channel!.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SubscriberBadge(
                        count: _channel!.subscriberCount,
                        size: SubscriberBadgeSize.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: [
        IconButton(
          key: _moreButtonKey,
          icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary),
          onPressed: _showMoreMenu,
        ),
      ],
    );
  }

  /// 加载中状态
  Widget _buildLoading(AppColorScheme colors) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: colors.textTertiary,
      ),
    );
  }

  /// 消息列表
  Widget _buildMessageList(AppColorScheme colors) {
    if (!_showMessages) {
      return const SizedBox.shrink();
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: colors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无消息',
              style: TextStyle(fontSize: 16, color: colors.textTertiary),
            ),
          ],
        ),
      );
    }

    final items = _buildListItems();
    final messageDates = _getMessageDates();
    final topPadding =
        MediaQuery.paddingOf(context).top +
        kToolbarHeight +
        (_showPinnedBanner && _channel?.pinnedMessage != null ? 60 : 8);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: FadeInAnim.startOpacity, end: FadeInAnim.endOpacity),
      duration: FadeInAnim.duration,
      curve: FadeInAnim.curve,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: topPadding, bottom: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is DateTime) {
            return DateSeparator(
              date: item,
              messageDates: messageDates,
              onDateSelected: _scrollToDate,
            );
          } else if (item is ChannelMessageModel) {
            final isHighlighted = _highlightedMessageId == item.id;
            return ChannelMessageWidget(
              message: item,
              isHighlighted: isHighlighted,
              onHighlightComplete: isHighlighted ? _onHighlightComplete : null,
              onCommentTap: () => _openCommentPage(item),
              onMenuAction: (action) {
                _handleMessageMenuAction(action, item);
              },
              onReactionTap: (emoji) {},
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// 处理消息菜单操作
  void _handleMessageMenuAction(
    ChannelMessageMenuAction action,
    ChannelMessageModel message,
  ) {
    switch (action) {
      case ChannelMessageMenuAction.save:
        _showSnackBar('消息已保存');
        break;
      case ChannelMessageMenuAction.forward:
        // TODO: 实现转发
        break;
      case ChannelMessageMenuAction.detail:
        // TODO: 实现详情
        break;
    }
  }

  /// 显示 SnackBar 提示
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 获取所有消息的日期集合
  Set<DateTime> _getMessageDates() {
    return _messages.map((m) {
      return DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
    }).toSet();
  }

  /// 滚动到指定日期的消息
  void _scrollToDate(DateTime date) {
    // 找到该日期的第一条消息
    final targetIndex = _messages.indexWhere((m) {
      final msgDate = DateTime(
        m.createdAt.year,
        m.createdAt.month,
        m.createdAt.day,
      );
      return msgDate == date;
    });

    if (targetIndex != -1) {
      // 重新加载消息列表，确保滚动到正确位置
      setState(() {});
    }
  }

  /// 构建列表项
  List<dynamic> _buildListItems() {
    final items = <dynamic>[];
    DateTime? lastDate;

    for (final message in _messages) {
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      if (lastDate == null || lastDate != messageDate) {
        items.add(messageDate);
        lastDate = messageDate;
      }

      items.add(message);
    }

    return items;
  }
}
