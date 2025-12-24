import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

abstract class BaseRepository {
  final Logger logger = Logger();

  Future<T> safeApiCall<T>(
    Future<Response> Function() call, {
    required T Function(dynamic data) mapper,
  }) async {
    try {
      final response = await call();
      return mapper(response.data);
    } on DioException catch (e) {
      logger.e('API Error: ${e.message}', error: e);
      throw _handleDioError(e);
    } catch (e) {
      logger.e('Unexpected Error', error: e);
      throw Exception('An unexpected error occurred');
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return Exception('Server error: $statusCode');
      default:
        return Exception('Network error occurred');
    }
  }
}
