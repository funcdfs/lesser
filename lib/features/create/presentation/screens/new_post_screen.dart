import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../../shared/widgets/button.dart';

/// 发布页面
class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isPostButtonEnabled = false;
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    // 监听文本变化以启用/禁用发布按钮
    _textController.addListener(() {
      final isEnabled = _textController.text.isNotEmpty;
      if (isEnabled != _isPostButtonEnabled) {
        setState(() {
          _isPostButtonEnabled = isEnabled;
        });
      }
    });

    // 动画显示内容，感觉更平滑
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isContentVisible = true);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '取消',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
          ),
        ),
        title: Text(
          '新建串文',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_add_outlined),
            onPressed: () {},
            color: theme.colorScheme.onSurface,
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
            color: theme.colorScheme.onSurface,
          ),
        ],
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedOpacity(
        opacity: _isContentVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(child: _buildPostContent(context)),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Avatar(
          avatarUrl: 'https://via.placeholder.com/150',
          fallbackInitials: 'F',
          size: 40,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'funcdfs',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' › 添加话题',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16),
                  maxLines: null, // 允许多行输入
                  decoration: const InputDecoration(
                    hintText: '有什么新鲜事吗?',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.mutedForeground),
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionIcons(),
                const Divider(color: AppColors.border, height: 32),
                Row(
                  children: const [
                    Avatar(
                      avatarUrl: 'https://via.placeholder.com/150',
                      fallbackInitials: 'F',
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '添加到串文',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcons() {
    const iconColor = AppColors.mutedForeground;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.photo_outlined, color: iconColor),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'GIF',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.emoji_emotions_outlined, color: iconColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.format_list_bulleted, color: iconColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.location_on_outlined, color: iconColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.sync_alt, color: AppColors.mutedForeground),
            label: const Text(
              '回复选项',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
            onPressed: () {},
          ),
          AppButton(
            // 文本为空时禁用按钮
            onPressed: _isPostButtonEnabled
                ? () {
                    // TODO: 实现发布逻辑
                    Navigator.of(context).pop();
                  }
                : () {},
            child: const Text('发布'),
          ),
        ],
      ),
    );
  }
}
