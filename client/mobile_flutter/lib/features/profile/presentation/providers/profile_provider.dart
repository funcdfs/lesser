import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Profile state
enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final ProfileStatus status;
  final Profile? profile;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

/// Profile notifier
class ProfileNotifier extends Notifier<ProfileState> {
  late final ProfileRepository _repository;

  @override
  ProfileState build() {
    _repository = getIt<ProfileRepository>();
    return const ProfileState();
  }

  /// Load current user's profile
  Future<void> loadCurrentProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _repository.getCurrentProfile();

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) => state = state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      ),
    );
  }

  /// Load profile by user ID
  Future<void> loadProfile(String userId) async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _repository.getProfile(userId);

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      ),
      (profile) => state = state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      ),
    );
  }

  /// Follow/unfollow user
  Future<void> toggleFollow() async {
    if (state.profile == null) return;

    final isFollowing = state.profile!.isFollowing;
    final userId = state.profile!.user.id;

    // Optimistic update
    state = state.copyWith(
      profile: Profile(
        user: state.profile!.user,
        followersCount: state.profile!.followersCount + (isFollowing ? -1 : 1),
        followingCount: state.profile!.followingCount,
        postsCount: state.profile!.postsCount,
        isFollowing: !isFollowing,
        isFollowedBy: state.profile!.isFollowedBy,
      ),
    );

    final result = isFollowing
        ? await _repository.unfollowUser(userId)
        : await _repository.followUser(userId);

    // Revert on failure
    result.fold(
      (failure) => state = state.copyWith(
        profile: Profile(
          user: state.profile!.user,
          followersCount:
              state.profile!.followersCount + (isFollowing ? 1 : -1),
          followingCount: state.profile!.followingCount,
          postsCount: state.profile!.postsCount,
          isFollowing: isFollowing,
          isFollowedBy: state.profile!.isFollowedBy,
        ),
      ),
      (_) {},
    );
  }

  /// Update profile
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final result = await _repository.updateProfile(
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
    );

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (user) {
        if (state.profile != null) {
          state = state.copyWith(
            profile: Profile(
              user: user,
              followersCount: state.profile!.followersCount,
              followingCount: state.profile!.followingCount,
              postsCount: state.profile!.postsCount,
              isFollowing: state.profile!.isFollowing,
              isFollowedBy: state.profile!.isFollowedBy,
            ),
          );
        }
      },
    );
  }
}

/// Profile provider
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
