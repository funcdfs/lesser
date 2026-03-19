// 表情面板 Shell
//
// UI 框架：键盘高度面板，顶部分类 tab + 底部类型 tab
// 后续补充真正的 emoji 选择功能

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';

/// 表情面板默认高度（模拟键盘高度）
const _kPanelHeight = 260.0;

/// 表情分类
enum _EmojiCategory {
  recent(Icons.access_time_rounded, '最近'),
  smileys(Icons.emoji_emotions_rounded, '笑脸'),
  animals(Icons.pets_rounded, '动物'),
  food(Icons.restaurant_rounded, '水果');

  const _EmojiCategory(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// 表情类型
enum _EmojiType {
  emoji('Emoji'),
  gif('动态图'),
  sticker('贴纸');

  const _EmojiType(this.label);
  final String label;
}

/// 表情面板
class EmojiPanel extends StatefulWidget {
  const EmojiPanel({
    super.key,
    this.onEmojiSelected,
  });

  final void Function(String emoji)? onEmojiSelected;

  @override
  State<EmojiPanel> createState() => _EmojiPanelState();
}

class _EmojiPanelState extends State<EmojiPanel> {
  _EmojiCategory _selectedCategory = _EmojiCategory.smileys;
  _EmojiType _selectedType = _EmojiType.emoji;

  // 示例 emoji 数据（占位）
  static const _sampleEmojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
    '🙂', '🙃', '😉', '😊', '😇', '🥰', '😍', '🤩',
    '😘', '😗', '😚', '😙', '🥲', '😋', '😛', '😜',
    '🤪', '😝', '🤗', '🤭', '🫢', '🤫', '🤔', '🫡',
    '🤐', '🤨', '😐', '😑', '😶', '🫥', '😏', '😒',
    '🙄', '😬', '🤥', '🫠', '😌', '😔', '😪', '🤤',
    '😴', '😷', '🤒', '🤕', '🤢', '🤮', '🤧', '🥵',
  ];

  static const _animalEmojis = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
    '🐻‍❄️', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵',
  ];

  static const _foodEmojis = [
    '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓',
    '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝',
  ];

  List<String> get _currentEmojis {
    switch (_selectedCategory) {
      case _EmojiCategory.recent:
        return _sampleEmojis.take(16).toList();
      case _EmojiCategory.smileys:
        return _sampleEmojis;
      case _EmojiCategory.animals:
        return _animalEmojis;
      case _EmojiCategory.food:
        return _foodEmojis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: _kPanelHeight,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          // 顶部分类 tab
          _CategoryTabs(
            selected: _selectedCategory,
            onChanged: (cat) => setState(() => _selectedCategory = cat),
          ),
          // Emoji grid
          Expanded(
            child: _selectedType == _EmojiType.emoji
                ? _EmojiGrid(
                    emojis: _currentEmojis,
                    onTap: widget.onEmojiSelected,
                  )
                : _PlaceholderContent(
                    icon: _selectedType == _EmojiType.gif
                        ? Icons.gif_box_rounded
                        : Icons.sticky_note_2_rounded,
                    label: '${_selectedType.label}功能开发中',
                  ),
          ),
          // 底部类型 tab
          _TypeTabs(
            selected: _selectedType,
            onChanged: (type) => setState(() => _selectedType = type),
          ),
        ],
      ),
    );
  }
}

/// 顶部分类 tab
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onChanged});

  final _EmojiCategory selected;
  final ValueChanged<_EmojiCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _EmojiCategory.values.map((cat) {
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onChanged(cat),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                cat.icon,
                size: 20,
                color: isSelected ? colors.accent : colors.textDisabled,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Emoji 网格
class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({required this.emojis, this.onTap});

  final List<String> emojis;
  final void Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return GestureDetector(
          onTap: () => onTap?.call(emoji),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
        );
      },
    );
  }
}

/// 占位内容
class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colors.textDisabled),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// 底部类型 tab
class _TypeTabs extends StatelessWidget {
  const _TypeTabs({required this.selected, required this.onChanged});

  final _EmojiType selected;
  final ValueChanged<_EmojiType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      top: false,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: _EmojiType.values.map((type) {
            final isSelected = type == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(type),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? colors.accent : colors.textTertiary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
