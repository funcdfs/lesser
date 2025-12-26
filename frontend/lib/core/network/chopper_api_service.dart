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

  // Authentication endpoints
  @Post(path: ApiEndpoints.register)
  Future<Response> register(@Body() Map<String, dynamic> body);

  @Post(path: ApiEndpoints.login)
  Future<Response> login(@Body() Map<String, dynamic> body);

  @Post(path: ApiEndpoints.logout, optionalBody: true)
  Future<Response> logout();

  @Get(path: ApiEndpoints.profile)
  Future<Response> getProfile();

  static ChopperApiService create([ChopperClient? client]) =>
      _$ChopperApiService(client);
}
