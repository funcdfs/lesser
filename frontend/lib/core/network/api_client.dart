import 'package:chopper/chopper.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:lesser/core/network/token_manager.dart';
import 'package:lesser/core/network/chopper_api_service.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final ChopperClient _chopperClient;
  late final ChopperApiService _apiService;
  final Logger _logger = Logger();

  ApiClient() {
    // Create Chopper client
    _chopperClient = ChopperClient(
      baseUrl: Uri.parse(ApiEndpoints.baseUrl),
      client: http.Client(),
      interceptors: [
        // Add token interceptor
        (Request request) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            request.headers['Authorization'] = 'Token $token';
          }
          return request;
        },
        // Logging interceptor
        (Request request) async {
          _logger.i('Request: ${request.method} ${request.url}');
          _logger.i('Headers: ${request.headers}');
          _logger.i('Body: ${request.body}');
          return request;
        },
        (Response response) async {
          _logger.i('Response: ${response.statusCode} ${response.body}');
          return response;
        },
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
