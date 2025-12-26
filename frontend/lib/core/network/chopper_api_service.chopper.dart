// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'chopper_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ChopperApiService extends ChopperApiService {
  _$ChopperApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ChopperApiService;

  @override
  Future<Response<dynamic>> healthCheck() {
    final Uri $url = Uri.parse('/health');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getFeeds(int page, int limit) {
    final Uri $url = Uri.parse('/feeds/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createPost(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/feeds/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getComments(String postId, int page, int limit) {
    final Uri $url = Uri.parse('/feeds/${postId}/comments/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createComment(
    String postId,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/feeds/${postId}/comments/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteComment(String commentId) {
    final Uri $url = Uri.parse('/comments/${commentId}/');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> likePost(String postId) {
    final Uri $url = Uri.parse('/feeds/${postId}/like/');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> unlikePost(String postId) {
    final Uri $url = Uri.parse('/feeds/${postId}/like/');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> bookmarkPost(String postId) {
    final Uri $url = Uri.parse('/feeds/${postId}/bookmark/');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> unbookmarkPost(String postId) {
    final Uri $url = Uri.parse('/feeds/${postId}/bookmark/');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> register(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/users/register/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> login(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/users/login/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> logout() {
    final Uri $url = Uri.parse('/users/logout/');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getProfile() {
    final Uri $url = Uri.parse('/users/profile/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> search(
    String query,
    String type,
    int page,
    int limit,
  ) {
    final Uri $url = Uri.parse('/search/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'query': query,
      'type': type,
      'page': page,
      'limit': limit,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getHotList() {
    final Uri $url = Uri.parse('/search/hot-list/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getHotTags() {
    final Uri $url = Uri.parse('/search/hot-tags/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
