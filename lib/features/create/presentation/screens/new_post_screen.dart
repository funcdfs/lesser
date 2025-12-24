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

  // 新增状态
  final List<String> _selectedImages = [];
  String? _selectedTopic;
  String _replySetting = '所有人';
  static const int _maxChars = 280;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isContentVisible = true);
    });
  }

  void _onTextChanged() {
    final isEnabled =
        _textController.text.isNotEmpty || _selectedImages.isNotEmpty;
    if (isEnabled != _isPostButtonEnabled) {
      setState(() {
        _isPostButtonEnabled = isEnabled;
      });
    } else {
      setState(() {}); // 触发 UI 更新（例如字符计数器）
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addMockImage() {
    setState(() {
      _selectedImages.add(
        'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/400',
      );
    });
    _onTextChanged();
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    _onTextChanged();
  }

  void _showReplySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReplySettingsSheet(
        currentSetting: _replySetting,
        onChanged: (val) => setState(() => _replySetting = val),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        leading: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildPostContent(context),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Avatar(
              avatarUrl: 'https://via.placeholder.com/150',
              fallbackInitials: 'F',
              size: 40,
            ),
            const SizedBox(height: 8),
            // 连接线效果（模拟串文）
            Container(
              width: 2,
              height: 40,
              color: AppColors.border.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            const Opacity(
              opacity: 0.5,
              child: Avatar(
                avatarUrl: 'https://via.placeholder.com/150',
                fallbackInitials: 'F',
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'funcdfs',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedTopic == null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedTopic = '话题'),
                      child: const Text(
                        ' › 添加话题',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTopic = null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$_selectedTopic',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              TextField(
                controller: _textController,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '有什么新鲜事吗?',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.mutedForeground),
                ),
              ),
              if (_selectedImages.isNotEmpty) _buildImagePreviews(),
              const SizedBox(height: 12),
              _buildActionIcons(),
              const SizedBox(height: 16),
              _buildAddThreadButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviews() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _selectedImages[index],
                  height: 200,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddThreadButton() {
    return Row(
      children: const [
        Opacity(
          opacity: 0.5,
          child: Avatar(
            avatarUrl: 'https://via.placeholder.com/150',
            fallbackInitials: 'F',
            size: 24,
          ),
        ),
        SizedBox(width: 8),
        Text('添加到串文', style: TextStyle(color: AppColors.mutedForeground)),
      ],
    );
  }

  Widget _buildActionIcons() {
    const iconColor = AppColors.mutedForeground;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.photo_outlined, color: iconColor, size: 24),
          onPressed: _addMockImage,
        ),
        IconButton(
          icon: const Icon(Icons.alternate_email, color: iconColor, size: 24),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.tag_outlined, color: iconColor, size: 24),
          onPressed: () => setState(() => _selectedTopic = '探索'),
        ),
        IconButton(
          icon: const Icon(
            Icons.emoji_emotions_outlined,
            color: iconColor,
            size: 24,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.location_on_outlined,
            color: iconColor,
            size: 24,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final charCount = _textController.text.length;
    final isOverLimit = charCount > _maxChars;
    final progress = charCount / _maxChars;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 8,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _showReplySettings,
            child: Row(
              children: [
                const Icon(
                  Icons.public,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  '谁可以回复: $_replySetting',
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (charCount > 0) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: progress > 1 ? 1 : progress,
                    strokeWidth: 2,
                    backgroundColor: AppColors.border,
                    color: isOverLimit
                        ? Colors.red
                        : (progress > 0.9 ? Colors.orange : Colors.blue),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              AppButton(
                onPressed: _isPostButtonEnabled && !isOverLimit
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : () {}, // 提供空函数以符合非空要求
                child: const Text('发布'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplySettingsSheet extends StatelessWidget {
  final String currentSetting;
  final ValueChanged<String> onChanged;

  const _ReplySettingsSheet({
    required this.currentSetting,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = ['所有人', '你关注的人', '仅限提及的人'];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '谁可以回复',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (option) => ListTile(
              title: Text(option),
              trailing: currentSetting == option
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                onChanged(option);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
