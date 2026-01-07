// 频道详情页

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../../../pkg/ui/widgets/widgets.dart';
import '../handler/channel_handler.dart';
import '../models/channel_models.dart';
import '../widgets/channel_message.dart';
import '../widgets/date_separator.dart';
import '../widgets/pinned_message_banner.dart';

/// 频道详情页
class ChannelDetailPage extends StatefulWidget {
  const ChannelDetailPage({
    super.key,
    required this.channelId,
    this.initialChannel,
  });

  final String channelId;
  final ChannelModel? initialChannel;

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  final _handler = ChannelHandler();
  ChannelModel? _channel;
  List<ChannelPostModel> _messages = [];
  bool _isLoading = true;
  bool _showPinnedBanner = true;
  bool _isMuted = false;
  bool _showMessages = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialChannel != null) {
      _channel = widget.initialChannel;
      _isMuted = widget.initialChannel!.isMuted;
      _isLoading = false;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final channel = _channel ?? _handler.getChannelDetail(widget.channelId);
    final messages = await _handler.getMessages(widget.channelId);

    if (mounted) {
      setState(() {
        _channel = channel;
        _messages = messages;
        _isMuted = channel?.isMuted ?? false;
        _isLoading = false;
      });

      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _showMessages = true);
      });
    }
  }

  void _onClosePinnedBanner() {
    setState(() => _showPinnedBanner = false);
  }

  final _moreButtonKey = GlobalKey();

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
                if (_showPinnedBanner && _channel?.pinnedPost != null)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                    left: 0,
                    right: 0,
                    child: PinnedMessageBanner(
                      message: _channel!.pinnedPost!.content,
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
                  flightShuttleBuilder:
                      (context, anim, direction, fromCtx, toCtx) {
                        return Material(
                          color: Colors.transparent,
                          child: AvatarButton(
                            imageUrl: _channel!.avatarUrl,
                            size: 40,
                            placeholder: _channel!.name.isNotEmpty
                                ? _channel!.name[0]
                                : '#',
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
                        flightShuttleBuilder:
                            (context, anim, direction, fromCtx, toCtx) {
                              return Material(
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
    final topPadding =
        MediaQuery.paddingOf(context).top +
        kToolbarHeight +
        (_showPinnedBanner && _channel?.pinnedPost != null ? 60 : 8);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: ListView.builder(
        padding: EdgeInsets.only(top: topPadding, bottom: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is DateTime) {
            return DateSeparator(date: item);
          } else if (item is ChannelPostModel) {
            return ChannelMessageWidget(
              message: item,
              onCommentTap: () {},
              onForward: () {},
              onReactionTap: (emoji) {},
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
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
