import 'package:flutter/material.dart';

/// 通知组件
///
/// 显示：
/// - 与用户相关的通知（如被关注、被提及）
/// - 与帖子相关的通知（如点赞、评论）
class NotifyWidget extends StatelessWidget {
  const NotifyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Notifications',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_add)),
              title: const Text('User followed you'),
              subtitle: const Text('2 minutes ago'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {},
              ),
            );
          },
        ),
      ],
    );
  }
}
