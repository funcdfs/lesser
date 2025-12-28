import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/profile.dart';

/// Profile data model
class ProfileModel extends Profile {
  const ProfileModel({
    required super.user,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    super.isFollowing,
    super.isFollowedBy,
  });

  /// Create from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      isFollowedBy: json['is_followed_by'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'is_following': isFollowing,
      'is_followed_by': isFollowedBy,
    };
  }
}
