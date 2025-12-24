import 'package:flutter/material.dart';

/// 聊天项目
///
/// 显示单个聊天会话：
/// - Channel（频道）
/// - Private（私聊）
/// - Group（群组）
class ChatItem extends StatelessWidget {
  /// 聊天类型
  final ChatType type;

  /// 聊天名称
  final String name;

  /// 最后消息
  final String lastMessage;

  /// 未读消息数
  final int unreadCount;

  const ChatItem({
    super.key,
    this.type = ChatType.private,
    this.name = 'Chat Name',
    this.lastMessage = 'Last message...',
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatar(),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        // 打开聊天详情
      },
    );
  }

  Widget _buildAvatar() {
    switch (type) {
      case ChatType.channel:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue),
          ),
          child: const Icon(Icons.tag, color: Colors.blue),
        );
      case ChatType.private:
        return const CircleAvatar(child: Icon(Icons.person));
      case ChatType.group:
        return Stack(
          alignment: Alignment.center,
          children: [const CircleAvatar(child: Icon(Icons.people))],
        );
    }
  }
}

/// 聊天类型
enum ChatType {
  /// 频道
  channel,

  /// 私聊
  private,

  /// 群组
  group,
}
