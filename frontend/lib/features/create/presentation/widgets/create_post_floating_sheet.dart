import 'package:flutter/material.dart';
import 'package:lesser/shared/theme/theme.dart';
import 'package:lesser/shared/widgets/button.dart';

/// 创建内容的悬浮框组件
class CreatePostFloatingSheet extends StatefulWidget {
  const CreatePostFloatingSheet({super.key});

  @override
  State<CreatePostFloatingSheet> createState() =>
      _CreatePostFloatingSheetState();
}

class _CreatePostFloatingSheetState extends State<CreatePostFloatingSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _selectedImages = [];

  // 选择的内容类型
  String _contentType = '帖子';

  // 可见范围
  String _visibility = '所有人';

  // 发布时间
  String _publishTime = '立即发布';

  // 开关状态
  bool _allowForward = true;
  bool _allowComment = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _addImage() {
    // 实际应用中应该调用图片选择器
    setState(() {
      _selectedImages.add(
        'https://tiebapic.baidu.com/forum/pic/item/962bd40735fae6cd7d3d75004ab30f2442a7d97e.jpg',
      );
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showContentTypeSelector() {
    _showSelector(
      title: '选择内容类型',
      options: ['reels', '帖子', '文章'],
      currentValue: _contentType,
      onSelect: (value) => setState(() => _contentType = value),
    );
  }

  void _showVisibilitySelector() {
    _showSelector(
      title: '选择可见范围',
      options: ['自己', '好友', '粉丝', '所有人'],
      currentValue: _visibility,
      onSelect: (value) => setState(() => _visibility = value),
    );
  }

  void _showPublishTimeSelector() {
    _showSelector(
      title: '选择发布时间',
      options: ['立即发布', '1h 后发布', '1d 后发布', '指定日期发布'],
      currentValue: _publishTime,
      onSelect: (value) => setState(() => _publishTime = value),
    );
  }

  void _showSelector({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl3),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (option) => ListTile(
              title: Text(option),
              trailing: option == currentValue
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : const Icon(
                      Icons.circle_outlined,
                      color: AppColors.mutedForeground,
                    ),
              onTap: () {
                onSelect(option);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl3),
        ),
      ),
      child: Column(
        children: [
          // 顶部拖拽条和关闭按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.foreground,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题输入
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '文字标题',
                      hintStyle: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // 内容输入
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: '内容...',
                      hintStyle: TextStyle(
                        color: AppColors.mutedForeground,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                    maxLines: null,
                  ),

                  // 图片预览
                  if (_selectedImages.isNotEmpty)
                    const SizedBox(height: AppSpacing.md),
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: Image.network(
                                _selectedImages[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: AppSpacing.xs,
                              right: AppSpacing.xs,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 添加图片按钮
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: AppColors.mutedForeground,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            '添加图片',
                            style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 内容类型选择
                  _buildSelectorRow(
                    label: '类型',
                    value: _contentType,
                    onTap: _showContentTypeSelector,
                  ),

                  // 可见范围选择
                  _buildSelectorRow(
                    label: '可见范围',
                    value: _visibility,
                    onTap: _showVisibilitySelector,
                  ),

                  // 发布时间选择
                  _buildSelectorRow(
                    label: '发布时间',
                    value: _publishTime,
                    onTap: _showPublishTimeSelector,
                  ),

                  // 开关选项
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('允许转发'),
                      Switch(
                        value: _allowForward,
                        onChanged: (value) =>
                            setState(() => _allowForward = value),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('允许评论'),
                      Switch(
                        value: _allowComment,
                        onChanged: (value) =>
                            setState(() => _allowComment = value),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 底部发布按钮
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
              color: AppColors.background,
            ),
            child: AppButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('发布'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(color: AppColors.mutedForeground),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
