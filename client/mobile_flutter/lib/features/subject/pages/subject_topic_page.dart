import 'package:flutter/material.dart';
import '../handler/subject_handler.dart';
import '../data_access/subject_mock_data_source.dart';
import '../models/subject_models.dart';
import '../widgets/post_list_controller.dart';
import '../widgets/post_list_view.dart';
import '../widgets/detail_app_bar.dart';
import 'subject_comment_page.dart';
import '../../../pkg/ui/theme/theme.dart';

/// 话题详情页 - 显示特定话题下的所有消息
class SubjectTopicPage extends StatefulWidget {
  const SubjectTopicPage({
    super.key,
    required this.subjectId,
    required this.topic,
  });

  final String subjectId;
  final SubjectTopicModel topic;

  @override
  State<SubjectTopicPage> createState() => _SubjectTopicPageState();
}

class _SubjectTopicPageState extends State<SubjectTopicPage> {
  late final SubjectHandler _handler;
  late final PostListController _listController;
  late final HighlightController _highlightController;
  final _scrollController = ScrollController();
  final _moreButtonKey = GlobalKey();
  
  SubjectModel? _subject;
  bool _isLoading = true;
  bool _showPosts = false;

  @override
  void initState() {
    super.initState();
    _handler = SubjectHandler(SubjectMockDataSource());
    _listController = PostListController();
    _highlightController = HighlightController(
      scrollController: _scrollController,
      onHighlightChanged: (id) {
        if (mounted) setState(() {});
      },
    );
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listController.dispose();
    _highlightController.dispose();
    _handler.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final subject = await _handler.getSubjectDetail(widget.subjectId);
      final posts = await _handler.getPosts(widget.subjectId, topicId: widget.topic.id);
      
      if (!mounted) return;

      setState(() {
        _subject = subject;
        _isLoading = false;
      });
      _listController.updateCache(posts);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => _showPosts = true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Scaffold(
      backgroundColor: colors.surfaceBase,
      extendBodyBehindAppBar: true,
      appBar: DetailAppBar(
        series: _subject,
        seriesId: widget.subjectId,
        moreButtonKey: _moreButtonKey,
        onBack: () => Navigator.of(context).pop(),
        onMoreTap: () {
          // TODO: Implement more menu
        },
      ),
      body: Stack(
        children: [
          _buildContent(),
          if (_isLoading && !_showPosts)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (!_showPosts && _isLoading) return const SizedBox.shrink();

    return PostListView(
      listController: _listController,
      scrollController: _scrollController,
      highlightController: _highlightController,
      highlightedPostId: null,
      topPadding: MediaQuery.paddingOf(context).top + kToolbarHeight,
      onHighlightComplete: () {},
      onCommentTap: (post) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectCommentPage(
              postId: post.id,
              subjectId: widget.subjectId,
              post: post,
            ),
          ),
        );
      },
      onMenuAction: (action, post) {
        // Handle menu action
      },
      onReactionTap: (emoji) {},
      onDateSelected: (date) {},
    );
  }
}
