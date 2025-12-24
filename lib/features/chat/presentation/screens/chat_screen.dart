import 'package:flutter/material.dart';
import '../widgets/notify.dart';
import '../widgets/chat_item.dart';
import '../widgets/network_neighbors.dart';

/// 会话组件的大框架
///
/// 显示：
/// - 上方的通知部分（通知用户和帖子相关的部分）
/// - 中间的聊天列表（Channel、Private、Group 三种类型）
/// - 下方的网络邻居部分（我的好友、我的粉丝、创建群组等外显）
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
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 新建会话
            },
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: const [
          // 通知部分 - 显示与用户和帖子相关的通知
          NotifyWidget(),
          Divider(height: 1),
          // 聊天列表 - 显示所有聊天会话
          ChatListSection(),
          // 网络邻居部分 - 显示好友、粉丝、创建群组等
          NetworkNeighborsWidget(),
        ],
      ),
    );
  }
}

/// 聊天列表部分
class ChatListSection extends StatelessWidget {
  const ChatListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search messages...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            return const ChatItem();
          },
        ),
      ],
    );
  }
}
