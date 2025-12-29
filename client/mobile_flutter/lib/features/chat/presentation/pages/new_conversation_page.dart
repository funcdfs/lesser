import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../providers/chat_provider.dart';

class NewConversationPage extends ConsumerStatefulWidget {
  const NewConversationPage({super.key});

  @override
  ConsumerState<NewConversationPage> createState() =>
      _NewConversationPageState();
}

class _NewConversationPageState extends ConsumerState<NewConversationPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _selectedUsers = <User>[];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.length >= 2) {
      ref.read(searchProvider.notifier).searchUsers(query);
    }
  }

  void _toggleUserSelection(User user) {
    setState(() {
      if (_selectedUsers.any((u) => u.id == user.id)) {
        _selectedUsers.removeWhere((u) => u.id == user.id);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _createConversation() async {
    if (_selectedUsers.isEmpty) {
      _showError('请至少选择一位用户');
      return;
    }

    setState(() => _isCreating = true);

    final result = await ref
        .read(newConversationProvider.notifier)
        .create(
          memberIds: _selectedUsers.map((u) => u.id).toList(),
          type: _selectedUsers.length == 1
              ? ConversationType.private
              : ConversationType.group,
        );

    setState(() => _isCreating = false);

    if (result != null && mounted) {
      ref.read(conversationsProvider.notifier).refresh();
      context.pushReplacement(
        RouteConstants.chatRoom.replaceFirst(':id', result.id),
      );
    } else if (mounted) {
      final errorMsg = ref.read(newConversationProvider).errorMessage;
      _showError(errorMsg ?? '创建会话失败，请重试');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('发起新消息'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _isCreating
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _selectedUsers.isEmpty
                        ? null
                        : _createConversation,
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedUsers.isEmpty
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('下一步'),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 收件人区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '收件人：',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  child: _selectedUsers.isEmpty
                      ? TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: const InputDecoration(
                            hintText: '搜索用户...',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: _onSearchChanged,
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._selectedUsers.map(
                              (user) => _buildSelectedChip(user),
                            ),
                            // 内联搜索框
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: const InputDecoration(
                                  hintText: '添加更多',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: _onSearchChanged,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          // 搜索结果
          Expanded(child: _buildSearchResults(searchState)),
        ],
      ),
    );
  }

  Widget _buildSelectedChip(User user) {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            imageUrl: user.avatarUrl,
            name: user.displayName ?? user.username,
            size: 28,
          ),
          const SizedBox(width: 6),
          Text(
            user.displayName ?? user.username,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _toggleUserSelection(user),
            child: const Icon(Icons.close, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    // 初始状态 - 显示引导
    if (_searchController.text.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_1_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '搜索用户开始对话',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '输入用户名或昵称进行搜索',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // 加载中
    if (searchState.status == SearchStatus.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '搜索中...',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    // 搜索出错
    if (searchState.status == SearchStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              searchState.errorMessage ?? '搜索失败',
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _onSearchChanged(_searchController.text),
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 无结果
    if (searchState.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              '未找到 "${_searchController.text}" 相关用户',
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 8),
            const Text(
              '请尝试其他关键词',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // 搜索结果列表
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: searchState.users.length,
      itemBuilder: (context, index) {
        final user = searchState.users[index];
        final isSelected = _selectedUsers.any((u) => u.id == user.id);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: UserAvatar(
            imageUrl: user.avatarUrl,
            name: user.displayName ?? user.username,
            size: 48,
          ),
          title: Text(
            user.displayName ?? user.username,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '@${user.username}',
            style: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
          onTap: () => _toggleUserSelection(user),
        );
      },
    );
  }
}

/// 新会话状态枚举
enum NewConversationStatus { initial, creating, created, error }

/// 新会话状态
class NewConversationState {
  const NewConversationState({
    this.status = NewConversationStatus.initial,
    this.conversation,
    this.errorMessage,
  });

  final NewConversationStatus status;
  final Conversation? conversation;
  final String? errorMessage;
}

/// 新会话状态管理器
class NewConversationNotifier extends Notifier<NewConversationState> {
  late final ChatRepository _repository;

  @override
  NewConversationState build() {
    _repository = getIt<ChatRepository>();
    return const NewConversationState();
  }

  Future<Conversation?> create({
    required List<String> memberIds,
    required ConversationType type,
    String? name,
  }) async {
    state = const NewConversationState(status: NewConversationStatus.creating);

    final result = await _repository.createConversation(
      type: type,
      memberIds: memberIds,
      name: name,
    );

    return result.fold(
      (failure) {
        state = NewConversationState(
          status: NewConversationStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (conversation) {
        state = NewConversationState(
          status: NewConversationStatus.created,
          conversation: conversation,
        );
        return conversation;
      },
    );
  }
}

/// 新会话 Provider
final newConversationProvider = NotifierProvider<NewConversationNotifier, NewConversationState>(
  NewConversationNotifier.new,
);
