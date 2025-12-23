import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../widgets/shadcn/shadcn_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoryViewScreen extends StatefulWidget {
  final List<User> users;
  final int initialUserIndex;

  const StoryViewScreen({
    super.key,
    required this.users,
    required this.initialUserIndex,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late PageController _pageController;
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _pageController = PageController(initialPage: widget.initialUserIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStory() {
    final stories = mockStories[widget.users[_currentUserIndex].id] ?? [];
    if (_currentStoryIndex < stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
    } else {
      if (_currentUserIndex < widget.users.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pop(context); // Close if last story of last user
      }
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
    } else {
      if (_currentUserIndex > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent background for modal feel
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Close when tapping outside
        child: Container(
          color: Colors.black54, // Dim background
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.users.length,
            onPageChanged: (index) {
              setState(() {
                _currentUserIndex = index;
                _currentStoryIndex = 0; // Reset story index for new user
              });
            },
            itemBuilder: (context, index) {
              final user = widget.users[index];
              final stories = mockStories[user.id] ?? [];
              
              if (stories.isEmpty) {
                 return Center(
                  child: Text(
                    'No stories for ${user.name}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              // Guard against index out of range if stories update or something is inconsistent
              final safeStoryIndex = _currentStoryIndex >= stories.length ? 0 : _currentStoryIndex;
              final story = stories[safeStoryIndex];

              return Center(
                child: GestureDetector(
                  onTap: () {}, // Absorb taps so background tap doesn't fire
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 60), // Gaps at top and bottom
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Story Content (Image)
                        CachedNetworkImage(
                          imageUrl: story.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                        ),
                        
                        // Navigation Touch Area (Top 80% only)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 100, // Leave space for bottom bar interactions
                          child: GestureDetector(
                             onTapUp: (details) {
                                final width = MediaQuery.of(context).size.width;
                                if (details.localPosition.dx < width / 3) {
                                  _previousStory();
                                } else {
                                  _nextStory();
                                }
                              },
                              child: Container(color: Colors.transparent), // Transparent hit target
                          ),
                        ),
                
                        // Top Progress Bar & User Info
                        Positioned(
                          top: 20,
                          left: 10,
                          right: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(stories.length, (i) {
                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: i == safeStoryIndex
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(1.5),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ShadcnAvatar(
                                    avatarUrl: user.avatar,
                                    fallbackInitials: user.name,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getTimeAgo(story.timestamp),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                
                        // Floating Action Bar (Bottom) - Interaction Zone
                         Positioned(
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: Row(
                            children: [
                              // Text Input Box (Left)
                              Expanded(
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.chat_bubble_outline, 
                                        color: Colors.white.withOpacity(0.7), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Send message...",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Like Button
                              _buildCircleActionButton(
                                icon: Icons.favorite_border, 
                                onTap: () => _showSnackBar("Liked"),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Share/Forward Button (Network Style)
                               _buildCircleActionButton(
                                icon: Icons.share_outlined, // Changed to network share style
                                onTap: () => _showSnackBar("Shared"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inMinutes}m';
    }
  }
}
