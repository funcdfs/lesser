import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../feeds/domain/entities/feed_item.dart';
import '../providers/post_provider.dart';
import '../widgets/post_type_selector.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final state = ref.read(createPostProvider);
      ref.read(createPostProvider.notifier).createPost(
            content: _contentController.text.trim(),
            title: state.selectedPostType == PostType.column
                ? _titleController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final createPostState = ref.watch(createPostProvider);

    ref.listen<CreatePostState>(createPostProvider, (previous, next) {
      if (next.status == CreatePostStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        ref.read(createPostProvider.notifier).reset();
        context.pop();
      } else if (next.status == CreatePostStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: createPostState.status == CreatePostStatus.loading
                  ? null
                  : _handleSubmit,
              child: createPostState.status == CreatePostStatus.loading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post type selector
              Text(
                'Post Type',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              PostTypeSelector(
                selectedType: createPostState.selectedPostType,
                onTypeSelected: (type) {
                  ref.read(createPostProvider.notifier).selectPostType(type);
                },
              ),
              const SizedBox(height: 24),
              // Title field (only for column)
              if (createPostState.selectedPostType == PostType.column) ...[
                Text(
                  'Title',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter title...',
                  ),
                  validator: Validators.validateColumnTitle,
                  maxLength: AppConstants.maxColumnTitleLength,
                ),
                const SizedBox(height: 16),
              ],
              // Content field
              Text(
                'Content',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: _getContentHint(createPostState.selectedPostType),
                  alignLabelWithHint: true,
                ),
                maxLines: createPostState.selectedPostType == PostType.column
                    ? 15
                    : 5,
                maxLength: createPostState.selectedPostType == PostType.short
                    ? AppConstants.maxShortPostLength
                    : null,
                validator: createPostState.selectedPostType == PostType.short
                    ? Validators.validateShortPost
                    : (value) => Validators.validateRequired(value, 'Content'),
              ),
              const SizedBox(height: 16),
              // Info text
              _buildInfoText(createPostState.selectedPostType),
            ],
          ),
        ),
      ),
    );
  }

  String _getContentHint(PostType type) {
    switch (type) {
      case PostType.story:
        return 'Share a moment (disappears in 24h)...';
      case PostType.short:
        return "What's happening?";
      case PostType.column:
        return 'Write your article...';
    }
  }

  Widget _buildInfoText(PostType type) {
    String info;
    IconData icon;
    Color color;

    switch (type) {
      case PostType.story:
        info = 'Stories disappear after 24 hours';
        icon = Icons.timer_outlined;
        color = AppColors.warning;
        break;
      case PostType.short:
        info = 'Short posts are limited to ${AppConstants.maxShortPostLength} characters';
        icon = Icons.short_text;
        color = AppColors.info;
        break;
      case PostType.column:
        info = 'Columns are long-form articles with a title';
        icon = Icons.article_outlined;
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
