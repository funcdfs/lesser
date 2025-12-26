import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:lesser/core/network/token_manager.dart';
import 'package:lesser/core/network/chopper_api_service.dart';
import 'api_endpoints.dart';

/// Token interceptor that adds authorization header to requests
class TokenInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final token = await TokenManager.getToken();
    Request request = chain.request;
    
    if (token != null) {
      request = request.copyWith(
        headers: {...request.headers, 'Authorization': 'Token $token'},
      );
    }
    
    return chain.proceed(request);
  }
}

/// Logging interceptor for debugging requests and responses
class LoggingInterceptor implements Interceptor {
  final Logger _logger = Logger();

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;
    _logger.i('Request: ${request.method} ${request.url}');
    _logger.i('Headers: ${request.headers}');
    _logger.i('Body: ${request.body}');
    
    final response = await chain.proceed(request);
    
    _logger.i('Response: ${response.statusCode} ${response.body}');
    
    return response;
  }
}

class ApiClient {
  late final ChopperClient _chopperClient;
  late final ChopperApiService _apiService;

  ApiClient() {
    // Create Chopper client
    _chopperClient = ChopperClient(
      baseUrl: Uri.parse(ApiEndpoints.baseUrl),
      client: http.Client(),
      interceptors: [
        TokenInterceptor(),
        LoggingInterceptor(),
      ],
      converter: const JsonConverter(),
      errorConverter: const JsonConverter(),
    );

    // Create API service
    _apiService = ChopperApiService.create(_chopperClient);
  }

  ChopperApiService get apiService => _apiService;
  ChopperClient get chopperClient => _chopperClient;
}
