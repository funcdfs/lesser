import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user.dart';

class UserSearchItem extends StatelessWidget {
  const UserSearchItem({
    super.key,
    required this.user,
    this.onTap,
    this.onFollow,
  });

  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(color: AppColors.textSecondaryLight),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onFollow != null)
              OutlinedButton(onPressed: onFollow, child: const Text('Follow')),
          ],
        ),
      ),
    );
  }
}
