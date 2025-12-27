import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/validation/validation_rules.dart';
import '../../../../core/validation/validators.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/create_post_provider.dart';
import '../providers/draft_provider.dart';
import '../widgets/character_counter.dart';

/// 发布页面
class NewPostScreen extends ConsumerStatefulWidget {
  const NewPostScreen({super.key});

  @override
  ConsumerState<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends ConsumerState<NewPostScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isPostButtonEnabled = false;
  bool _isContentVisible = false;
  bool _isTyping = false;

  // 新增状态
  final List<String> _selectedImages = [];
  String? _selectedTopic;
  String _replySetting = '所有人';
  static final int _maxChars = ValidationRules.maxPostContentLength;
  String? _validationError;
  String? _draftId; // ID of the draft being edited
  bool _isSavingDraft = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isContentVisible = true);
    });
  }

  void _onFocusChanged() {
    setState(() {
      _isTyping = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    final text = _textController.text;
    final isEnabled = text.isNotEmpty || _selectedImages.isNotEmpty;
    
    // Validate content
    final error = Validators.validatePostContent(text.isEmpty ? null : text);
    
    setState(() {
      _isPostButtonEnabled = isEnabled;
      _validationError = text.isNotEmpty ? error : null;
    });
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
        'https://tiebapic.baidu.com/forum/pic/item/962bd40735fae6cd7d3d75004ab30f2442a7d97e.jpg',
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
          child: AppButton.text(
            text: '取消',
            onPressed: () => Navigator.of(context).pop(),
            size: AppButtonSize.medium,
          ),
        ),
        title: Text(
          '新建串文',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
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
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedOpacity(
        opacity: _isContentVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
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
            const Avatar(avatarUrl: '', fallbackInitials: 'F', size: 40),
            const SizedBox(height: 8),
            // 连接线效果（模拟串文）
            Container(
              width: 2,
              height: 40,
              color: AppColors.border.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            const Opacity(
              opacity: 0.5,
              child: Avatar(avatarUrl: '', fallbackInitials: 'F', size: 20),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (_selectedTopic == null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedTopic = '话题'),
                      child: Text(
                        '› 添加话题',
                        style: TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 15,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTopic = null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '#$_selectedTopic',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
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
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '有什么新鲜事吗?',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 16,
                  ),
                  contentPadding: EdgeInsets.only(top: 8, bottom: 8),
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
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  _selectedImages[index],
                  height: 200,
                  width: 150,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      width: 150,
                      color: AppColors.muted,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: 150,
                    color: AppColors.muted,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 32,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: InkWell(
                    onTap: () => _removeImage(index),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
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
      children: [
        Opacity(
          opacity: 0.5,
          child: const Avatar(avatarUrl: '', fallbackInitials: 'F', size: 24),
        ),
        const SizedBox(width: 8),
        Text(
          '添加到串文',
          style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
        ),
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
          splashRadius: 24,
        ),
        IconButton(
          icon: const Icon(Icons.alternate_email, color: iconColor, size: 24),
          onPressed: () {},
          splashRadius: 24,
        ),
        IconButton(
          icon: const Icon(Icons.tag_outlined, color: iconColor, size: 24),
          onPressed: () => setState(() => _selectedTopic = '探索'),
          splashRadius: 24,
        ),
        IconButton(
          icon: const Icon(
            Icons.emoji_emotions_outlined,
            color: iconColor,
            size: 24,
          ),
          onPressed: () {},
          splashRadius: 24,
        ),
        IconButton(
          icon: const Icon(
            Icons.location_on_outlined,
            color: iconColor,
            size: 24,
          ),
          onPressed: () {},
          splashRadius: 24,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final content = _textController.text;
    
    // Validate content before submission
    final validationError = Validators.validatePostContent(content);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.error(message: validationError),
      );
      return;
    }
    
    try {
      await ref.read(createPostProvider.notifier).createPost(
        content: content,
        location: null, // 暂时不支持位置信息
      );
      
      // Delete draft if it was being edited
      if (_draftId != null) {
        await ref.read(draftsProvider.notifier).deleteDraft(_draftId!);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.success(message: '发布成功'),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.error(message: '发布失败，请重试'),
        );
      }
    }
  }

  Future<void> _handleSaveDraft() async {
    final content = _textController.text;
    
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.error(message: '内容不能为空'),
      );
      return;
    }
    
    setState(() => _isSavingDraft = true);
    
    try {
      await ref.read(draftsProvider.notifier).saveDraft(
        id: _draftId,
        content: content,
        location: null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.success(message: '草稿已保存'),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.error(message: '保存草稿失败'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingDraft = false);
      }
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final charCount = _textController.text.length;
    final isOverLimit = charCount > _maxChars;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          if (_isTyping)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _showReplySettings,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
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
                    style: TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              if (charCount > 0) ...[
                CharacterCounter(
                  currentLength: charCount,
                  maxLength: _maxChars,
                ),
                const SizedBox(width: 12),
              ],
              // Save draft button
              IconButton(
                icon: _isSavingDraft
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                onPressed: _isSavingDraft || _textController.text.trim().isEmpty
                    ? null
                    : _handleSaveDraft,
                tooltip: '保存草稿',
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              AppButton.primary(
                text: '发布',
                onPressed: _isPostButtonEnabled && !isOverLimit && _validationError == null
                    ? () => _handleSubmit()
                    : null,
                size: AppButtonSize.medium,
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '谁可以回复',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          ...options.map(
            (option) => ListTile(
              title: Text(option, style: const TextStyle(fontSize: 16)),
              trailing: currentSetting == option
                  ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 24,
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      size: 24,
                      color: AppColors.mutedForeground,
                    ),
              onTap: () {
                onChanged(option);
                Navigator.pop(context);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              minVerticalPadding: 16,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
