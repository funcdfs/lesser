import '../../../auth/data/models/user_model.dart';
import '../models/profile_model.dart';

/// Profile remote data source interface
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> getCurrentProfile();
  Future<UserModel> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  });
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<UserModel>> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
  Future<List<UserModel>> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });
}
