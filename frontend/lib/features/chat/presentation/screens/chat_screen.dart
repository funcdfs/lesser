import 'package:flutter/material.dart';
import 'package:lesser/features/chat/presentation/widgets/notify.dart';
import 'package:lesser/features/chat/presentation/widgets/network_neighbors.dart';
import 'package:lesser/features/chat/presentation/widgets/chat_item.dart';
import 'package:lesser/features/chat/presentation/widgets/section_header.dart';
import '../../../../shared/theme/theme.dart';

/// 会话组件的大框架
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Message',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[const SliverToBoxAdapter(child: NotifyWidget())];
        },
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: _buildChatList()),
            const SliverToBoxAdapter(child: NetworkNeighborsWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SectionHeader(title: '聊天'),
        ChatItem(
          icon: Icons.people_outline,
          iconColor: Colors.blue,
          title: 'Group Chat',
          subtitle: '最新消息预览...',
          time: '10:30',
          unreadCount: 5,
        ),
        ChatItem(
          icon: Icons.campaign_outlined,
          iconColor: Colors.orange,
          title: 'Channel',
          subtitle: '频道消息更新',
          time: '昨天',
          unreadCount: 2,
          isMuted: true,
        ),
        ChatItem(
          icon: Icons.person_outline,
          iconColor: Colors.green,
          title: 'Private Chat',
          subtitle: '你好啊',
          time: '12:00',
        ),
      ],
    );
  }
}
