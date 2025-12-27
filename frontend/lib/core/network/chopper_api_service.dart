import 'package:chopper/chopper.dart';

import 'api_endpoints.dart';

part 'chopper_api_service.chopper.dart';

@ChopperApi()
abstract class ChopperApiService extends ChopperService {
  // Health check
  @GET(path: ApiEndpoints.health)
  Future<Response> healthCheck();

  // Feeds
  @GET(path: ApiEndpoints.feeds)
  Future<Response> getFeeds(@Query('page') int page, @Query('limit') int limit);

  @POST(path: ApiEndpoints.feeds)
  Future<Response> createPost(@Body() Map<String, dynamic> body);

  // Comments
  @GET(path: '/feeds/{postId}/comments/')
  Future<Response> getComments(
    @Path('postId') String postId,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST(path: '/feeds/{postId}/comments/')
  Future<Response> createComment(
    @Path('postId') String postId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: '/comments/{commentId}/')
  Future<Response> deleteComment(@Path('commentId') String commentId);

  // Post interactions
  @POST(path: '/feeds/{postId}/like/')
  Future<Response> likePost(@Path('postId') String postId);

  @DELETE(path: '/feeds/{postId}/like/')
  Future<Response> unlikePost(@Path('postId') String postId);

  @POST(path: '/feeds/{postId}/bookmark/')
  Future<Response> bookmarkPost(@Path('postId') String postId);

  @DELETE(path: '/feeds/{postId}/bookmark/')
  Future<Response> unbookmarkPost(@Path('postId') String postId);

  // Authentication endpoints
  @POST(path: ApiEndpoints.register)
  Future<Response> register(@Body() Map<String, dynamic> body);

  @POST(path: ApiEndpoints.login)
  Future<Response> login(@Body() Map<String, dynamic> body);

  @POST(path: ApiEndpoints.logout, optionalBody: true)
  Future<Response> logout();

  @GET(path: ApiEndpoints.profile)
  Future<Response> getProfile();

  // Search endpoints
  @GET(path: ApiEndpoints.search)
  Future<Response> search(
    @Query('query') String query,
    @Query('type') String type,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET(path: ApiEndpoints.hotList)
  Future<Response> getHotList();

  @GET(path: ApiEndpoints.hotTags)
  Future<Response> getHotTags();

  static ChopperApiService create([ChopperClient? client]) =>
      _$ChopperApiService(client);
}
