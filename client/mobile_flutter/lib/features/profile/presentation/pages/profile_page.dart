import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userId != null) {
        ref.read(profileProvider.notifier).loadProfile(widget.userId!);
      } else {
        ref.read(profileProvider.notifier).loadCurrentProfile();
      }
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go(RouteConstants.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final isOwnProfile =
        widget.userId == null || widget.userId == authState.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(profileState.profile?.user.username ?? 'Profile'),
        actions: [
          if (isOwnProfile) ...[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(RouteConstants.settings),
            ),
          ],
        ],
      ),
      body: _buildBody(profileState, isOwnProfile),
    );
  }

  Widget _buildBody(ProfileState profileState, bool isOwnProfile) {
    switch (profileState.status) {
      case ProfileStatus.initial:
      case ProfileStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ProfileStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(profileState.errorMessage ?? 'An error occurred'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (widget.userId != null) {
                    ref
                        .read(profileProvider.notifier)
                        .loadProfile(widget.userId!);
                  } else {
                    ref.read(profileProvider.notifier).loadCurrentProfile();
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      case ProfileStatus.loaded:
        final profile = profileState.profile!;
        return SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profile.user.avatarUrl != null
                          ? NetworkImage(profile.user.avatarUrl!)
                          : null,
                      child: profile.user.avatarUrl == null
                          ? Text(
                              profile.user.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.user.displayName ?? profile.user.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${profile.user.username}',
                      style: const TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 16,
                      ),
                    ),
                    if (profile.user.bio != null &&
                        profile.user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        profile.user.bio!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatItem(count: profile.postsCount, label: 'Posts'),
                        const SizedBox(width: 32),
                        _StatItem(
                          count: profile.followersCount,
                          label: 'Followers',
                        ),
                        const SizedBox(width: 32),
                        _StatItem(
                          count: profile.followingCount,
                          label: 'Following',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action button
                    if (isOwnProfile)
                      OutlinedButton(
                        onPressed: () =>
                            context.push(RouteConstants.editProfile),
                        child: const Text('Edit Profile'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(profileProvider.notifier).toggleFollow(),
                        style: profile.isFollowing
                            ? OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                        child: Text(
                          profile.isFollowing ? 'Following' : 'Follow',
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              // Posts section placeholder
              const Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.grid_on,
                      size: 48,
                      color: AppColors.textSecondaryLight,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Posts will appear here',
                      style: TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.compact,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondaryLight,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
