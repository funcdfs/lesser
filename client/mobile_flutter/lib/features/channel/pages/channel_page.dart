// 频道列表页

import 'package:flutter/material.dart';
import '../../../pkg/ui/effects/effects.dart';
import '../../../pkg/ui/theme/theme.dart';
import '../handler/channel_handler.dart';
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
  final _handler = ChannelHandler();
  List<ChannelModel> _channels = [];
  bool _isLoading = true;

  // 标签相关（参考 note.com 分类）
  final List<ChannelTag> _tags = const [
    // 娱乐
    ChannelTag(id: '1', name: 'エンタメ', icon: '🎬'),
    ChannelTag(id: '2', name: 'ゲーム', icon: '🎮'),
    ChannelTag(id: '3', name: 'マンガ', icon: '📚'),
    ChannelTag(id: '4', name: '音楽', icon: '🎵'),
    ChannelTag(id: '5', name: 'アニメ', icon: '🎌'),
    ChannelTag(id: '6', name: '映画', icon: '🎥'),
    // 创作
    ChannelTag(id: '7', name: 'コラム', icon: '✍️'),
    ChannelTag(id: '8', name: '小説', icon: '📝'),
    ChannelTag(id: '9', name: 'エッセイ', icon: '📄'),
    ChannelTag(id: '10', name: 'ポエム', icon: '🌸'),
    // 技术
    ChannelTag(id: '11', name: 'テクノロジー', icon: '💻'),
    ChannelTag(id: '12', name: 'プログラミング', icon: '⌨️'),
    ChannelTag(id: '13', name: 'AI', icon: '🤖'),
    ChannelTag(id: '14', name: 'Web3', icon: '🔗'),
    // 商业
    ChannelTag(id: '15', name: 'ビジネス', icon: '💼'),
    ChannelTag(id: '16', name: 'マーケティング', icon: '📊'),
    ChannelTag(id: '17', name: '起業', icon: '🚀'),
    ChannelTag(id: '18', name: '投資', icon: '📈'),
    // 生活
    ChannelTag(id: '19', name: 'ライフスタイル', icon: '🌿'),
    ChannelTag(id: '20', name: 'フード', icon: '🍜'),
    ChannelTag(id: '21', name: '料理', icon: '🍳'),
    ChannelTag(id: '22', name: 'カフェ', icon: '☕'),
    ChannelTag(id: '23', name: 'トラベル', icon: '✈️'),
    ChannelTag(id: '24', name: '海外生活', icon: '🌍'),
    // 运动健康
    ChannelTag(id: '25', name: 'スポーツ', icon: '⚽'),
    ChannelTag(id: '26', name: 'フィットネス', icon: '💪'),
    ChannelTag(id: '27', name: 'ランニング', icon: '🏃'),
    ChannelTag(id: '28', name: 'ヨガ', icon: '🧘'),
    // 时尚美容
    ChannelTag(id: '29', name: 'ファッション', icon: '👗'),
    ChannelTag(id: '30', name: 'コスメ', icon: '💄'),
    ChannelTag(id: '31', name: 'ネイル', icon: '💅'),
    // 艺术设计
    ChannelTag(id: '32', name: 'アート', icon: '🎨'),
    ChannelTag(id: '33', name: '写真', icon: '📷'),
    ChannelTag(id: '34', name: 'デザイン', icon: '✨'),
    ChannelTag(id: '35', name: 'イラスト', icon: '🖼️'),
    // 学习
    ChannelTag(id: '36', name: '教育', icon: '📖'),
    ChannelTag(id: '37', name: '語学', icon: '🗣️'),
    ChannelTag(id: '38', name: '資格', icon: '📜'),
    // 其他
    ChannelTag(id: '39', name: 'ペット', icon: '🐱'),
    ChannelTag(id: '40', name: 'DIY', icon: '🔧'),
    ChannelTag(id: '41', name: '子育て', icon: '👶'),
    ChannelTag(id: '42', name: '恋愛', icon: '💕'),
    ChannelTag(id: '43', name: '占い', icon: '🔮'),
    ChannelTag(id: '44', name: 'メンタル', icon: '🧠'),
  ];
  final Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    final channels = await _handler.getChannels();
    if (mounted) {
      setState(() {
        _channels = channels;
        _isLoading = false;
      });
    }
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
              : _channels.isEmpty
              ? _buildEmpty(colors)
              : _buildList(colors),
        ),
        // 使用统一的 ChannelTagDrawer 组件
        ChannelTagDrawer(
          tags: _tags,
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
