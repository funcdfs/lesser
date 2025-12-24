import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../common/widgets/shadcn/shadcn_avatar.dart';
import '../../common/widgets/shadcn/shadcn_button.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isPostButtonEnabled = false;
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    // Add listener to enable/disable the publish button
    _textController.addListener(() {
      final isEnabled = _textController.text.isNotEmpty;
      if (isEnabled != _isPostButtonEnabled) {
        setState(() {
          _isPostButtonEnabled = isEnabled;
        });
      }
    });

    // Animate content in for a smoother feel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isContentVisible = true);
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
          child: Text('取消', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16)),
        ),
        title: Text('新建串文', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
              Expanded(
                child: _buildPostContent(context),
              ),
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
        ShadcnAvatar(
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
                    Text('funcdfs', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(' › 添加话题', style: TextStyle(color: AppColors.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  autofocus: true,
                  style: const TextStyle(fontSize: 16),
                  maxLines: null, // Allows for multiline input
                  decoration: InputDecoration(
                    hintText: '有什么新鲜事吗?',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.mutedForeground),
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionIcons(),
                Divider(color: AppColors.border, height: 32),
                Row(
                  children: [
                    ShadcnAvatar(
                      avatarUrl: 'https://via.placeholder.com/150',
                      fallbackInitials: 'F',
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text('添加到串文', style: TextStyle(color: AppColors.mutedForeground)),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcons() {
    final iconColor = AppColors.mutedForeground;
    return Row(
      children: [
        IconButton(icon: Icon(Icons.photo_outlined, color: iconColor), onPressed: () {}),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('GIF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const SizedBox(width: 4),
        IconButton(icon: Icon(Icons.emoji_emotions_outlined, color: iconColor), onPressed: () {}),
        IconButton(icon: Icon(Icons.format_list_bulleted, color: iconColor), onPressed: () {}),
        IconButton(icon: Icon(Icons.location_on_outlined, color: iconColor), onPressed: () {}),
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
            icon: Icon(Icons.sync_alt, color: AppColors.mutedForeground),
            label: Text('回复选项', style: TextStyle(color: AppColors.mutedForeground)),
            onPressed: () {},
          ),
          ShadcnButton(
            // Disable button when text is empty
            onPressed: _isPostButtonEnabled
                ? () {
                    // TODO: Implement post logic
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
