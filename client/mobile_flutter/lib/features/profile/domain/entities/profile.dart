import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

/// Profile entity with additional stats
class Profile extends Equatable {
  const Profile({
    required this.user,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isFollowing = false,
    this.isFollowedBy = false,
  });

  final User user;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isFollowing;
  final bool isFollowedBy;

  @override
  List<Object?> get props => [
        user,
        followersCount,
        followingCount,
        postsCount,
        isFollowing,
        isFollowedBy,
      ];
}
