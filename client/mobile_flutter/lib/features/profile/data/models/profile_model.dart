import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/profile.dart';
import '../../../../generated/protos/user/user.pb.dart' as user_pb;

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

  /// Create from Proto message
  factory ProfileModel.fromProto(user_pb.Profile proto) {
    return ProfileModel(
      user: UserModel(
        id: proto.id,
        username: proto.username,
        email: proto.email,
        displayName: proto.hasDisplayName() ? proto.displayName : null,
        avatarUrl: proto.hasAvatarUrl() ? proto.avatarUrl : null,
        bio: proto.hasBio() ? proto.bio : null,
        createdAt: proto.hasCreatedAt()
            ? DateTime.fromMillisecondsSinceEpoch(
                proto.createdAt.seconds.toInt() * 1000,
              )
            : null,
      ),
      followersCount: proto.followersCount,
      followingCount: proto.followingCount,
      postsCount: proto.postsCount,
      isFollowing: false, // Not in proto, set default
      isFollowedBy: false, // Not in proto, set default
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
