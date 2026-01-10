// =============================================================================
// 频道列表页 - Channel Page (Tab 2)
// =============================================================================
//
// ## 设计目的
// 作为底部导航栏 Tab 2 的入口页面，展示用户订阅的频道列表。
// 支持标签筛选、下拉刷新和频道详情导航。
//
// ## 页面结构
// - AppBar: 标题 + 筛选标签清除按钮
// - Body: 频道列表（支持下拉刷新）
// - Overlay: 底部标签抽屉（可拖拽展开）
//
// ## 状态管理
// - 使用 ChannelHandler 管理频道数据和 UI 状态
// - 标签筛选状态由页面本地管理（_selectedTags）
// - Handler 变化时通过 Listener 触发重建
//
// ## 生命周期处理
// - initState: 创建 Handler，添加监听器，加载数据
// - dispose: 先移除监听器，再 dispose Handler（防止回调竞态）
//
// ## 数据源
// 当前使用 ChannelMockDataSource，后续可替换为 gRPC 数据源。
// 标签数据从 mock_data 获取，便于统一管理。
//
// =============================================================================

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../data_access/channel_mock_data_source.dart';
import '../data_access/mock/channel_mock_data.dart';
import '../handler/channel_handler.dart';
import '../models/channel_models.dart';
import '../widgets/channel_item.dart';
import '../widgets/channel_tag_drawer.dart';
import 'channel_detail_page.dart';

/// 频道列表页 - Tab 2 入口
///
/// ## 功能特性
/// - 频道列表展示（支持下拉刷新）
/// - 标签筛选（底部抽屉）
/// - 加载/空/错误状态处理
/// - 频道详情页导航
class ChannelPage extends StatefulWidget {
  const ChannelPage({super.key});

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  late final ChannelHandler _handler;

  // 标签筛选状态（本地管理，后续可考虑移入 Handler）
  // 标签数据从 mock_data 获取，便于后续替换为后端数据
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    // 使用 Mock 数据源，后续可替换为 gRPC 数据源
    _handler = ChannelHandler(ChannelMockDataSource());
    _handler.addListener(_onHandlerChanged);
    _handler.getChannels();
  }

  /// Handler 状态变化回调
  ///
  /// 注意：已有 mounted 检查，确保 dispose 后不会调用 setState
  void _onHandlerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // 重要：先移除监听器，防止 dispose 后仍收到回调
    // 虽然 _onHandlerChanged 中有 mounted 检查，但这是双重保险
    _handler.removeListener(_onHandlerChanged);
    _handler.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _handler.refresh();
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
    setState(() => _selectedTags.clear());
  }

  void _onRetry() {
    _handler.getChannels();
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
      body: Stack(
        children: [
          Positioned.fill(child: _buildContent(colors)),
          // 使用统一的 ChannelTagDrawer 组件，标签数据从 mock_data 获取
          ChannelTagDrawer(
            tags: mockChannelTags,
            selectedTags: _selectedTags,
            onTagTap: _onTagTap,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppColorScheme colors) {
    if (_handler.isLoading) {
      return _LoadingView(colors: colors);
    }

    if (_handler.error != null) {
      return _ErrorView(
        colors: colors,
        error: _handler.error!,
        onRetry: _onRetry,
      );
    }

    if (_handler.channels.isEmpty) {
      return _EmptyView(colors: colors);
    }

    return _ChannelListView(
      colors: colors,
      channels: _handler.channels,
      getUIState: _handler.getUIState,
      onRefresh: _onRefresh,
      onChannelTap: _onChannelTap,
    );
  }
}

// =============================================================================
// 私有 Widget 类
// =============================================================================
// 将状态视图抽取为独立的私有 Widget 类，遵循 Flutter 最佳实践：
// - 提高代码可读性和可维护性
// - 便于单独测试各个视图组件
// - 避免在 build 方法中使用私有方法返回 Widget

/// 加载中视图
class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.colors});

  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: colors.textTertiary,
      ),
    );
  }
}

/// 空状态视图
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.colors});

  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
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
}

/// 错误视图
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.colors,
    required this.error,
    required this.onRetry,
  });

  final AppColorScheme colors;
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
            error,
            style: TextStyle(fontSize: 14, color: colors.textDisabled),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TapScale(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '重试',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 频道列表视图
///
/// 使用 RefreshIndicator 支持下拉刷新。
/// 列表项使用 ChannelItem 组件，传入 UI 状态用于显示未读数等。
class _ChannelListView extends StatelessWidget {
  const _ChannelListView({
    required this.colors,
    required this.channels,
    required this.getUIState,
    required this.onRefresh,
    required this.onChannelTap,
  });

  final AppColorScheme colors;
  final List<ChannelModel> channels;
  final ChannelUIState? Function(String channelId) getUIState;
  final Future<void> Function() onRefresh;
  final void Function(ChannelModel) onChannelTap;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors.textPrimary,
      backgroundColor: colors.surfaceElevated,
      child: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          return ChannelItem(
            channel: channel,
            uiState: getUIState(channel.id),
            onTap: () => onChannelTap(channel),
          );
        },
      ),
    );
  }
}
