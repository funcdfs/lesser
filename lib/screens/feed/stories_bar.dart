import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../config/shadcn_theme.dart';
import '../../widgets/shadcn/shadcn_avatar.dart';
import 'story_view_screen.dart';

class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          120, // Increased height for better spacing and to prevent overflow
      decoration: const BoxDecoration(
        color: ShadcnColors.background,
        border: Border(
          bottom: BorderSide(color: ShadcnColors.border, width: 0.5),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: mockFollowingUsers.length + 1, // +1 for "My Story"
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _MyStoryItem();
          }
          final user = mockFollowingUsers[index - 1];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false, // Important for transparent background
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      StoryViewScreen(
                        users: mockFollowingUsers,
                        initialUserIndex: index - 1,
                      ),
                ),
              );
            },
            child: _StoryItem(
              name: user.name,
              imageUrl: user.avatar,
              hasUnseenStory: index % 3 != 0, // Mock unseen status
            ),
          );
        },
      ),
    );
  }
}

class _MyStoryItem extends StatelessWidget {
  const _MyStoryItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 68, // slightly larger to include border visual weight
          height: 68,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ShadcnColors.border,
              width:
                  1, // Dashed border is hard in basic Flutter without packages, solid is fine for now
              style: BorderStyle.solid,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: ShadcnColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              size: 28,
              color: ShadcnColors.foreground,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '发状态',
          style: TextStyle(fontSize: 12, color: ShadcnColors.mutedForeground),
        ),
      ],
    );
  }
}

class _StoryItem extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool hasUnseenStory;

  const _StoryItem({
    required this.name,
    this.imageUrl,
    this.hasUnseenStory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(3), // Space between border and avatar
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasUnseenStory
                ? const LinearGradient(
                    colors: [
                      Color(0xFFFFD600), // Yellow
                      Color(0xFFFF0169), // Pink/Red
                      Color(0xFFD300C5), // Purple
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  )
                : const LinearGradient(colors: [Colors.grey, Colors.grey]),
          ),
          child: Container(
            padding: const EdgeInsets.all(2), // White border inside gradient
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ShadcnColors.background,
            ),
            child: ShadcnAvatar(
              avatarUrl: imageUrl,
              fallbackInitials: name,
              size: 56, // Slightly larger avatar
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64, // Constrain text width
          child: Text(
            name.split(' ')[0], // First name only
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: hasUnseenStory ? FontWeight.w500 : FontWeight.normal,
              color: ShadcnColors.foreground,
            ),
          ),
        ),
      ],
    );
  }
}
