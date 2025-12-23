import 'package:flutter/material.dart';

/// 通知屏幕 (Notification Screen)
///
/// 展示用户的各种通知提醒，包括：
/// 1. 消息、私信提醒。
/// 2. 帖子的点赞、评论、转发通知。
/// 3. 系统公告及其他交互提醒。
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通知')),
      body: const Center(child: Text('通知中心：展示消息、点赞、评论等互动信息')),
    );
  }
}
