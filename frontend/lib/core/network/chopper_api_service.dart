import 'package:chopper/chopper.dart';

import 'api_endpoints.dart';

part 'chopper_api_service.chopper.dart';

@ChopperApi()
abstract class ChopperApiService extends ChopperService {
  // Health check
  @Get(path: ApiEndpoints.health)
  Future<Response> healthCheck();

  // Feeds
  @Get(path: ApiEndpoints.feeds)
  Future<Response> getFeeds(@Query('page') int page, @Query('limit') int limit);

  @Post(path: ApiEndpoints.feeds)
  Future<Response> createPost(@Body() Map<String, dynamic> body);

  // Comments
  @Get(path: '/feeds/{postId}/comments/')
  Future<Response> getComments(
    @Path('postId') String postId,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @Post(path: '/feeds/{postId}/comments/')
  Future<Response> createComment(
    @Path('postId') String postId,
    @Body() Map<String, dynamic> body,
  );

  @Delete(path: '/comments/{commentId}/')
  Future<Response> deleteComment(@Path('commentId') String commentId);

  // Post interactions
  @Post(path: '/feeds/{postId}/like/')
  Future<Response> likePost(@Path('postId') String postId);

  @Delete(path: '/feeds/{postId}/like/')
  Future<Response> unlikePost(@Path('postId') String postId);

  @Post(path: '/feeds/{postId}/bookmark/')
  Future<Response> bookmarkPost(@Path('postId') String postId);

  @Delete(path: '/feeds/{postId}/bookmark/')
  Future<Response> unbookmarkPost(@Path('postId') String postId);

  // Authentication endpoints
  @Post(path: ApiEndpoints.register)
  Future<Response> register(@Body() Map<String, dynamic> body);

  @Post(path: ApiEndpoints.login)
  Future<Response> login(@Body() Map<String, dynamic> body);

  @Post(path: ApiEndpoints.logout, optionalBody: true)
  Future<Response> logout();

  @Get(path: ApiEndpoints.profile)
  Future<Response> getProfile();

  // Search endpoints
  @Get(path: ApiEndpoints.search)
  Future<Response> search(
    @Query('query') String query,
    @Query('type') String type,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @Get(path: ApiEndpoints.hotList)
  Future<Response> getHotList();

  @Get(path: ApiEndpoints.hotTags)
  Future<Response> getHotTags();

  static ChopperApiService create([ChopperClient? client]) =>
      _$ChopperApiService(client);
}
