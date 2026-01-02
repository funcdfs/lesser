import 'package:fixnum/fixnum.dart';
import '../../../../generated/protos/auth/auth.pb.dart' as auth_pb;
import '../../../../generated/protos/common/common.pb.dart' as common_pb;
import '../../domain/entities/user.dart';

/// 用户数据模型
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.displayName,
    super.avatarUrl,
    super.bio,
    super.createdAt,
  });

  /// 从 JSON 创建
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: (json['username'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// 从实体创建
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      createdAt: user.createdAt,
    );
  }

  /// 从 Proto 消息创建
  factory UserModel.fromProto(auth_pb.User proto) {
    return UserModel(
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
    );
  }

  /// 转换为 Proto 消息
  auth_pb.User toProto() {
    final proto = auth_pb.User()
      ..id = id
      ..username = username
      ..email = email;
    if (displayName != null) proto.displayName = displayName!;
    if (avatarUrl != null) proto.avatarUrl = avatarUrl!;
    if (bio != null) proto.bio = bio!;
    if (createdAt != null) {
      proto.createdAt = common_pb.Timestamp()
        ..seconds = Int64(createdAt!.millisecondsSinceEpoch ~/ 1000);
    }
    return proto;
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
