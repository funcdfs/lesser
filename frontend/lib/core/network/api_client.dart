import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:lesser/core/network/token_manager.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Token $token';
          }
          handler.next(options);
        },
      ),
    );

    // Initial log interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
        logPrint: (object) => _logger.i(object),
      ),
    );
  }

  Dio get dio => _dio;
}
