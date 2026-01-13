// 链接预览组件
//
// 异步加载并显示链接预览卡片

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/effects/effects.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/loading_dots.dart';
import '../link_parser.dart';
import '../link_service.dart';
import '../link_utils.dart';
import '../models/link_model.dart';
import 'link_action_sheet.dart';

/// 链接预览组件
///
/// 异步加载链接元数据并显示预览卡片
/// 支持点击跳转和长按操作菜单
class LinkPreview extends StatefulWidget {
  const LinkPreview({
    super.key,
    required this.url,
    this.onTap,
    this.onLongPress,
    this.showActionSheet = true,
    this.compact = false,
  });

  /// 链接 URL
  final String url;

  /// 点击回调（不提供则使用 LinkService 导航）
  final VoidCallback? onTap;

  /// 长按回调（不提供则显示操作菜单）
  final VoidCallback? onLongPress;

  /// 是否显示操作菜单（长按时）
  final bool showActionSheet;

  /// 是否使用紧凑模式
  final bool compact;

  @override
  State<LinkPreview> createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  LinkModel? _link;
  LinkMetadata? _metadata;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  @override
  void didUpdateWidget(LinkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadMetadata();
    }
  }

  Future<void> _loadMetadata() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // 解析 URL
    final link = LinkParser.parse(widget.url);
    if (link == null) {
      setState(() {
        _link = null;
        _metadata = null;
        _isLoading = false;
        _error = '无效的链接';
      });
      return;
    }

    // 获取元数据
    try {
      final metadata = await LinkService.instance.getMetadata(widget.url);
      if (mounted) {
        setState(() {
          _link = link;
          _metadata = metadata ?? LinkMetadata.empty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _link = link;
          _metadata = LinkMetadata.empty;
          _isLoading = false;
          _error = '加载失败';
        });
      }
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    HapticFeedback.lightImpact();
    if (LinkService.instance.isInitialized) {
      LinkService.instance.navigate(context, widget.url);
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      widget.onLongPress!();
      return;
    }

    if (widget.showActionSheet) {
      LinkActionSheet.show(
        context,
        url: widget.url,
        onOpen: _handleTap,
        onCopy: () => LinkUtils.copyWithFeedback(context, widget.url),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (_isLoading) {
      return _buildLoading(colors);
    }

    if (_error != null && _link == null) {
      return _buildError(colors);
    }

    if (widget.compact) {
      return _buildCompact(colors);
    }

    return _buildFull(colors);
  }

  /// 构建加载状态
  Widget _buildLoading(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingDots.mini(color: colors.textDisabled),
          const SizedBox(width: 8),
          Text(
            '加载中...',
            style: TextStyle(fontSize: 13, color: colors.textDisabled),
          ),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildError(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 16, color: colors.error),
          const SizedBox(width: 8),
          Text(
            _error ?? '加载失败',
            style: TextStyle(fontSize: 13, color: colors.error),
          ),
        ],
      ),
    );
  }

  /// 构建紧凑模式
  Widget _buildCompact(AppColorScheme colors) {
    final icon = _link != null
        ? LinkUtils.getIconForType(_link!.targetType)
        : Icons.link_rounded;
    final displayText = _buildDisplayText();

    return GestureDetector(
      onLongPress: _handleLongPress,
      child: TapScale(
        onTap: _handleTap,
        scale: TapScales.small,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.accentSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colors.accent.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: colors.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建完整模式
  Widget _buildFull(AppColorScheme colors) {
    final icon = _link != null
        ? LinkUtils.getIconForType(_link!.targetType)
        : Icons.link_rounded;
    final isDeleted = _metadata?.isDeleted ?? false;

    return GestureDetector(
      onLongPress: _handleLongPress,
      child: TapScale(
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (isDeleted ? colors.textDisabled : colors.accent)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDeleted ? colors.textDisabled : colors.accent,
                ),
              ),
              const SizedBox(width: 10),
              // 内容
              Flexible(child: _buildContent(colors)),
              const SizedBox(width: 6),
              // 箭头
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(AppColorScheme colors) {
    final isDeleted = _metadata?.isDeleted ?? false;
    final typeLabel = _link != null
        ? LinkUtils.getLabelForType(_link!.targetType)
        : '链接';
    final displayText = _buildDisplayText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 类型标签
        Text(
          typeLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textTertiary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        // 内容预览
        Text(
          displayText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: isDeleted ? colors.textDisabled : colors.textSecondary,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建显示文本
  String _buildDisplayText() {
    if (_metadata?.isDeleted ?? false) return '内容已删除';

    final parts = <String>[];

    // 添加频道名称
    if (_metadata?.channelName != null && _metadata!.channelName!.isNotEmpty) {
      parts.add('频道: ${_metadata!.channelName}');
    }

    // 添加内容预览
    if (_metadata?.contentPreview != null &&
        _metadata!.contentPreview!.isNotEmpty) {
      final typeLabel = _link != null
          ? _getContentTypeLabel(_link!.targetType)
          : '内容';
      parts.add('$typeLabel: ${_metadata!.contentPreview}');
    }

    // 如果没有任何内容，显示作者名称
    if (parts.isEmpty && _metadata?.authorName != null) {
      parts.add(_metadata!.authorName!);
    }

    // 如果还是空的，显示默认文本
    if (parts.isEmpty) {
      return '查看详情';
    }

    return parts.join(' · ');
  }

  /// 获取内容类型标签
  String _getContentTypeLabel(LinkContentType type) {
    return switch (type) {
      LinkContentType.comment => '评论',
      LinkContentType.message => '消息',
      LinkContentType.post => '帖子',
      _ => '内容',
    };
  }
}
