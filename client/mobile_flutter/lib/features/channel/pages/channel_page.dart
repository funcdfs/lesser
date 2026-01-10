// 频道列表页

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../data_access/channel_mock_data_source.dart';
import '../handler/channel_handler.dart';
import '../handler/channel_mock_data.dart';
import '../models/channel_models.dart';
import '../widgets/channel_item.dart';
import '../widgets/channel_tag_drawer.dart';
import 'channel_detail_page.dart';

/// 频道列表页 - Tab 2 入口
class ChannelPage extends StatefulWidget {
  const ChannelPage({super.key});

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  late final ChannelHandler _handler;
  List<ChannelModel> _channels = [];
  bool _isLoading = true;
  String? _error;

  // 标签数据从 mock_data 获取，便于后续替换为后端数据
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    // 使用 Mock 数据源，后续可替换为 gRPC 数据源
    _handler = ChannelHandler(ChannelMockDataSource());
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    try {
      final channels = await _handler.getChannels();
      if (mounted) {
        setState(() {
          _channels = channels;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _handler.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _handler.refresh();
    if (mounted) {
      setState(() {
        _channels = _handler.channels;
      });
    }
  }

  void _onChannelTap(ChannelModel channel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ChannelDetailPage(channelId: channel.id, initialChannel: channel),
      ),
    );
  }

  void _onTagTap(ChannelTag tag) {
    setState(() {
      if (_selectedTags.contains(tag.id)) {
        _selectedTags.remove(tag.id);
      } else {
        _selectedTags.add(tag.id);
      }
    });
  }

  void _onClearTags() {
    setState(() {
      _selectedTags.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: AppBar(
        backgroundColor: colors.surfaceBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '频道',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          if (_selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: TapScale(
                  onTap: _onClearTags,
                  scale: TapScales.small,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.textPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_selectedTags.length}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: colors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColorScheme colors) {
    return Stack(
      children: [
        Positioned.fill(
          child: _isLoading
              ? _buildLoading(colors)
              : _error != null
              ? _buildError(colors)
              : _channels.isEmpty
              ? _buildEmpty(colors)
              : _buildList(colors),
        ),
        // 使用统一的 ChannelTagDrawer 组件，标签数据从 mock_data 获取
        ChannelTagDrawer(
          tags: mockChannelTags,
          selectedTags: _selectedTags,
          onTagTap: _onTagTap,
        ),
      ],
    );
  }

  Widget _buildLoading(AppColorScheme colors) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: colors.textTertiary,
      ),
    );
  }

  Widget _buildEmpty(AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_rounded, size: 64, color: colors.textDisabled),
          const SizedBox(height: 16),
          Text(
            '暂无订阅频道',
            style: TextStyle(fontSize: 16, color: colors.textTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            '订阅感兴趣的频道，获取最新资讯',
            style: TextStyle(fontSize: 14, color: colors.textDisabled),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: colors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(fontSize: 16, color: colors.textTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '未知错误',
            style: TextStyle(fontSize: 14, color: colors.textDisabled),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadChannels();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppColorScheme colors) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colors.textPrimary,
      backgroundColor: colors.surfaceElevated,
      child: ListView.builder(
        itemCount: _channels.length,
        itemBuilder: (context, index) {
          final channel = _channels[index];
          return ChannelItem(
            channel: channel,
            onTap: () => _onChannelTap(channel),
          );
        },
      ),
    );
  }
}
